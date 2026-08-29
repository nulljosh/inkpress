import Foundation

@MainActor
final class JournalFeedService: ObservableObject {
    @Published var entries: [JournalEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let cacheURL: URL = {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("journal-entries.json")
    }()

    init() {
        loadCache()
    }

    /// Fetch every subscribed feed concurrently, tag each entry with its source, and merge.
    func refresh(feeds: [Feed]) async {
        guard !feeds.isEmpty else { entries = []; return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        var merged: [JournalEntry] = []
        var failures = 0
        await withTaskGroup(of: [JournalEntry].self) { group in
            for feed in feeds {
                group.addTask {
                    guard let url = URL(string: feed.url),
                          let (data, _) = try? await URLSession.shared.data(from: url) else { return [] }
                    return FeedParser.parse(data: data).map {
                        var e = $0; e.sourceTitle = feed.title; return e
                    }
                }
            }
            for await result in group {
                if result.isEmpty { failures += 1 } else { merged.append(contentsOf: result) }
            }
        }

        if merged.isEmpty {
            if failures > 0 { errorMessage = "Couldn't load feeds. Pull to retry." }
            return
        }
        entries = merged.sorted { $0.date > $1.date }
        saveCache()
    }

    private func loadCache() {
        guard let data = try? Data(contentsOf: cacheURL),
              let cached = try? JSONDecoder().decode([JournalEntry].self, from: data) else { return }
        entries = cached.sorted { $0.date > $1.date }
    }

    private func saveCache() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: cacheURL)
    }
}

/// ponytail: hand-rolled parser handling both Atom (<entry>) and RSS 2.0 (<item>).
/// Covers the common feed shapes; swap for a library only if exotic namespaces show up.
final class FeedParser: NSObject, XMLParserDelegate {
    private var entries: [JournalEntry] = []
    private var element = ""
    private var title = ""
    private var link = ""
    private var date = ""
    private var content = ""
    private var mediaSrc = ""
    private var enclosureSrc = ""
    private var inItem = false

    static func parse(data: Data) -> [JournalEntry] {
        let parser = XMLParser(data: data)
        let delegate = FeedParser()
        parser.delegate = delegate
        parser.parse()
        return delegate.entries
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName: String?, attributes attributeDict: [String: String] = [:]) {
        element = elementName
        if elementName == "entry" || elementName == "item" {
            inItem = true; title = ""; link = ""; date = ""; content = ""
            mediaSrc = ""; enclosureSrc = ""
        } else if elementName == "link", inItem, let href = attributeDict["href"] {
            // Atom links carry the URL in the href attribute.
            link = href
        } else if inItem, elementName == "media:thumbnail" || elementName == "media:content" {
            // <media:thumbnail> is an image by definition; <media:content> carries video too.
            if mediaSrc.isEmpty, let u = attributeDict["url"],
               elementName == "media:thumbnail" || Self.isImage(attributeDict, url: u) {
                mediaSrc = u
            }
        } else if inItem, elementName == "enclosure" {
            if enclosureSrc.isEmpty, let u = attributeDict["url"], Self.isImage(attributeDict, url: u) {
                enclosureSrc = u
            }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard inItem else { return }
        switch element {
        case "title": title += string
        case "link": link += string                 // RSS puts the URL in element text
        case "published", "updated", "pubDate", "dc:date": date += string
        case "content", "content:encoded", "description", "summary": content += string
        default: break
        }
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        guard inItem, let s = String(data: CDATABlock, encoding: .utf8) else { return }
        switch element {
        case "content", "content:encoded", "description", "summary": content += s
        case "title": title += s
        default: break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName: String?) {
        guard elementName == "entry" || elementName == "item" else { return }
        inItem = false
        let entryURL = link.trimmingCharacters(in: .whitespacesAndNewlines)
        entries.append(JournalEntry(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            url: entryURL,
            date: Self.parseDate(date.trimmingCharacters(in: .whitespacesAndNewlines)),
            htmlContent: content,
            imageURL: Self.pickImage(media: mediaSrc, enclosure: enclosureSrc,
                                     html: content, entryURL: entryURL)
        ))
    }

    private static let imageExtensions: Set<String> = ["jpg", "jpeg", "png", "gif", "webp", "avif"]

    /// A media/enclosure element is an image if it says so, or — when it declares neither a
    /// type nor a medium — if the URL ends in an image extension.
    static func isImage(_ attributes: [String: String], url: String) -> Bool {
        if let type = attributes["type"] { return type.lowercased().hasPrefix("image/") }
        if let medium = attributes["medium"] { return medium.lowercased() == "image" }
        let ext = (URL(string: url)?.pathExtension ?? "").lowercased()
        return imageExtensions.contains(ext)
    }

    private static let imgSrcRegex = try? NSRegularExpression(
        pattern: "<img[^>]+src\\s*=\\s*[\"']([^\"']+)[\"']", options: .caseInsensitive)

    static func firstImageSrc(inHTML html: String) -> String? {
        guard let re = imgSrcRegex else { return nil }
        let ns = html as NSString
        guard let m = re.firstMatch(in: html, range: NSRange(location: 0, length: ns.length)),
              m.numberOfRanges > 1 else { return nil }
        return ns.substring(with: m.range(at: 1))
    }

    /// Resolve a feed-supplied src against the entry link. Handles protocol-relative
    /// (`//host/x.jpg`) and plain relative paths, and refuses anything that is not http(s)
    /// so `data:` blobs never reach AsyncImage.
    static func resolve(_ src: String, against base: String) -> URL? {
        let s = src.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return nil }
        let baseURL = URL(string: base)
        let resolved: URL?
        if s.hasPrefix("//") {
            resolved = URL(string: (baseURL?.scheme ?? "https") + ":" + s)
        } else if let u = URL(string: s), u.scheme != nil {
            resolved = u
        } else {
            resolved = URL(string: s, relativeTo: baseURL)?.absoluteURL
        }
        guard let out = resolved, let scheme = out.scheme?.lowercased(),
              scheme == "https" || scheme == "http" else { return nil }
        return out
    }

    /// media:* wins over <enclosure>, which wins over the first <img> in the body.
    /// No match means no thumbnail — never a placeholder URL.
    static func pickImage(media: String, enclosure: String, html: String, entryURL: String) -> URL? {
        for candidate in [media, enclosure] where !candidate.isEmpty {
            if let u = resolve(candidate, against: entryURL) { return u }
        }
        guard let src = firstImageSrc(inHTML: html) else { return nil }
        return resolve(src, against: entryURL)
    }

    /// Accept both ISO8601 (Atom) and RFC822 (RSS pubDate). Two RFC822 shapes, because the
    /// zone is written either as an offset (`-0400`) or as a name (`EDT`, `GMT`) and `Z`
    /// only reads the offset form — CBC ships named zones, so one format is not enough.
    private static let rfc822: [DateFormatter] = ["EEE, dd MMM yyyy HH:mm:ss Z",
                                                  "EEE, dd MMM yyyy HH:mm:ss zzz"].map {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = $0
        return f
    }

    static func parseDate(_ s: String) -> Date {
        if let d = ISO8601DateFormatter().date(from: s) { return d }
        for f in rfc822 { if let d = f.date(from: s) { return d } }
        // ponytail: sink undated entries rather than defaulting to `Date()`. Entries are
        // sorted newest-first, so "now" would pin every unparseable entry above real news
        // forever — a whole feed's worth, if that feed uses a format we miss.
        return .distantPast
    }
}

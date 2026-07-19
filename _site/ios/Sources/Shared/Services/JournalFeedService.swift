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
        } else if elementName == "link", inItem, let href = attributeDict["href"] {
            // Atom links carry the URL in the href attribute.
            link = href
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
        entries.append(JournalEntry(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            url: link.trimmingCharacters(in: .whitespacesAndNewlines),
            date: Self.parseDate(date.trimmingCharacters(in: .whitespacesAndNewlines)),
            htmlContent: content
        ))
    }

    /// Accept both ISO8601 (Atom) and RFC822 (RSS pubDate).
    private static let rfc822: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return f
    }()

    static func parseDate(_ s: String) -> Date {
        if let d = ISO8601DateFormatter().date(from: s) { return d }
        if let d = rfc822.date(from: s) { return d }
        return Date()
    }
}

import Foundation

@MainActor
final class JournalFeedService: ObservableObject {
    @Published var entries: [JournalEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let feedURL = URL(string: "https://journal.heyitsmejosh.com/feed.xml")!
    private let cacheURL: URL = {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("journal-entries.json")
    }()

    init() {
        loadCache()
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let (data, _) = try await URLSession.shared.data(from: feedURL)
            let parsed = AtomFeedParser.parse(data: data)
            guard !parsed.isEmpty else { return }
            entries = parsed.sorted { $0.date > $1.date }
            saveCache()
        } catch {
            errorMessage = error.localizedDescription
        }
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

/// ponytail: hand-rolled Atom parser, fine for ~10 entries/year; swap for a library only if the feed format grows more complex.
final class AtomFeedParser: NSObject, XMLParserDelegate {
    private var entries: [JournalEntry] = []
    private var currentElement = ""
    private var currentTitle = ""
    private var currentLink = ""
    private var currentPublished = ""
    private var currentContent = ""
    private var insideEntry = false

    static func parse(data: Data) -> [JournalEntry] {
        let parser = XMLParser(data: data)
        let delegate = AtomFeedParser()
        parser.delegate = delegate
        parser.parse()
        return delegate.entries
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        if elementName == "entry" {
            insideEntry = true
            currentTitle = ""
            currentLink = ""
            currentPublished = ""
            currentContent = ""
        } else if elementName == "link", insideEntry, let href = attributeDict["href"] {
            currentLink = href
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard insideEntry else { return }
        switch currentElement {
        case "title": currentTitle += string
        case "published": currentPublished += string
        case "content": currentContent += string
        default: break
        }
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        guard insideEntry, currentElement == "content",
              let s = String(data: CDATABlock, encoding: .utf8) else { return }
        currentContent += s
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName: String?) {
        if elementName == "entry" {
            insideEntry = false
            let formatter = ISO8601DateFormatter()
            let date = formatter.date(from: currentPublished) ?? Date()
            entries.append(JournalEntry(
                title: currentTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                url: currentLink,
                date: date,
                htmlContent: currentContent
            ))
        }
    }
}

import Foundation

struct Feed: Codable, Identifiable, Hashable {
    var id: String { url }
    var title: String
    let url: String
}

/// Persisted list of subscribed feeds. Seeded with the journal so the app has content
/// on first launch, but the user can add or remove any RSS/Atom feed.
@MainActor
final class FeedStore: ObservableObject {
    @Published var feeds: [Feed] {
        didSet { save() }
    }

    private static let defaultFeed = Feed(title: "Inkpress Journal", url: "https://journal.heyitsmejosh.com/feed.xml")

    private let storeURL: URL = {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("feeds.json")
    }()

    init() {
        if let data = try? Data(contentsOf: storeURL),
           let saved = try? JSONDecoder().decode([Feed].self, from: data) {
            feeds = saved
        } else {
            feeds = [Self.defaultFeed]
        }
    }

    func add(urlString: String) -> Bool {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        var normalized = trimmed
        if !normalized.lowercased().hasPrefix("http") { normalized = "https://" + normalized }
        guard let u = URL(string: normalized), u.host != nil,
              !feeds.contains(where: { $0.url == normalized }) else { return false }
        feeds.append(Feed(title: u.host ?? normalized, url: normalized))
        return true
    }

    func remove(at offsets: IndexSet) {
        feeds.remove(atOffsets: offsets)
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(feeds) else { return }
        try? data.write(to: storeURL)
    }
}

import SwiftUI

struct EntryListView: View {
    @StateObject private var feed = JournalFeedService()
    @StateObject private var store = FeedStore()
    @State private var showFeeds = false

    var body: some View {
        NavigationStack {
            List(feed.entries) { entry in
                NavigationLink(value: entry) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.title).font(.headline)
                        HStack(spacing: 6) {
                            if !entry.sourceTitle.isEmpty {
                                Text(entry.sourceTitle)
                                Text("·")
                            }
                            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Inkpress")
            .navigationDestination(for: JournalEntry.self) { entry in
                EntryDetailView(entry: entry)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showFeeds = true } label: {
                        Label("Feeds", systemImage: "list.bullet.rectangle")
                    }
                }
            }
            .sheet(isPresented: $showFeeds) {
                ManageFeedsView(store: store)
            }
            .refreshable { await feed.refresh(feeds: store.feeds) }
            .overlay {
                if feed.entries.isEmpty && feed.isLoading {
                    ProgressView()
                } else if feed.entries.isEmpty {
                    ContentUnavailableView("No entries yet", systemImage: "doc.text", description: Text("Add a feed or pull to refresh"))
                }
            }
            .task(id: store.feeds) { await feed.refresh(feeds: store.feeds) }
        }
    }
}

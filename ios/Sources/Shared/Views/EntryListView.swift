import SwiftUI

struct EntryListView: View {
    @StateObject private var feed = JournalFeedService()

    var body: some View {
        NavigationStack {
            List(feed.entries) { entry in
                NavigationLink(value: entry) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.title).font(.headline)
                        Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Journal")
            .navigationDestination(for: JournalEntry.self) { entry in
                EntryDetailView(entry: entry)
            }
            .refreshable { await feed.refresh() }
            .overlay {
                if feed.entries.isEmpty && feed.isLoading {
                    ProgressView()
                } else if feed.entries.isEmpty {
                    ContentUnavailableView("No entries yet", systemImage: "doc.text", description: Text("Pull to refresh"))
                }
            }
            .task { await feed.refresh() }
        }
    }
}

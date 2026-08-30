import SwiftUI

struct EntryListView: View {
    @StateObject private var feed: JournalFeedService
    @StateObject private var store: FeedStore
    @State private var showFeeds = false

    /// Both default to the real thing; the parameters exist so the macOS screenshot capture can
    /// hand in a pre-loaded service and a trimmed feed list without writing to the user's saved
    /// subscriptions. No caller in the app passes either.
    init(feed: JournalFeedService? = nil, store: FeedStore? = nil) {
        _feed = StateObject(wrappedValue: feed ?? JournalFeedService())
        _store = StateObject(wrappedValue: store ?? FeedStore())
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if feed.isLoading && !feed.entries.isEmpty {
                    ProgressView().progressViewStyle(.linear)
                }
                List(feed.entries) { entry in
                    HStack {
                        NavigationLink(value: entry) {
                            HStack(spacing: 12) {
                                EntryThumbnail(url: entry.imageURL)
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
                        Spacer()
                        UpvoteButton(entryID: entry.id)
                    }
                }
                .refreshable { await feed.refresh(feeds: store.feeds) }
                .overlay {
                    if feed.entries.isEmpty && feed.isLoading {
                        ProgressView()
                    } else if feed.entries.isEmpty {
                        ContentUnavailableView("No entries yet", systemImage: "doc.text", description: Text("Add a feed or pull to refresh"))
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
            .task(id: store.feeds) { await feed.refresh(feeds: store.feeds) }
        }
    }
}

/// ponytail: fixed box so a slow image can't resize the row mid-load, and nothing at all
/// when the entry has no image — most feeds carry none, and a reserved empty square would
/// indent every row in the list for nothing.
private struct EntryThumbnail: View {
    let url: URL?
    private let side: CGFloat = 56

    var body: some View {
        if let url {
            AsyncImage(url: url) { phase in
                fill(for: phase)
            }
            .frame(width: side, height: side)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
    }

    /// Loading and failure share the placeholder, so a broken image leaves the row the same
    /// height it started at rather than collapsing under the text.
    @ViewBuilder
    private func fill(for phase: AsyncImagePhase) -> some View {
        if case .success(let image) = phase {
            image.resizable().aspectRatio(contentMode: .fill)
        } else {
            Color.secondary.opacity(0.12)
        }
    }
}

import SwiftUI

struct ManageFeedsView: View {
    @ObservedObject var store: FeedStore
    @Environment(\.dismiss) private var dismiss
    @State private var newFeed = ""
    @State private var showError = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        TextField("Add feed URL (RSS or Atom)", text: $newFeed)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.URL)
                            .onSubmit(add)
                        Button("Add", action: add)
                            .disabled(newFeed.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                } footer: {
                    Text("Paste any RSS or Atom feed URL to follow it alongside your journal.")
                }

                Section("Following") {
                    ForEach(store.feeds) { feed in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(feed.title).font(.body)
                            Text(feed.url).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                        }
                    }
                    .onDelete(perform: store.remove)
                }
            }
            .navigationTitle("Feeds")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
            .alert("Invalid or duplicate URL", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    private func add() {
        guard store.add(urlString: newFeed) else { showError = true; return }
        newFeed = ""
    }
}

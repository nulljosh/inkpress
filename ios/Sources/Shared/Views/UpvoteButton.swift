import SwiftUI

@Observable
final class UpvoteStore {
    static let shared = UpvoteStore()
    private let key = "upvotedEntryIDs"
    private(set) var ids: Set<String>

    private init() {
        ids = Set(UserDefaults.standard.stringArray(forKey: key) ?? [])
    }

    func toggle(_ id: String) {
        if ids.contains(id) { ids.remove(id) } else { ids.insert(id) }
        UserDefaults.standard.set(Array(ids), forKey: key)
    }

    func isUpvoted(_ id: String) -> Bool { ids.contains(id) }
}

struct UpvoteButton: View {
    let entryID: String
    @State private var store = UpvoteStore.shared

    var body: some View {
        let on = store.isUpvoted(entryID)
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                store.toggle(entryID)
            }
        } label: {
            Image(systemName: on ? "circle.fill" : "circle")
                .foregroundStyle(on ? .primary : .secondary)
        }
        .buttonStyle(.plain)
    }
}

import SwiftUI

@main
struct JournalApp: App {
    init() {
        #if DEBUG
        // The self-checks were dead code until this call — nothing invoked them.
        feedParserDemo()
        seedFeedsDemo()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            EntryListView()
        }
    }
}

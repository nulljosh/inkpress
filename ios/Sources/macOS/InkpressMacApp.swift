import SwiftUI

@main
struct InkpressMacApp: App {
    init() {
        // `--capture <state>` renders one App Store frame offscreen, prints its path and
        // exits before any real window opens. DEBUG-only; the shipped binary has no such path.
        #if DEBUG
        if MainActor.assumeIsolated({ ScreenshotCapture.runIfRequested() }) { return }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            EntryListView()
                .frame(minWidth: 720, minHeight: 480)
        }
        .defaultSize(width: 1280, height: 800)
        .commands { SidebarCommands() }
    }
}

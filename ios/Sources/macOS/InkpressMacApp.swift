import SwiftUI

@main
struct InkpressMacApp: App {
    var body: some Scene {
        WindowGroup {
            EntryListView()
                .frame(minWidth: 720, minHeight: 480)
        }
        .defaultSize(width: 1280, height: 800)
        .commands { SidebarCommands() }
    }
}

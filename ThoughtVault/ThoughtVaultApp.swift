import SwiftUI

@main
struct ThoughtVaultApp: App {
    @State private var store = QuoteStore()

    var body: some Scene {
        WindowGroup {
            QuoteListView()
                .environment(store)
        }
    }
}

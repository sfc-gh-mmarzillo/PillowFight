import SwiftUI

@main
struct PillowFightApp: App {
    @StateObject private var gameManager = GameManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameManager)
                .preferredColorScheme(.dark)
        }
    }
}

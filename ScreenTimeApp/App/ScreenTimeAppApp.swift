import SwiftUI
import ScreenTimeApp

@main
struct ScreenTimeAppApp: App {
    // Environment objects
    @StateObject private var authService = MockAuthService()
    @StateObject private var homeViewModel = MockHomeViewModel()
    @StateObject private var groupViewModel = MockGroupViewModel()
    @StateObject private var notificationsManager = MockNotificationsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(homeViewModel)
                .environmentObject(groupViewModel)
                .environmentObject(notificationsManager)
        }
    }
}

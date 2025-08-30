import SwiftUI
import UserNotifications

@main
struct ScreenTimeApp: App {
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

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        SwiftUI.Group {
            if authService.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Limits", systemImage: "timer")
                }
            
            GroupListView()
                .tabItem {
                    Label("Group", systemImage: "person.3")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    Button("Sign Out") {
                        Task {
                            await authService.signOut()
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

import Foundation
import Combine

class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var authError: Error?
    
    init() {
        // Base class implementation
    }
    
    func checkSession() async {
        // Base class implementation
    }
    
    func signUp(email: String, password: String) async {
        // Base class implementation
    }
    
    func signIn(email: String, password: String) async {
        // Base class implementation
    }
    
    func signOut() async {
        // Base class implementation
    }
    
    func resetPassword(email: String) async {
        // Base class implementation
    }
}

// Simplified User model to match Supabase user properties
struct User: Codable, Identifiable {
    let id: String
    let email: String?
    let userMetadata: [String: String]?
    var profilePictureUrl: String?

    var username: String? {
        return userMetadata?["username"]
    }

    var displayName: String {
        return username ?? email ?? "User"
    }

    var profileInitial: String {
        return displayName.prefix(1).uppercased()
    }
}

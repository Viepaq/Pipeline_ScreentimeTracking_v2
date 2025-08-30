import Foundation
import Combine

class MockAuthService: AuthService {
    private var mockUser = User(
        id: "user-1",
        email: "test@example.com",
        userMetadata: ["username": "testuser"]
    )
    
    override init() {
        super.init()
        // Uncomment to start with a logged-in user
        // isAuthenticated = true
        // currentUser = mockUser
    }
    
    override func checkSession() async {
        // Mock implementation - do nothing
    }
    
    override func signUp(email: String, password: String) async {
        DispatchQueue.main.async {
            // Simulate successful signup
            self.authError = nil
            // In a real app, the user would need to verify email
        }
    }
    
    override func signIn(email: String, password: String) async {
        DispatchQueue.main.async {
            // Always succeed in mock mode
            self.isAuthenticated = true
            self.currentUser = self.mockUser
            self.authError = nil
        }
    }
    
    override func signOut() async {
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.currentUser = nil
            self.authError = nil
        }
    }
    
    override func resetPassword(email: String) async {
        DispatchQueue.main.async {
            self.authError = nil
        }
    }
}

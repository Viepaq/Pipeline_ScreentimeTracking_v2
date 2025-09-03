import SwiftUI

@main
struct ScreenTimeAppPreviewApp: App {
    // Environment objects
    @StateObject private var authService = MockAuthService()
    @StateObject private var homeViewModel = MockHomeViewModel()
    @StateObject private var groupViewModel = MockGroupViewModel()
    @StateObject private var notificationsManager = MockNotificationsManager()
    @StateObject private var responseManager = ResponseManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(homeViewModel)
                .environmentObject(groupViewModel)
                .environmentObject(notificationsManager)
                .environmentObject(responseManager)
                .preferredColorScheme(.dark)
        }
    }
}

// Response manager for tracking responses to extension requests
class ResponseManager: ObservableObject {
    @Published var decisions: [String: Bool] = [:]
    @Published var denyReasons: [String: String] = [:]

    func setDecision(for requestId: String, approved: Bool) {
        objectWillChange.send()
        decisions[requestId] = approved
        print("Decision set for \(requestId): \(approved)")
    }

    func setDenyReason(for requestId: String, reason: String) {
        objectWillChange.send()
        denyReasons[requestId] = reason
    }

    func reset(for requestId: String) {
        objectWillChange.send()
        decisions.removeValue(forKey: requestId)
        denyReasons.removeValue(forKey: requestId)
    }
}

// Profile Picture Component
struct ProfilePictureView: View {
    let user: User
    let size: CGFloat

    var body: some View {
        ZStack {
            if let profilePictureUrl = user.profilePictureUrl {
                // Display actual profile picture
                AsyncImage(url: URL(string: profilePictureUrl)) { phase in
                    switch phase {
                    case .empty:
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: size, height: size)
                            .overlay(
                                ProgressView()
                                    .scaleEffect(0.5)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                    case .failure(_):
                        // Fallback to initial
                        initialView
                    @unknown default:
                        initialView
                    }
                }
            } else {
                // Display initial
                initialView
            }
        }
    }

    private var initialView: some View {
        Circle()
            .fill(Color.blue.opacity(0.8))
            .frame(width: size, height: size)
            .overlay(
                Text(user.profileInitial)
                    .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            )
    }
}

// Profile Picture Picker
struct ProfilePicturePicker: View {
    @Binding var selectedImage: String?
    @State private var showingImagePicker = false

    // Mock image options for demo
    let mockImages = [
        "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&h=100&fit=crop&crop=face",
        "https://images.unsplash.com/photo-1494790108755-2616b612b5bc?w=100&h=100&fit=crop&crop=face",
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face",
        "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop&crop=face",
        "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face"
    ]

    var body: some View {
        VStack(spacing: 16) {
            Text("Choose Profile Picture")
                .font(.headline)
                .padding(.top)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                // Current selection indicator
                if selectedImage == nil {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(Color.blue, lineWidth: 3)
                            )

                        Text("T")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.blue)
                    }
                }

                // Mock profile pictures
                ForEach(mockImages, id: \.self) { imageUrl in
                    ZStack {
                        AsyncImage(url: URL(string: imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 80, height: 80)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            case .failure(_):
                                Circle()
                                    .fill(Color.red.opacity(0.3))
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Image(systemName: "exclamationmark.triangle")
                                            .foregroundColor(.red)
                                    )
                            @unknown default:
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 80, height: 80)
                            }
                        }

                        if selectedImage == imageUrl {
                            Circle()
                                .stroke(Color.blue, lineWidth: 3)
                                .frame(width: 80, height: 80)
                        }
                    }
                    .onTapGesture {
                        selectedImage = imageUrl
                    }
                }
            }
            .padding(.horizontal)

            Button(action: {
                selectedImage = nil // Clear selection
            }) {
                HStack {
                    Image(systemName: "person.circle")
                    Text("Use Initial Instead")
                }
                .foregroundColor(.blue)
                .padding()
            }
        }
        .padding()
    }
}

// Group Member Profile Picture Component
struct GroupMemberProfileView: View {
    let member: GroupMember
    let size: CGFloat
    var showBorder: Bool = true

    var body: some View {
        ZStack {
            if let profilePictureUrl = member.profilePictureUrl {
                // Display actual profile picture
                AsyncImage(url: URL(string: profilePictureUrl)) { phase in
                    switch phase {
                    case .empty:
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: size, height: size)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                    case .failure(_):
                        // Fallback to initial
                        initialView
                    @unknown default:
                        initialView
                    }
                }
            } else {
                // Display initial
                initialView
            }
        }
        .overlay(alignment: .center) {
            if showBorder {
                Circle()
                    .stroke(Color.white, lineWidth: 1.5)
                    .frame(width: size, height: size)
            }
        }
        .shadow(color: Color.black.opacity(0.08), radius: 1, x: 0, y: 0.5)
    }

    private var initialView: some View {
        Circle()
            .fill(Color.blue.opacity(0.8))
            .frame(width: size, height: size)
            .overlay(
                Text(member.profileInitial)
                    .font(.system(size: size * 0.45, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            )
    }
}

// Extension Request model for preview app
struct ExtensionRequest: Identifiable {
    var id: String = UUID().uuidString
    var appId: String
    var appName: String
    var requestedMinutes: Int
    var reason: String
    var userId: String
    var groupId: String
    var status: ExtensionStatus = .pending
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var responses: [ExtensionResponse] = []
    var responseDecision: Bool? = nil
    var denyReason: String = ""
    
    // Mock data for previews
    static let mockRequest = ExtensionRequest(
        appId: "com.instagram.ios",
        appName: "Instagram",
        requestedMinutes: 30,
        reason: "Need to respond to important messages from my team about tomorrow's presentation.",
        userId: "user-2",
        groupId: "group-1"
    )
}

struct ExtensionResponse: Identifiable {
    var id: String = UUID().uuidString
    var requestId: String
    var userId: String
    var approved: Bool
    var comment: String?
    var createdAt: Date = Date()
}

enum ExtensionStatus: String {
    case pending
    case approved
    case denied
}

// Mock implementations for preview
class MockAuthService: ObservableObject {
    @Published var isAuthenticated = false  // Start as not authenticated
    @Published var currentUser: User? = nil
    @Published var authError: Error?
    @Published var requiresPasswordCreation = false

    // Simple in-memory password storage for demo
    private var userPasswords: [String: String] = [:]

    func signIn(email: String, password: String) async {
        // Check if user exists
        if email == "test@example.com" {
            // Check if user has a password set
            if let storedPassword = userPasswords[email] {
                // Verify password
                if storedPassword == password {
                    isAuthenticated = true
                    currentUser = User(id: "user-1", email: email, userMetadata: ["username": "testuser"], profilePictureUrl: nil)
                    requiresPasswordCreation = false
                } else {
                    authError = NSError(domain: "AuthError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Incorrect password"])
                }
            } else {
                // User doesn't have a password - require creation
                requiresPasswordCreation = true
                currentUser = User(id: "user-1", email: email, userMetadata: ["username": "testuser"], profilePictureUrl: nil)
                authError = NSError(domain: "AuthError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Password required. Please create a password."])
            }
        } else {
            authError = NSError(domain: "AuthError", code: 3, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
    }

    func createPassword(email: String, password: String) async {
        userPasswords[email] = password
        isAuthenticated = true
        requiresPasswordCreation = false
        authError = nil
    }

    func resetPassword(email: String) async -> Bool {
        // Check if user exists
        if email == "test@example.com" {
            // In a real app, this would send an email with a reset link
            // For demo purposes, we'll just simulate success
            return true
        } else {
            return false
        }
    }

    func signOut() async {
        isAuthenticated = false
        currentUser = nil
        requiresPasswordCreation = false
    }
}

class MockHomeViewModel: ObservableObject {
    @Published var screenTimeLimits: [ScreenTimeLimit] = [
        ScreenTimeLimit(
            appId: "com.instagram.ios",
            appName: "Instagram",
            iconName: "camera",
            dailyLimitMinutes: 30,
            userId: "user-1"
        ),
        ScreenTimeLimit(
            appId: "com.tiktok.ios",
            appName: "TikTok",
            iconName: "play.rectangle",
            dailyLimitMinutes: 45,
            userId: "user-1"
        ),
        ScreenTimeLimit(
            appId: "com.google.ios.youtube",
            appName: "YouTube",
            iconName: "play.tv",
            dailyLimitMinutes: 60,
            userId: "user-1"
        )
    ]
    
    @Published var screenTimeUsage: [ScreenTimeUsage] = [
        ScreenTimeUsage(
            appId: "com.instagram.ios",
            appName: "Instagram",
            minutesUsed: 15,
            userId: "user-1"
        ),
        ScreenTimeUsage(
            appId: "com.tiktok.ios",
            appName: "TikTok",
            minutesUsed: 25,
            userId: "user-1"
        ),
        ScreenTimeUsage(
            appId: "com.google.ios.youtube",
            appName: "YouTube",
            minutesUsed: 40,
            userId: "user-1"
        )
    ]
    
    @Published var totalMinutesUsed: Int = 80
    @Published var totalDailyLimit: Int = 135
    @Published var isLoading = false
    
    var remainingMinutes: Int {
        max(0, totalDailyLimit - totalMinutesUsed)
    }
    
    var usagePercentage: Double {
        guard totalDailyLimit > 0 else { return 0 }
        return Double(totalMinutesUsed) / Double(totalDailyLimit)
    }
    
    var isOverLimit: Bool {
        totalMinutesUsed > totalDailyLimit
    }
    
    func updateLimit(for appId: String, minutes: Int) {
        if let index = screenTimeLimits.firstIndex(where: { $0.appId == appId }) {
            screenTimeLimits[index].dailyLimitMinutes = minutes
        }
    }
    
    func addUsageTime(for appId: String, minutes: Int) {
        if let index = screenTimeUsage.firstIndex(where: { $0.appId == appId }) {
            screenTimeUsage[index].minutesUsed += minutes
            totalMinutesUsed += minutes
        }
    }
    
    func resetUsage() {
        for i in 0..<screenTimeUsage.count {
            screenTimeUsage[i].minutesUsed = 0
        }
        totalMinutesUsed = 0
    }
    
    func isAppBlocked(appId: String) -> Bool {
        guard isOverLimit else { return false }
        
        if let usage = screenTimeUsage.first(where: { $0.appId == appId }),
           let limit = screenTimeLimits.first(where: { $0.appId == appId }) {
            return usage.minutesUsed >= limit.dailyLimitMinutes
        }
        
        return false
    }
}

class MockGroupViewModel: ObservableObject {
    @Published var currentGroup: Group? = Group(
        id: "group-1",
        name: "Focus Friends",
        description: "A group to help each other stay focused",
        adminUserId: "user-1",
        members: [
            GroupMember(
                id: "member-1",
                userId: "user-1",
                groupId: "group-1",
                username: "johndoe",
                email: "john@example.com",
                profilePictureUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face",
                status: .active,
                joinedAt: Date()
            ),
            GroupMember(
                id: "member-2",
                userId: "user-2",
                groupId: "group-1",
                username: "janedoe",
                email: "jane@example.com",
                profilePictureUrl: "https://images.unsplash.com/photo-1494790108755-2616b612b5bc?w=100&h=100&fit=crop&crop=face",
                status: .active,
                joinedAt: Date()
            ),
            GroupMember(
                id: "member-3",
                userId: "user-3",
                groupId: "group-1",
                username: "bobsmith",
                email: "bob@example.com",
                profilePictureUrl: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face",
                status: .active,
                joinedAt: Date()
            ),
            GroupMember(
                id: "member-4",
                userId: "user-4",
                groupId: "group-1",
                username: "sarahwilson",
                email: "sarah@example.com",
                profilePictureUrl: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop&crop=face",
                status: .active,
                joinedAt: Date()
            )
        ]
    )
    
    @Published var pendingInvitations: [GroupMember] = []
    @Published var isLoading = false
    
    func isUserAdmin(userId: String) -> Bool {
        return currentGroup?.adminUserId == userId
    }
    
    func hasPendingInvitation(userId: String) -> Bool {
        return pendingInvitations.contains(where: { $0.userId == userId })
    }
}

class MockNotificationsManager: ObservableObject {
    @Published var notifications: [NotificationItem] = []
    @Published var unreadCount: Int = 2
}

// Model structs
struct User: Codable, Identifiable {
    var id: String
    var email: String?
    var userMetadata: [String: String]?
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

struct ScreenTimeLimit: Identifiable {
    var id: String = UUID().uuidString
    var appId: String
    var appName: String
    var iconName: String
    var dailyLimitMinutes: Int
    var userId: String
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}

struct ScreenTimeUsage: Identifiable {
    var id: String = UUID().uuidString
    var appId: String
    var appName: String
    var minutesUsed: Int
    var date: Date = Date()
    var userId: String
}

struct Group: Identifiable {
    var id: String
    var name: String
    var description: String?
    var groupPictureUrl: String? = nil
    var adminUserId: String
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var members: [GroupMember]
}

struct GroupMember: Identifiable {
    var id: String
    var userId: String
    var groupId: String
    var username: String
    var email: String
    var profilePictureUrl: String?
    var status: MembershipStatus
    var joinedAt: Date?
    var invitedAt: Date = Date()

    var displayName: String {
        return username
    }

    var profileInitial: String {
        return displayName.prefix(1).uppercased()
    }
}

enum MembershipStatus: String {
    case pending
    case active
    case declined
    case removed
}

struct NotificationItem: Identifiable {
    var id: String = UUID().uuidString
    var title: String
    var body: String
    var type: NotificationType
    var relatedId: String?
    var createdAt: Date = Date()
    var isRead: Bool = false
    var userId: String
}

enum NotificationType: String {
    case extensionRequest
    case extensionApproved
    case extensionDenied
    case groupInvite
    case groupJoined
    case dailySummary
}
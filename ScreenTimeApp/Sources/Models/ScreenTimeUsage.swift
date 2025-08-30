import Foundation

struct ScreenTimeUsage: Identifiable, Codable, Equatable {
    var id: String
    var appId: String
    var appName: String
    var minutesUsed: Int
    var date: Date
    var userId: String
    
    init(id: String = UUID().uuidString,
         appId: String,
         appName: String,
         minutesUsed: Int,
         date: Date = Date(),
         userId: String) {
        self.id = id
        self.appId = appId
        self.appName = appName
        self.minutesUsed = minutesUsed
        self.date = date
        self.userId = userId
    }
    
    static func == (lhs: ScreenTimeUsage, rhs: ScreenTimeUsage) -> Bool {
        return lhs.id == rhs.id
    }
}

// Mock data for development and testing
extension ScreenTimeUsage {
    static let mockUsage = [
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
}

struct ExtensionRequest: Identifiable, Codable {
    var id: String
    var appId: String
    var appName: String
    var requestedMinutes: Int
    var reason: String
    var userId: String
    var groupId: String
    var status: ExtensionStatus
    var createdAt: Date
    var updatedAt: Date
    var responses: [ExtensionResponse]
    
    init(id: String = UUID().uuidString,
         appId: String,
         appName: String,
         requestedMinutes: Int,
         reason: String,
         userId: String,
         groupId: String,
         status: ExtensionStatus = .pending,
         createdAt: Date = Date(),
         updatedAt: Date = Date(),
         responses: [ExtensionResponse] = []) {
        self.id = id
        self.appId = appId
        self.appName = appName
        self.requestedMinutes = requestedMinutes
        self.reason = reason
        self.userId = userId
        self.groupId = groupId
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.responses = responses
    }
}

struct ExtensionResponse: Identifiable, Codable {
    var id: String
    var requestId: String
    var userId: String
    var approved: Bool
    var comment: String?
    var createdAt: Date
    
    init(id: String = UUID().uuidString,
         requestId: String,
         userId: String,
         approved: Bool,
         comment: String? = nil,
         createdAt: Date = Date()) {
        self.id = id
        self.requestId = requestId
        self.userId = userId
        self.approved = approved
        self.comment = comment
        self.createdAt = createdAt
    }
}

enum ExtensionStatus: String, Codable {
    case pending
    case approved
    case denied
}

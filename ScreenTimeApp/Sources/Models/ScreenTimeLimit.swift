import Foundation

struct ScreenTimeLimit: Identifiable, Codable, Equatable {
    var id: String
    var appId: String
    var appName: String
    var iconName: String
    var dailyLimitMinutes: Int
    var userId: String
    var createdAt: Date
    var updatedAt: Date
    
    init(id: String = UUID().uuidString,
         appId: String,
         appName: String,
         iconName: String,
         dailyLimitMinutes: Int,
         userId: String,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.appId = appId
        self.appName = appName
        self.iconName = iconName
        self.dailyLimitMinutes = dailyLimitMinutes
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    static func == (lhs: ScreenTimeLimit, rhs: ScreenTimeLimit) -> Bool {
        return lhs.id == rhs.id
    }
}

// Mock data for development and testing
extension ScreenTimeLimit {
    static let mockApps = [
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
}

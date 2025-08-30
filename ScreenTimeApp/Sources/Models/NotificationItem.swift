import Foundation
import UserNotifications

struct NotificationItem: Identifiable, Codable, Equatable {
    var id: String
    var title: String
    var body: String
    var type: NotificationType
    var relatedId: String?
    var createdAt: Date
    var isRead: Bool
    var userId: String
    
    init(id: String = UUID().uuidString,
         title: String,
         body: String,
         type: NotificationType,
         relatedId: String? = nil,
         createdAt: Date = Date(),
         isRead: Bool = false,
         userId: String) {
        self.id = id
        self.title = title
        self.body = body
        self.type = type
        self.relatedId = relatedId
        self.createdAt = createdAt
        self.isRead = isRead
        self.userId = userId
    }
    
    static func == (lhs: NotificationItem, rhs: NotificationItem) -> Bool {
        return lhs.id == rhs.id
    }
}

enum NotificationType: String, Codable {
    case extensionRequest
    case extensionApproved
    case extensionDenied
    case groupInvite
    case groupJoined
    case dailySummary
}

// NotificationsManager moved to MockNotificationsManager.swift

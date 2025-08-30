import Foundation
import UserNotifications

class MockNotificationsManager: ObservableObject {
    @Published var notifications: [NotificationItem] = []
    @Published var unreadCount: Int = 0
    
    init() {
        // Request notification permissions
        requestNotificationPermissions()
        
        // Load mock data
        loadMockData()
    }
    
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error)")
            }
            
            if granted {
                print("Notification permissions granted")
                
                // Register for remote notifications (APNs)
                // Commented out for now as we don't need actual push registration in mock mode
                // DispatchQueue.main.async {
                //     UIApplication.shared.registerForRemoteNotifications()
                // }
            }
        }
    }
    
    func loadMockData() {
        notifications = [
            NotificationItem(
                title: "Time Extension Request",
                body: "John requested 30 more minutes for Instagram",
                type: .extensionRequest,
                relatedId: "request-1",
                createdAt: Date().addingTimeInterval(-3600), // 1 hour ago
                userId: "user-1"
            ),
            NotificationItem(
                title: "Extension Approved",
                body: "Your request for 15 more minutes on TikTok was approved",
                type: .extensionApproved,
                relatedId: "request-2",
                createdAt: Date().addingTimeInterval(-7200), // 2 hours ago
                userId: "user-1"
            ),
            NotificationItem(
                title: "Group Invitation",
                body: "Jane invited you to join 'Focus Friends'",
                type: .groupInvite,
                relatedId: "group-1",
                createdAt: Date().addingTimeInterval(-86400), // 1 day ago
                userId: "user-1"
            ),
            NotificationItem(
                title: "Daily Summary",
                body: "You used 45 minutes of screen time today (75% of your limit)",
                type: .dailySummary,
                createdAt: Date().addingTimeInterval(-172800), // 2 days ago
                userId: "user-1"
            )
        ]
        
        updateUnreadCount()
    }
    
    func fetchNotifications(userId: String) async {
        // In a real app, this would fetch notifications from Supabase
        // For now, we're using mock data
        DispatchQueue.main.async {
            self.loadMockData()
        }
    }
    
    func markAsRead(notificationId: String) {
        if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
            notifications[index].isRead = true
            updateUnreadCount()
        }
    }
    
    func markAllAsRead() {
        for i in 0..<notifications.count {
            notifications[i].isRead = true
        }
        updateUnreadCount()
    }
    
    func deleteNotification(notificationId: String) {
        notifications.removeAll { $0.id == notificationId }
        updateUnreadCount()
    }
    
    func clearAllNotifications() {
        notifications.removeAll()
        updateUnreadCount()
    }
    
    private func updateUnreadCount() {
        unreadCount = notifications.filter { !$0.isRead }.count
    }
    
    // For sending local notifications (for testing)
    func scheduleLocalNotification(title: String, body: String, type: NotificationType) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Add to category based on type
        content.categoryIdentifier = type.rawValue
        
        // Schedule for immediate delivery
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    // For handling APNs token
    func registerDeviceToken(_ deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(tokenString)")
    }
}

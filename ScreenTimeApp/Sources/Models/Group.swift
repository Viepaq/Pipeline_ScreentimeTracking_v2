import Foundation

struct Group: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var description: String?
    var adminUserId: String
    var createdAt: Date
    var updatedAt: Date
    var members: [GroupMember]
    
    init(id: String = UUID().uuidString,
         name: String,
         description: String? = nil,
         adminUserId: String,
         createdAt: Date = Date(),
         updatedAt: Date = Date(),
         members: [GroupMember] = []) {
        self.id = id
        self.name = name
        self.description = description
        self.adminUserId = adminUserId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.members = members
    }
    
    static func == (lhs: Group, rhs: Group) -> Bool {
        return lhs.id == rhs.id
    }
}

struct GroupMember: Identifiable, Codable, Equatable {
    var id: String
    var userId: String
    var groupId: String
    var username: String
    var email: String
    var status: MembershipStatus
    var joinedAt: Date?
    var invitedAt: Date
    
    init(id: String = UUID().uuidString,
         userId: String,
         groupId: String,
         username: String,
         email: String,
         status: MembershipStatus = .pending,
         joinedAt: Date? = nil,
         invitedAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.groupId = groupId
        self.username = username
        self.email = email
        self.status = status
        self.joinedAt = joinedAt
        self.invitedAt = invitedAt
    }
    
    static func == (lhs: GroupMember, rhs: GroupMember) -> Bool {
        return lhs.id == rhs.id
    }
}

enum MembershipStatus: String, Codable {
    case pending
    case active
    case declined
    case removed
}

// Mock data for development and testing
extension Group {
    static let mockGroup = Group(
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
                status: .active,
                joinedAt: Date()
            ),
            GroupMember(
                id: "member-2",
                userId: "user-2",
                groupId: "group-1",
                username: "janedoe",
                email: "jane@example.com",
                status: .active,
                joinedAt: Date()
            ),
            GroupMember(
                id: "member-3",
                userId: "user-3",
                groupId: "group-1",
                username: "bobsmith",
                email: "bob@example.com",
                status: .pending
            )
        ]
    )
}

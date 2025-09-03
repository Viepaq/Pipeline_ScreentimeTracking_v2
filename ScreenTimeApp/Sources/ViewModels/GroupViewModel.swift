import Foundation
import Combine
import SwiftUI

class GroupViewModel: ObservableObject {
    @Published var currentGroup: Group?
    @Published var pendingInvitations: [GroupMember] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var searchResults: [User] = []
    @Published var isSearching = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Base initialization
    }
    
    func loadMockData() {
        currentGroup = Group.mockGroup
        pendingInvitations = currentGroup?.members.filter { $0.status == .pending } ?? []
    }
    
    func fetchUserGroup(userId: String) async {
        // In a real app, this would fetch data from Supabase
        // For now, we're using mock data
        DispatchQueue.main.async {
            self.isLoading = true
            self.currentGroup = Group.mockGroup
            self.pendingInvitations = self.currentGroup?.members.filter { $0.status == .pending } ?? []
            self.isLoading = false
        }
    }
    
    func createGroup(name: String, description: String?, userId: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            
            // In a real app, this would create a group in Supabase
            let newGroup = Group(
                name: name,
                description: description,
                adminUserId: userId,
                members: [
                    GroupMember(
                        userId: userId,
                        groupId: UUID().uuidString,
                        username: "currentUser", // This would be the actual username
                        email: "user@example.com", // This would be the actual email
                        status: .active,
                        joinedAt: Date()
                    )
                ]
            )
            
            self.currentGroup = newGroup
            self.isLoading = false
        }
    }
    
    func searchUsers(username: String) async {
        guard !username.isEmpty else {
            DispatchQueue.main.async {
                self.searchResults = []
                self.isSearching = false
            }
            return
        }
        
        DispatchQueue.main.async {
            self.isSearching = true
            
            // In a real app, this would search users in Supabase
            // Mock search results
            self.searchResults = [
                User(id: "user-4", email: "alex@example.com", userMetadata: ["username": "alex123"]),
                User(id: "user-5", email: "sam@example.com", userMetadata: ["username": "samsmith"]),
                User(id: "user-6", email: "taylor@example.com", userMetadata: ["username": "taylor"])
            ].filter { $0.username?.contains(username.lowercased()) ?? false }
            
            self.isSearching = false
        }
    }
    
    func inviteUser(user: User) async {
        guard let groupId = currentGroup?.id else { return }
        
        DispatchQueue.main.async {
            self.isLoading = true
            
            // In a real app, this would create an invitation in Supabase
            let newMember = GroupMember(
                userId: user.id,
                groupId: groupId,
                username: user.username ?? "unknown",
                email: user.email ?? "unknown@example.com",
                status: .pending
            )
            
            // Add to current group members
            self.currentGroup?.members.append(newMember)
            self.pendingInvitations.append(newMember)
            
            self.isLoading = false
        }
    }
    
    func acceptInvitation(groupId: String, userId: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            
            // In a real app, this would update the membership status in Supabase
            let mockGroup = Group.mockGroup
            self.currentGroup = mockGroup
            
            self.isLoading = false
        }
    }
    
    func declineInvitation(groupId: String, userId: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            
            // In a real app, this would update the membership status in Supabase
            self.currentGroup = nil
            self.pendingInvitations = []
            
            self.isLoading = false
        }
    }
    
    func removeMember(memberId: String) async {
        guard let groupId = currentGroup?.id, 
              let currentUserId = currentGroup?.adminUserId else { return }
        
        DispatchQueue.main.async {
            self.isLoading = true
            
            // In a real app, this would update the membership in Supabase
            // Only allow if current user is admin
            if let index = self.currentGroup?.members.firstIndex(where: { $0.id == memberId }) {
                self.currentGroup?.members.remove(at: index)
                
                // Also remove from pending invitations if present
                if let pendingIndex = self.pendingInvitations.firstIndex(where: { $0.id == memberId }) {
                    self.pendingInvitations.remove(at: pendingIndex)
                }
            }
            
            self.isLoading = false
        }
    }
    
    func leaveGroup() async {
        guard let groupId = currentGroup?.id,
              let currentUserId = currentGroup?.adminUserId else { return }
        
        DispatchQueue.main.async {
            self.isLoading = true
            
            // In a real app, this would update the membership in Supabase
            self.currentGroup = nil
            self.pendingInvitations = []
            
            self.isLoading = false
        }
    }

    func updateGroup(name: String, description: String?) async {
        DispatchQueue.main.async {
            self.isLoading = true
            if var group = self.currentGroup {
                group.name = name
                group.description = description
                group.updatedAt = Date()
                self.currentGroup = group
            }
            self.isLoading = false
        }
    }

    func deleteGroup() async {
        DispatchQueue.main.async {
            self.isLoading = true
            // In a real app, this would delete the group in Supabase and notify members
            self.currentGroup = nil
            self.pendingInvitations = []
            self.isLoading = false
        }
    }
    
    func isUserAdmin(userId: String) -> Bool {
        return currentGroup?.adminUserId == userId
    }
    
    func hasActiveGroup(userId: String) -> Bool {
        return currentGroup != nil
    }
    
    func hasPendingInvitation(userId: String) -> Bool {
        return pendingInvitations.contains(where: { $0.userId == userId })
    }
}

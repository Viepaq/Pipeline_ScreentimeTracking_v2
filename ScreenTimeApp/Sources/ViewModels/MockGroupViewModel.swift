import Foundation
import Combine
import SwiftUI

class MockGroupViewModel: GroupViewModel {
    override init() {
        super.init()
        // Load mock data
        loadMockData()
    }
    
    override func loadMockData() {
        currentGroup = Group.mockGroup
        pendingInvitations = currentGroup?.members.filter { $0.status == .pending } ?? []
    }
}

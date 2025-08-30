import Foundation
import Combine
import SwiftUI

class MockHomeViewModel: HomeViewModel {
    override init() {
        super.init()
        // Load mock data
        loadMockData()
    }
    
    override func loadMockData() {
        screenTimeLimits = ScreenTimeLimit.mockApps
        screenTimeUsage = ScreenTimeUsage.mockUsage
        
        calculateTotalLimit()
        calculateTotalUsage()
    }
}

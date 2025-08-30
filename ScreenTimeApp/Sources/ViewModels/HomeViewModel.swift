import Foundation
import Combine
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var screenTimeLimits: [ScreenTimeLimit] = []
    @Published var screenTimeUsage: [ScreenTimeUsage] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    // Total usage and limit
    @Published var totalMinutesUsed: Int = 0
    @Published var totalDailyLimit: Int = 0
    
    // Computed properties
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
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Calculate totals when data changes
        $screenTimeLimits
            .sink { [weak self] limits in
                self?.calculateTotalLimit()
            }
            .store(in: &cancellables)
        
        $screenTimeUsage
            .sink { [weak self] usage in
                self?.calculateTotalUsage()
            }
            .store(in: &cancellables)
    }
    
    func loadMockData() {
        screenTimeLimits = ScreenTimeLimit.mockApps
        screenTimeUsage = ScreenTimeUsage.mockUsage
    }
    
    func fetchData(userId: String) async {
        // In a real app, this would fetch data from Supabase
        // For now, we're using mock data
        DispatchQueue.main.async {
            self.isLoading = true
            self.screenTimeLimits = ScreenTimeLimit.mockApps
            self.screenTimeUsage = ScreenTimeUsage.mockUsage
            self.isLoading = false
        }
    }
    
    func updateLimit(for appId: String, minutes: Int) {
        if let index = screenTimeLimits.firstIndex(where: { $0.appId == appId }) {
            screenTimeLimits[index].dailyLimitMinutes = minutes
            screenTimeLimits[index].updatedAt = Date()
            
            // In a real app, save to Supabase here
        }
    }
    
    func addUsageTime(for appId: String, minutes: Int) {
        if let index = screenTimeUsage.firstIndex(where: { $0.appId == appId }) {
            screenTimeUsage[index].minutesUsed += minutes
            
            // In a real app, save to Supabase here
        } else if let app = screenTimeLimits.first(where: { $0.appId == appId }) {
            let newUsage = ScreenTimeUsage(
                appId: app.appId,
                appName: app.appName,
                minutesUsed: minutes,
                userId: app.userId
            )
            screenTimeUsage.append(newUsage)
            
            // In a real app, save to Supabase here
        }
    }
    
    func resetUsage() {
        for i in 0..<screenTimeUsage.count {
            screenTimeUsage[i].minutesUsed = 0
        }
        
        // In a real app, save to Supabase here
    }
    
    func calculateTotalLimit() {
        totalDailyLimit = screenTimeLimits.reduce(0) { $0 + $1.dailyLimitMinutes }
    }
    
    func calculateTotalUsage() {
        totalMinutesUsed = screenTimeUsage.reduce(0) { $0 + $1.minutesUsed }
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

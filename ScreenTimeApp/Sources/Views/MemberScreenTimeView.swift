import SwiftUI

struct MemberScreenTimeView: View {
    let member: GroupMember
    
    // In a real app, fetch per-user limits/usages from a service. For now, reuse mock data.
    private var limits: [ScreenTimeLimit] {
        ScreenTimeLimit.mockApps.map { base in
            var copy = base
            copy.userId = member.userId
            return copy
        }
    }
    
    private var usage: [ScreenTimeUsage] {
        ScreenTimeUsage.mockUsage.map { base in
            ScreenTimeUsage(appId: base.appId, appName: base.appName, minutesUsed: base.minutesUsed, date: base.date, userId: member.userId)
        }
    }
    
    var body: some View {
        List {
            Section(header: Text("Blocked Apps & Limits")) {
                ForEach(limits) { limit in
                    HStack(spacing: 12) {
                        Image(systemName: limit.iconName)
                            .frame(width: 28)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text(limit.appName)
                                .font(.headline)
                            Text("Daily limit: \(limit.dailyLimitMinutes) min")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if let used = usage.first(where: { $0.appId == limit.appId })?.minutesUsed {
                            Text("\(used) min used")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle(member.username)
    }
}



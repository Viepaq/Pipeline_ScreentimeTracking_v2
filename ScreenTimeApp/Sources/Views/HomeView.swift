import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var viewModel: HomeViewModel
    
    init() {
        // View model is injected via environment object
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Usage Summary Card
                    VStack(spacing: 15) {
                        Text("Today's Screen Time")
                            .font(.headline)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(viewModel.totalMinutesUsed) min")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(viewModel.isOverLimit ? .red : .primary)
                                
                                Text("of \(viewModel.totalDailyLimit) min limit")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat(min(viewModel.usagePercentage, 1.0)))
                                    .stroke(viewModel.isOverLimit ? Color.red : Color.blue, lineWidth: 10)
                                    .frame(width: 80, height: 80)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.linear, value: viewModel.usagePercentage)
                                
                                Text("\(Int(viewModel.usagePercentage * 100))%")
                                    .font(.caption)
                                    .bold()
                            }
                        }
                        
                        // Progress bar
                        ProgressView(value: min(viewModel.usagePercentage, 1.0))
                            .progressViewStyle(LinearProgressViewStyle(tint: viewModel.isOverLimit ? .red : .blue))
                            .animation(.linear, value: viewModel.usagePercentage)
                        
                        // Status message
                        Text(viewModel.isOverLimit ? "You've exceeded your daily limit!" : "You have \(viewModel.remainingMinutes) minutes remaining")
                            .font(.subheadline)
                            .foregroundColor(viewModel.isOverLimit ? .red : .green)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                    
                    // App List
                    VStack(alignment: .leading, spacing: 10) {
                        Text("App Limits")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.screenTimeLimits) { app in
                            AppLimitRow(
                                app: app,
                                usage: viewModel.screenTimeUsage.first(where: { $0.appId == app.appId }),
                                isBlocked: viewModel.isAppBlocked(appId: app.appId),
                                onLimitChange: { newLimit in
                                    viewModel.updateLimit(for: app.appId, minutes: newLimit)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Simulation Controls (for demo purposes)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Simulation Controls")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.screenTimeLimits) { app in
                            HStack {
                                Image(systemName: app.iconName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.blue)
                                
                                Text(app.appName)
                                
                                Spacer()
                                
                                Button("+ 5 min") {
                                    viewModel.addUsageTime(for: app.appId, minutes: 5)
                                }
                                .buttonStyle(.bordered)
                                .tint(.blue)
                                .font(.caption)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        Button("Reset All Usage") {
                            viewModel.resetUsage()
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Limits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Refresh data
                        if let userId = authService.currentUser?.id {
                            Task {
                                await viewModel.fetchData(userId: userId)
                            }
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

struct AppLimitRow: View {
    let app: ScreenTimeLimit
    let usage: ScreenTimeUsage?
    let isBlocked: Bool
    let onLimitChange: (Int) -> Void
    
    @State private var isEditing = false
    @State private var limitMinutes: Int
    
    init(app: ScreenTimeLimit, usage: ScreenTimeUsage?, isBlocked: Bool, onLimitChange: @escaping (Int) -> Void) {
        self.app = app
        self.usage = usage
        self.isBlocked = isBlocked
        self.onLimitChange = onLimitChange
        _limitMinutes = State(initialValue: app.dailyLimitMinutes)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: app.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)
                
                Text(app.appName)
                    .font(.headline)
                
                Spacer()
                
                if isBlocked {
                    Text("BLOCKED")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(4)
                }
            }
            
            // Usage progress
            HStack {
                Text("\(usage?.minutesUsed ?? 0) min")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Limit: \(app.dailyLimitMinutes) min")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: Double(usage?.minutesUsed ?? 0), total: Double(app.dailyLimitMinutes))
                .progressViewStyle(LinearProgressViewStyle(tint: isBlocked ? .red : .blue))
            
            // Edit limit
            if isEditing {
                HStack {
                    Slider(value: Binding(
                        get: { Double(limitMinutes) },
                        set: { limitMinutes = Int($0) }
                    ), in: 5...240, step: 5)
                    
                    Text("\(limitMinutes) min")
                        .frame(width: 60)
                }
                
                HStack {
                    Button("Cancel") {
                        limitMinutes = app.dailyLimitMinutes
                        isEditing = false
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button("Save") {
                        onLimitChange(limitMinutes)
                        isEditing = false
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                Button("Edit Limit") {
                    isEditing = true
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(MockAuthService())
            .environmentObject(MockHomeViewModel())
    }
}

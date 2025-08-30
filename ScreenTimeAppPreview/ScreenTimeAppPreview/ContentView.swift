import SwiftUI

// Tab enum for the custom tab bar
enum Tab {
    case groups, restrict, settings
}

struct ContentView: View {
    @EnvironmentObject var authService: MockAuthService

    var body: some View {
        SwiftUI.Group {
            if authService.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: Tab = .groups

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content
            VStack(spacing: 0) {
                switch selectedTab {
                case .groups:
                    GroupView()
                case .restrict:
                    HomeView()
                case .settings:
                    SettingsView()
                }

                // Add some bottom padding to account for the custom tab bar
                Spacer().frame(height: 90)
            }
            .edgesIgnoringSafeArea(.bottom)

            // Custom tab bar
            CustomTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

/// The custom tab bar view.
struct CustomTabBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack(spacing: 40) {
            TabBarItem(icon: "house.fill", tab: .groups, selectedTab: $selectedTab)
            TabBarItem(icon: "lock.fill", tab: .restrict, selectedTab: $selectedTab)
            TabBarItem(icon: "gearshape.fill", tab: .settings, selectedTab: $selectedTab)
        }
        .padding(15)
        .background(Color.white.opacity(0.1))
        .clipShape(Capsule())
        .shadow(color: .white.opacity(0.2), radius: 10, x: 0, y: 0)
    }
}

/// A single item within the custom tab bar.
struct TabBarItem: View {
    let icon: String
    let tab: Tab
    @Binding var selectedTab: Tab

    var isSelected: Bool {
        selectedTab == tab
    }

    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedTab = tab
            }
        }) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isSelected ? .black : .gray)
                .frame(width: 45, height: 45)
                .background(isSelected ? Color.white : Color.clear)
                .clipShape(Circle())
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var viewModel: MockHomeViewModel
    
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
                                
                                Text("\(Int(viewModel.usagePercentage * 100))%")
                                    .font(.caption)
                                    .bold()
                            }
                        }
                        
                        // Progress bar
                        ProgressView(value: min(viewModel.usagePercentage, 1.0))
                            .progressViewStyle(LinearProgressViewStyle(tint: viewModel.isOverLimit ? .red : .blue))
                        
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
                    
                    // Simulation Controls
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

struct GroupView: View {
    @EnvironmentObject var viewModel: MockGroupViewModel
    @EnvironmentObject var authService: MockAuthService
    @EnvironmentObject var responseManager: ResponseManager
    @State private var showRequestExtension = false
    @State private var showPendingRequests = false
    @State private var requestReason = ""
    @State private var selectedAppIndex = 0
    @State private var requestedMinutes = 15
    @State private var denyReason = ""

    // Computed property to get other members (excluding current user)
    private var otherMembers: [GroupMember] {
        guard let currentUserId = authService.currentUser?.id,
              let group = viewModel.currentGroup else {
            return []
        }
        return group.members.filter { $0.userId != currentUserId && $0.status == .active }
    }

    // Mock extension requests for the preview
    @State private var pendingRequests: [ExtensionRequest] = [
        ExtensionRequest(
            appId: "com.instagram.ios",
            appName: "Instagram",
            requestedMinutes: 30,
            reason: "Need to respond to important messages from my team about tomorrow's presentation.",
            userId: "user-2",
            groupId: "group-1"
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                if let group = viewModel.currentGroup {
                    // Group info card - now tappable
                    NavigationLink(destination: GroupDetailView(group: group)) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(group.name)
                                .font(.title2)
                                .fontWeight(.bold)

                            if let description = group.description {
                                Text(description)
                                    .foregroundColor(.secondary)
                            }

                            HStack {
                                Text("\(group.members.filter { $0.status == .active }.count) members")
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)

                                Text("Created \(group.createdAt.formatted(.dateTime.month().day().year()))")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.top)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Request Extension Button
                    Button(action: {
                        showRequestExtension = true
                    }) {
                        HStack {
                            Image(systemName: "clock.badge.plus")
                                .foregroundColor(.white)
                            Text("Request More Time")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                    
                    // Pending Requests Button (if there are any)
                    if !pendingRequests.isEmpty {
                        Button(action: {
                            showPendingRequests = true
                        }) {
                            HStack {
                                Text("Pending Requests")
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Text("\(pendingRequests.count)")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.orange)
                                    .clipShape(Circle())
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                    }
                    
                    // Members list
                    List {
                        Section(header: Text("Members")) {
                            ForEach(group.members.filter { $0.status == .active }) { member in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(member.username)
                                            .font(.headline)
                                        Text(member.email)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if member.userId == group.adminUserId {
                                        Text("Admin")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                        
                        if !group.members.filter({ $0.status == .pending }).isEmpty {
                            Section(header: Text("Pending Invitations")) {
                                ForEach(group.members.filter { $0.status == .pending }) { member in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(member.username)
                                                .font(.headline)
                                            Text(member.email)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Text("Pending")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                } else {
                    // No group yet
                    VStack(spacing: 20) {
                        Image(systemName: "person.3")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                            .padding(.top, 50)
                        
                        Text("You're not in a group yet")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Create a new accountability group or join an existing one via invitation")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Button(action: {
                            // Show create group sheet
                        }) {
                            Text("Create New Group")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                                .padding(.horizontal, 30)
                                .padding(.top, 20)
                        }
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Group")
            .sheet(isPresented: $showRequestExtension) {
                // Inline RequestTimeExtensionView
                NavigationView {
                    Form {
                        Section(header: Text("Select App")) {
                            let appLimits = [
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
                            
                            ForEach(Array(appLimits.enumerated()), id: \.element.id) { index, app in
                                Button(action: {
                                    selectedAppIndex = index
                                }) {
                                    HStack {
                                        Image(systemName: app.iconName)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(.blue)
                                        
                                        Text(app.appName)
                                        
                                        Spacer()
                                        
                                        if selectedAppIndex == index {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                                .foregroundColor(.primary)
                            }
                        }
                        
                        Section(header: Text("Request Extra Time")) {
                            Picker("Minutes", selection: $requestedMinutes) {
                                Text("15 minutes").tag(15)
                                Text("30 minutes").tag(30)
                                Text("60 minutes").tag(60)
                                Text("120 minutes").tag(120)
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        Section(header: Text("Reason (Required)")) {
                            TextEditor(text: $requestReason)
                                .frame(minHeight: 100)
                        }
                        
                        Section {
                            Button(action: {
                                // Submit request
                                // Create a mock request
                                let appLimits = [
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
                                
                                let selectedApp = appLimits[selectedAppIndex]
                                
                                // In a real app, this would be saved to Supabase
                                requestReason = ""
                                showRequestExtension = false
                            }) {
                                Text("Submit Request")
                                    .frame(maxWidth: .infinity)
                            }
                            .disabled(requestReason.isEmpty)
                        }
                    }
                    .navigationTitle("Request Extension")
                    .navigationBarItems(leading: Button("Cancel") {
                        showRequestExtension = false
                    })
                }
            }
            .sheet(isPresented: $showPendingRequests) {
                NavigationView {
                    List(pendingRequests) { request in
                        NavigationLink(destination: {
                            // Inline RequestResponseView
                            Form {
                                Section(header: Text("Request Details")) {
                                    HStack {
                                        Text("App")
                                        Spacer()
                                        Text(request.appName)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    HStack {
                                        Text("Requested Time")
                                        Spacer()
                                        Text("\(request.requestedMinutes) minutes")
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    HStack {
                                        Text("Reason")
                                        Spacer()
                                    }
                                    
                                    Text(request.reason)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                Section(header: Text("Your Response")) {

                                    HStack(spacing: 20) {
                                        // Approve Button
                                        Button(action: {
                                            responseManager.setDecision(for: request.id, approved: true)
                                        }) {
                                            ZStack {
                                                // Background gradient
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(responseManager.decisions[request.id] == true ?
                                                          LinearGradient(colors: [.green.opacity(0.8), .green.opacity(0.6)],
                                                                       startPoint: .top,
                                                                       endPoint: .bottom) :
                                                          LinearGradient(colors: [.gray.opacity(0.2), .gray.opacity(0.1)],
                                                                       startPoint: .top,
                                                                       endPoint: .bottom))
                                                    .frame(height: 80)
                                                    .shadow(color: responseManager.decisions[request.id] == true ? .green.opacity(0.3) : .clear,
                                                           radius: 8, x: 0, y: 4)

                                                HStack {
                                                    Spacer()

                                                    // Icon with glow effect
                                                    ZStack {
                                                        Circle()
                                                            .fill(.white.opacity(0.2))
                                                            .frame(width: 50, height: 50)

                                                        Image(systemName: responseManager.decisions[request.id] == true ?
                                                                     "checkmark.circle.fill" : "checkmark.circle")
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 28, height: 28)
                                                            .foregroundColor(.white)
                                                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                                                    }

                                                    Spacer()
                                                }
                                                .padding(.horizontal, 16)
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())

                                        // Deny Button
                                        Button(action: {
                                            responseManager.setDecision(for: request.id, approved: false)
                                        }) {
                                            ZStack {
                                                // Background gradient
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(responseManager.decisions[request.id] == false ?
                                                          LinearGradient(colors: [.red.opacity(0.8), .red.opacity(0.6)],
                                                                       startPoint: .top,
                                                                       endPoint: .bottom) :
                                                          LinearGradient(colors: [.gray.opacity(0.2), .gray.opacity(0.1)],
                                                                       startPoint: .top,
                                                                       endPoint: .bottom))
                                                    .frame(height: 80)
                                                    .shadow(color: responseManager.decisions[request.id] == false ? .red.opacity(0.3) : .clear,
                                                           radius: 8, x: 0, y: 4)

                                                HStack {
                                                    Spacer()

                                                    // Icon with glow effect
                                                    ZStack {
                                                        Circle()
                                                            .fill(.white.opacity(0.2))
                                                            .frame(width: 50, height: 50)

                                                        Image(systemName: responseManager.decisions[request.id] == false ?
                                                                     "xmark.circle.fill" : "xmark.circle")
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 28, height: 28)
                                                            .foregroundColor(.white)
                                                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                                                    }

                                                    Spacer()
                                                }
                                                .padding(.horizontal, 16)
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                    .padding(.horizontal, 4)
                                }
                                
                                if responseManager.decisions[request.id] == false {
                                    Section(header: HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.orange)
                                            .font(.system(size: 16))
                                        Text("Reason for Denial")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.orange)
                                        Spacer()
                                        Text("Required")
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundColor(.orange.opacity(0.7))
                                    }) {
                                        ZStack(alignment: .topLeading) {
                                            // Background
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(.systemGray6))
                                                .frame(minHeight: 120)

                                            // Placeholder text
                                            if (responseManager.denyReasons[request.id] ?? denyReason).isEmpty {
                                                Text("Please explain why you're denying this request...")
                                                    .foregroundColor(.gray.opacity(0.6))
                                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 12)
                                            }

                                            // Text editor
                                            TextEditor(text: Binding(
                                                get: { responseManager.denyReasons[request.id] ?? denyReason },
                                                set: {
                                                    denyReason = $0
                                                    responseManager.denyReasons[request.id] = $0
                                                }
                                            ))
                                            .font(.system(size: 16, weight: .regular, design: .rounded))
                                            .foregroundColor(.primary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .frame(minHeight: 120)
                                            .scrollContentBackground(.hidden)
                                            .background(Color.clear)
                                        }
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.orange.opacity(0.3), lineWidth: 1.5)
                                        )
                                    }
                                }
                                
                                Section {
                                    Button(action: {
                                        // Submit response
                                        if let index = pendingRequests.firstIndex(where: { $0.id == request.id }),
                                           let decision = responseManager.decisions[request.id] {
                                            // Save the response decision
                                            pendingRequests[index].responseDecision = decision

                                            if decision == false {
                                                // Save the denial reason
                                                let reason = responseManager.denyReasons[request.id] ?? denyReason
                                                pendingRequests[index].denyReason = reason
                                            }
                                            // In a real app, this would save to the database
                                        }
                                        // Reset state
                                        responseManager.decisions.removeValue(forKey: request.id)
                                        responseManager.denyReasons.removeValue(forKey: request.id)
                                        denyReason = ""
                                        showPendingRequests = false
                                    }) {
                                        Text("Submit Response")
                                            .frame(maxWidth: .infinity)
                                    }
                                    .disabled(responseManager.decisions[request.id] == nil ||
                                             (responseManager.decisions[request.id] == false &&
                                              (responseManager.denyReasons[request.id] ?? "").isEmpty))
                                }
                            }
                            .navigationTitle("Time Extension Request")
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(request.appName) • \(request.requestedMinutes) min")
                                    .font(.headline)
                                
                                Text(request.reason.prefix(50) + (request.reason.count > 50 ? "..." : ""))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("From: \(viewModel.currentGroup?.members.first(where: { $0.userId == request.userId })?.username ?? "Unknown")")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .navigationTitle("Pending Requests")
                }
            }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var authService: MockAuthService
    @State private var showingProfilePicturePicker = false
    @State private var selectedProfilePicture: String?
    @State private var showForgotPassword = false
    @State private var resetEmail = ""
    @State private var resetMessage = ""

    var body: some View {
        NavigationView {
            List {
                // Profile Section
                Section {
                    HStack(spacing: 16) {
                        if let user = authService.currentUser {
                            ProfilePictureView(user: user, size: 60)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(authService.currentUser?.displayName ?? "User")
                                .font(.headline)
                                .foregroundColor(.primary)

                            Text(authService.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Button(action: {
                            showingProfilePicturePicker = true
                        }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section(header: Text("Account")) {
                    HStack {
                        Text("Username")
                        Spacer()
                        Text(authService.currentUser?.username ?? "")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Email")
                        Spacer()
                        Text(authService.currentUser?.email ?? "")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button("Reset Password") {
                        Task {
                            // Reset password for current user
                            if let email = authService.currentUser?.email {
                                let success = await authService.resetPassword(email: email)
                                if success {
                                    // Show success message (in a real app, user would get an email)
                                    print("Password reset email sent to \(email)")
                                }
                            }
                        }
                    }
                    .foregroundColor(.blue)
                }

                Section {
                    Button("Sign Out") {
                        Task {
                            await authService.signOut()
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingProfilePicturePicker) {
                ProfilePicturePicker(selectedImage: Binding(
                    get: { selectedProfilePicture },
                    set: { newValue in
                        selectedProfilePicture = newValue
                        // Update the user's profile picture
                        if var user = authService.currentUser {
                            user.profilePictureUrl = newValue
                            authService.currentUser = user
                        }
                    }
                ))
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showForgotPassword) {
                VStack(spacing: 20) {
                    Text("Reset Password")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)

                    Text("Enter your email address and we'll send you a link to reset your password")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    TextField("Email", text: $resetEmail)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)

                    if !resetMessage.isEmpty {
                        Text(resetMessage)
                            .foregroundColor(resetMessage.contains("sent") ? .green : .red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button(action: {
                        Task {
                            let success = await authService.resetPassword(email: resetEmail)
                            if success {
                                resetMessage = "Password reset email sent to \(resetEmail)"
                            } else {
                                resetMessage = "Email not found. Please check and try again."
                            }
                        }
                    }) {
                        Text("Send Reset Email")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .disabled(resetEmail.isEmpty)
                    .padding(.horizontal)

                    Button("Cancel") {
                        showForgotPassword = false
                        resetEmail = ""
                        resetMessage = ""
                    }
                    .foregroundColor(.gray)
                    .padding(.bottom)

                    Spacer()
                }
                .padding()
                .presentationDetents([.medium])
            }
        }
    }
}

struct LoginView: View {
    @EnvironmentObject var authService: MockAuthService

    @State private var email = "test@example.com"
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var isCreatingPassword = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Logo and Title
                VStack(spacing: 10) {
                    Image(systemName: "timer")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                    
                    Text("ScreenTime Accountability")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Stay focused with friends")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Login Form
                VStack(spacing: 15) {
                    if authService.requiresPasswordCreation {
                        // Password Creation Form
                        Text("Create Password")
                            .font(.headline)
                            .padding(.bottom, 10)

                        Text("Please create a password for your account")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)

                        SecureField("New Password", text: $password)
                            .textContentType(.newPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)

                        SecureField("Confirm Password", text: $confirmPassword)
                            .textContentType(.newPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)

                        if let error = authService.authError {
                            Text(error.localizedDescription)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }

                        Button(action: {
                            Task {
                                if password.isEmpty {
                                    authService.authError = NSError(domain: "AuthError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Password cannot be empty"])
                                    return
                                }
                                if password != confirmPassword {
                                    authService.authError = NSError(domain: "AuthError", code: 5, userInfo: [NSLocalizedDescriptionKey: "Passwords do not match"])
                                    return
                                }
                                isLoading = true
                                await authService.createPassword(email: email, password: password)
                                isLoading = false
                            }
                        }) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            } else {
                                Text("Create Password")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                        }
                        .disabled(password.isEmpty || confirmPassword.isEmpty || isLoading)

                    } else {
                        // Regular Sign In Form
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)

                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)

                        if let error = authService.authError {
                            Text(error.localizedDescription)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }

                        Button(action: {
                            Task {
                                isLoading = true
                                await authService.signIn(email: email, password: password)
                                isLoading = false
                            }
                        }) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            } else {
                                Text("Sign In")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                        }
                        .disabled(email.isEmpty || password.isEmpty || isLoading)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Sign Up Button
                VStack {
                    Button("Don't have an account? Sign Up") {
                        // Show sign up sheet
                    }
                    .foregroundColor(.blue)
                }
                .padding(.bottom, 30)
            }
            .navigationBarHidden(true)
        }
    }
}

// Group Detail View - Shows when group card is tapped
struct GroupDetailView: View {
    let group: Group
    @EnvironmentObject var authService: MockAuthService

    @State private var showAddMemberSheet = false
    @State private var searchUsername = ""
    @State private var searchResults: [User] = []
    @State private var isSearching = false

    private var otherMembers: [GroupMember] {
        guard let currentUserId = authService.currentUser?.id else {
            return []
        }
        return group.members.filter { $0.userId != currentUserId && $0.status == .active }
    }

    private var isCurrentUserAdmin: Bool {
        guard let currentUserId = authService.currentUser?.id else {
            return false
        }
        return group.adminUserId == currentUserId
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Group Header
                VStack(alignment: .leading, spacing: 12) {
                    Text(group.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    if let description = group.description {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Created \(group.createdAt.formatted(.dateTime.month().day().year()))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("\(group.members.filter { $0.status == .active }.count) members")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)

                // Group Members Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Group Members")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Spacer()

                        if isCurrentUserAdmin {
                            Button(action: {
                                showAddMemberSheet = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                    .padding(8)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.horizontal)

                    if !otherMembers.isEmpty {

                        VStack(spacing: 12) {
                            ForEach(otherMembers) { member in
                                HStack(spacing: 16) {
                                    GroupMemberProfileView(member: member, size: 50)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(member.displayName)
                                            .font(.headline)

                                        Text(member.email)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title3)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                    }
                }

                // Alternative view with overlapping profile pictures
                VStack(alignment: .leading, spacing: 16) {
                    Text("Quick View")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)

                    HStack {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: -8) {
                                ForEach(otherMembers) { member in
                                    GroupMemberProfileView(member: member, size: 40)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Spacer()
            }
            .padding(.top)
        }
        .navigationTitle("Group Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddMemberSheet) {
            AddMemberSheet(
                searchUsername: $searchUsername,
                searchResults: $searchResults,
                isSearching: $isSearching,
                onSearch: performSearch,
                onInvite: inviteUser
            )
        }
    }

    private func performSearch() {
        isSearching = true

        // Mock search functionality
        // In a real app, this would call an API
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if searchUsername.lowercased() == "johndoe" {
                searchResults = [
                    User(id: "user-2", email: "johndoe@example.com", userMetadata: ["username": "johndoe"])
                ]
            } else if searchUsername.lowercased() == "sarahwilson" {
                searchResults = [
                    User(id: "user-4", email: "sarahwilson@example.com", userMetadata: ["username": "sarahwilson"])
                ]
            } else {
                searchResults = []
            }
            isSearching = false
        }
    }

    private func inviteUser(_ user: User) {
        // Mock invitation functionality
        // In a real app, this would send an invitation
        print("Invited user: \(user.username ?? "Unknown") to group: \(group.name)")

        // Close the sheet
        showAddMemberSheet = false
        searchUsername = ""
        searchResults = []
    }
}

// Add Member Sheet Component
struct AddMemberSheet: View {
    @Binding var searchUsername: String
    @Binding var searchResults: [User]
    @Binding var isSearching: Bool

    let onSearch: () -> Void
    let onInvite: (User) -> Void

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Search Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Search for Users")
                        .font(.title2)
                        .fontWeight(.semibold)

                    HStack {
                        TextField("Enter username", text: $searchUsername)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)

                        Button(action: onSearch) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                        .disabled(searchUsername.isEmpty || isSearching)
                    }
                }
                .padding(.horizontal)

                // Search Results
                if isSearching {
                    ProgressView("Searching...")
                        .padding()
                } else if !searchResults.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Search Results")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(searchResults) { user in
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.2))
                                        .frame(width: 50, height: 50)

                                    Text(user.profileInitial)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(user.displayName)
                                        .font(.headline)

                                    Text(user.email ?? "")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Button(action: {
                                    onInvite(user)
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Text("Invite")
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(Color.blue)
                                        .cornerRadius(20)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                } else if !searchUsername.isEmpty && !isSearching {
                    VStack {
                        Image(systemName: "person.slash")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                            .padding()

                        Text("No users found")
                            .font(.headline)
                            .foregroundColor(.gray)

                        Text("Try searching with a different username")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 50)
                }

                Spacer()
            }
            .navigationTitle("Add Member")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .padding(.top)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MockAuthService())
            .environmentObject(MockHomeViewModel())
            .environmentObject(MockGroupViewModel())
            .environmentObject(MockNotificationsManager())
    }
}

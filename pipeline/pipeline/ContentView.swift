import SwiftUI

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
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Limits", systemImage: "timer")
                }
            
            GroupView()
                .tabItem {
                    Label("Group", systemImage: "person.3")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
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
    
    var body: some View {
        NavigationView {
            VStack {
                if let group = viewModel.currentGroup {
                    // Group info card
                    VStack(alignment: .leading, spacing: 10) {
                        Text(group.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if let description = group.description {
                            Text(description)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        HStack {
                            Label("\(group.members.filter { $0.status == .active }.count) members", systemImage: "person.2")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                            
                            Spacer()
                            
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
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var authService: MockAuthService
    
    var body: some View {
        NavigationView {
            List {
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
                    Button("Sign Out") {
                        Task {
                            await authService.signOut()
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct LoginView: View {
    @EnvironmentObject var authService: MockAuthService
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MockAuthService())
            .environmentObject(MockHomeViewModel())
            .environmentObject(MockGroupViewModel())
            .environmentObject(MockNotificationsManager())
    }
}


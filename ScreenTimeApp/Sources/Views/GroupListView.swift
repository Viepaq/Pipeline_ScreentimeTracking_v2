import SwiftUI

struct GroupListView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var viewModel: GroupViewModel
    @State private var showCreateGroup = false
    @State private var showInvitations = false
    
    init() {
        // View model is injected via environment object
    }
    
    var body: some View {
        NavigationView {
            SwiftUI.Group {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let group = viewModel.currentGroup {
                    // User has a group
                    VStack {
                        // Group info card
                        GroupInfoCard(group: group)
                        
                        // Members list with navigation to detail
                        NavigationLink(destination: GroupDetailView(group: group)) {
                            HStack {
                                Text("View Members (\(group.members.filter { $0.status == .active }.count))")
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                        
                        // Pending invitations badge
                        if !viewModel.pendingInvitations.isEmpty {
                            Button(action: {
                                showInvitations = true
                            }) {
                                HStack {
                                    Text("Pending Invitations")
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                    
                                    Text("\(viewModel.pendingInvitations.count)")
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue)
                                        .clipShape(Circle())
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer()
                        
                        // Leave group button (only if not admin)
                        if let userId = authService.currentUser?.id,
                           !viewModel.isUserAdmin(userId: userId) {
                            Button("Leave Group") {
                                Task {
                                    await viewModel.leaveGroup()
                                }
                            }
                            .foregroundColor(.red)
                            .padding()
                        }
                    }
                    .navigationTitle("My Group")
                    .sheet(isPresented: $showInvitations) {
                        PendingInvitationsView(invitations: viewModel.pendingInvitations)
                    }
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
                            showCreateGroup = true
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
                        
                        // Check for pending invitations
                        if let userId = authService.currentUser?.id,
                           viewModel.hasPendingInvitation(userId: userId) {
                            Button(action: {
                                showInvitations = true
                            }) {
                                Text("View Pending Invitations")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                                    .padding(.top, 10)
                            }
                        }
                        
                        Spacer()
                    }
                    .navigationTitle("Groups")
                    .sheet(isPresented: $showCreateGroup) {
                        CreateGroupView()
                    }
                    .sheet(isPresented: $showInvitations) {
                        PendingInvitationsView(invitations: viewModel.pendingInvitations)
                    }
                }
            }
        .onAppear {
            if let userId = authService.currentUser?.id {
                Task {
                    await viewModel.fetchUserGroup(userId: userId)
                }
            }
        }
        }
    }
}

struct GroupInfoCard: View {
    let group: Group
    
    var body: some View {
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
    }
}

struct CreateGroupView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var viewModel: GroupViewModel
    
    @State private var groupName = ""
    @State private var groupDescription = ""
    @State private var isLoading = false
    
    init() {
        // View model is injected via environment object
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Group Information")) {
                    TextField("Group Name", text: $groupName)
                    
                    TextField("Description (optional)", text: $groupDescription)
                        .frame(height: 100, alignment: .top)
                        .multilineTextAlignment(.leading)
                }
                
                Section(footer: Text("You'll be able to invite members after creating the group")) {
                    Button(action: {
                        if let userId = authService.currentUser?.id {
                            Task {
                                isLoading = true
                                await viewModel.createGroup(
                                    name: groupName,
                                    description: groupDescription.isEmpty ? nil : groupDescription,
                                    userId: userId
                                )
                                isLoading = false
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Create Group")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(groupName.isEmpty || isLoading)
                }
            }
            .navigationTitle("Create Group")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct PendingInvitationsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var viewModel: GroupViewModel
    
    let invitations: [GroupMember]
    
    init(invitations: [GroupMember]) {
        self.invitations = invitations
        // View model is injected via environment object
    }
    
    var body: some View {
        NavigationView {
            List {
                if invitations.isEmpty {
                    Text("No pending invitations")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(invitations) { invitation in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(invitation.username)
                                .font(.headline)
                            
                            Text(invitation.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Button("Accept") {
                                    Task {
                                        await viewModel.acceptInvitation(
                                            groupId: invitation.groupId,
                                            userId: invitation.userId
                                        )
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.green)
                                
                                Button("Decline") {
                                    Task {
                                        await viewModel.declineInvitation(
                                            groupId: invitation.groupId,
                                            userId: invitation.userId
                                        )
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                                .buttonStyle(.bordered)
                                .tint(.red)
                            }
                            .padding(.top, 5)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("Invitations")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct GroupListView_Previews: PreviewProvider {
    static var previews: some View {
        GroupListView()
            .environmentObject(MockAuthService())
            .environmentObject(MockGroupViewModel())
    }
}

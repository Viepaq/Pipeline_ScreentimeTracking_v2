import SwiftUI

struct GroupDetailView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var viewModel: GroupViewModel
    
    let group: Group
    @State private var showInviteSheet = false
    @State private var searchText = ""
    
    init(group: Group) {
        self.group = group
        // View model is injected via environment object
    }
    
    var body: some View {
        List {
            
            Section(header: Text("Pending Invitations")) {
                if viewModel.pendingInvitations.isEmpty {
                    Text("No pending invitations")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.pendingInvitations) { invitation in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(invitation.username)
                                    .font(.headline)
                                
                                Text(invitation.email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("Invited \(invitation.invitedAt.formatted(.dateTime.month().day()))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Cancel invitation (only for admin)
                            if let userId = authService.currentUser?.id,
                               viewModel.isUserAdmin(userId: userId) {
                                Button(action: {
                                    Task {
                                        await viewModel.removeMember(memberId: invitation.id)
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            
            // Invite button (only for admin)
            if let userId = authService.currentUser?.id,
               viewModel.isUserAdmin(userId: userId) {
                Section {
                    Button(action: {
                        showInviteSheet = true
                    }) {
                        Label("Invite New Member", systemImage: "person.badge.plus")
                    }
                }
            }
        }
        .navigationTitle("Group Details")
        .sheet(isPresented: $showInviteSheet) {
            InviteMemberView()
                .environmentObject(viewModel)
        }
        .onAppear {
            // Initialize the view model with the current group
            viewModel.currentGroup = group
            viewModel.pendingInvitations = group.members.filter { $0.status == .pending }
        }
    }
}

struct InviteMemberView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: GroupViewModel
    
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var invitedUsers: [String] = []
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search by username", text: $searchText)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onChange(of: searchText) { newValue in
                            if !newValue.isEmpty && newValue.count >= 3 {
                                Task {
                                    await viewModel.searchUsers(username: newValue)
                                }
                            }
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.top)
                
                // Results
                if viewModel.isSearching {
                    ProgressView()
                        .padding()
                } else if searchText.isEmpty {
                    Text("Enter a username to search")
                        .foregroundColor(.secondary)
                        .padding(.top, 50)
                } else if viewModel.searchResults.isEmpty {
                    Text("No users found")
                        .foregroundColor(.secondary)
                        .padding(.top, 50)
                } else {
                    List {
                        ForEach(viewModel.searchResults, id: \.id) { user in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(user.username ?? "Unknown")
                                        .font(.headline)
                                    
                                    if let email = user.email {
                                        Text(email)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                if invitedUsers.contains(user.id) {
                                    Text("Invited")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.green.opacity(0.2))
                                        .cornerRadius(4)
                                } else {
                                    Button("Invite") {
                                        Task {
                                            await viewModel.inviteUser(user: user)
                                            invitedUsers.append(user.id)
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.blue)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Invite Members")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct GroupDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GroupDetailView(group: Group.mockGroup)
                .environmentObject(MockAuthService())
                .environmentObject(MockGroupViewModel())
        }
    }
}

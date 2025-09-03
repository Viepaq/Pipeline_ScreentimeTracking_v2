import SwiftUI

struct GroupSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var viewModel: GroupViewModel

    @State private var editableName: String = ""
    @State private var editableDescription: String = ""
    @State private var isSaving: Bool = false
    @State private var isDeleting: Bool = false

    var isAdmin: Bool {
        if let userId = authService.currentUser?.id {
            return viewModel.isUserAdmin(userId: userId)
        }
        return false
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Group Info")) {
                    TextField("Group Name", text: $editableName)
                    TextField("Description (optional)", text: $editableDescription)
                        .frame(height: 100, alignment: .top)
                        .multilineTextAlignment(.leading)
                }

                if isAdmin {
                    Section(header: Text("Members"), footer: Text("Only the admin can remove members.")) {
                        if let members = viewModel.currentGroup?.members {
                            List {
                                ForEach(members.filter { $0.status == .active && $0.userId != viewModel.currentGroup?.adminUserId }) { member in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(member.username)
                                                .font(.headline)
                                            Text(member.email)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Button(role: .destructive) {
                                            Task { await viewModel.removeMember(memberId: member.id) }
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                    }
                                }
                            }
                            .frame(minHeight: 44)
                        }
                    }

                    Section(footer: Text("This action permanently deletes the focus group for all members.")) {
                        Button(role: .destructive) {
                            Task {
                                isDeleting = true
                                await viewModel.deleteGroup()
                                isDeleting = false
                                presentationMode.wrappedValue.dismiss()
                            }
                        } label: {
                            if isDeleting {
                                ProgressView().frame(maxWidth: .infinity)
                            } else {
                                Text("Delete Focus Group").frame(maxWidth: .infinity)
                            }
                        }
                    }
                } else {
                    Section(footer: Text("Leave the focus group. You can join or create another later.")) {
                        Button(role: .destructive) {
                            Task {
                                await viewModel.leaveGroup()
                                presentationMode.wrappedValue.dismiss()
                            }
                        } label: {
                            Text("Leave Focus Group").frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .navigationTitle("Group Settings")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                Task {
                    isSaving = true
                    await viewModel.updateGroup(name: editableName, description: editableDescription.isEmpty ? nil : editableDescription)
                    isSaving = false
                    presentationMode.wrappedValue.dismiss()
                }
            }.disabled(editableName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving))
            .onAppear {
                editableName = viewModel.currentGroup?.name ?? ""
                editableDescription = viewModel.currentGroup?.description ?? ""
            }
        }
    }
}

struct GroupSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GroupSettingsView()
            .environmentObject(MockAuthService())
            .environmentObject(MockGroupViewModel())
    }
}



import SwiftUI

struct GroupSettingsView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var viewModel: GroupViewModel
    
    let group: Group
    @State private var name: String
    @State private var description: String
    @State private var isSaving = false
    
    init(group: Group) {
        self.group = group
        _name = State(initialValue: group.name)
        _description = State(initialValue: group.description ?? "")
    }
    
    var body: some View {
        Form {
            Section(header: Text("Group Info")) {
                TextField("Name", text: $name)
                TextField("Description", text: $description)
            }
            
            Section(footer: Text("Only group admins can edit settings")) {
                Button(action: save) {
                    if isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(!canEdit || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
            }

            // Leave group (non-admins only)
            if let userId = authService.currentUser?.id, !viewModel.isUserAdmin(userId: userId) {
                Section {
                    Button(role: .destructive) {
                        Task { await viewModel.leaveGroup() }
                    } label: {
                        Text("Leave Group")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .navigationTitle("Group Settings")
    }
    
    private var canEdit: Bool {
        guard let userId = authService.currentUser?.id else { return false }
        return viewModel.isUserAdmin(userId: userId)
    }
    
    private func save() {
        guard canEdit else { return }
        isSaving = true
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.updateGroup(name: trimmed, description: description.isEmpty ? nil : description)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isSaving = false
        }
    }
}

struct GroupSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GroupSettingsView(group: Group.mockGroup)
                .environmentObject(MockAuthService())
                .environmentObject(MockGroupViewModel())
        }
    }
}



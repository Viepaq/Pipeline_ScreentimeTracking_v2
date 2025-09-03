import SwiftUI

struct GroupSettingsView: View {
    @EnvironmentObject var authService: MockAuthService
    @EnvironmentObject var viewModel: MockGroupViewModel
    
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
            
            Section(footer: Text("Only admins can edit")) {
                Button(action: save) {
                    if isSaving {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Save").frame(maxWidth: .infinity)
                    }
                }
                .disabled(!canEdit || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
            }
        }
        .navigationTitle("Group Settings")
    }
    
    private var canEdit: Bool {
        guard let uid = authService.currentUser?.id else { return false }
        return group.adminUserId == uid
    }
    
    private func save() {
        guard canEdit else { return }
        isSaving = true
        if var current = viewModel.currentGroup, current.id == group.id {
            current.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            current.description = description.isEmpty ? nil : description
            current.updatedAt = Date()
            viewModel.currentGroup = current
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { isSaving = false }
    }
}



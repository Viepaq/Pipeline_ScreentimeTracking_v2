import SwiftUI

struct RequestTimeExtensionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authService: MockAuthService
    @EnvironmentObject var homeViewModel: MockHomeViewModel
    @EnvironmentObject var groupViewModel: MockGroupViewModel
    
    @State private var selectedApp: ScreenTimeLimit?
    @State private var requestedMinutes = 15
    @State private var reason = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    
    let minutesOptions = [5, 15, 30, 60, 120, 240, 420] // 5 min to 7 hours
    
    var body: some View {
        NavigationView {
            Form {
                if showSuccess {
                    SuccessView {
                        presentationMode.wrappedValue.dismiss()
                    }
                } else {
                    Section(header: Text("Select App")) {
                        ForEach(homeViewModel.screenTimeLimits) { app in
                            Button(action: {
                                selectedApp = app
                            }) {
                                HStack {
                                    Image(systemName: app.iconName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.blue)
                                    
                                    Text(app.appName)
                                    
                                    Spacer()
                                    
                                    if selectedApp?.id == app.id {
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
                            ForEach(minutesOptions, id: \.self) { minutes in
                                if minutes < 60 {
                                    Text("\(minutes) minutes")
                                } else {
                                    Text("\(minutes / 60) hour\(minutes / 60 > 1 ? "s" : "")")
                                }
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    Section(header: Text("Reason (Required)")) {
                        TextEditor(text: $reason)
                            .frame(minHeight: 100)
                    }
                    
                    Section(footer: Text("Your request will be sent to all members of your accountability group. You'll receive a notification when it's approved or denied.")) {
                        Button(action: {
                            submitRequest()
                        }) {
                            if isSubmitting {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Submit Request")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .disabled(selectedApp == nil || reason.isEmpty || isSubmitting)
                    }
                }
            }
            .navigationTitle("Request Extension")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func submitRequest() {
        guard let app = selectedApp, !reason.isEmpty else { return }
        
        isSubmitting = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Create a mock extension request
            let request = ExtensionRequest(
                appId: app.appId,
                appName: app.appName,
                requestedMinutes: requestedMinutes,
                reason: reason,
                userId: authService.currentUser?.id ?? "user-1",
                groupId: groupViewModel.currentGroup?.id ?? "group-1"
            )
            
            // In a real app, this would be saved to Supabase
            
            isSubmitting = false
            showSuccess = true
        }
    }
}

struct SuccessView: View {
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.green)
            
            Text("Request Submitted!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Your time extension request has been sent to your accountability group. You'll be notified when they respond.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Done") {
                onDismiss()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 20)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

struct RequestResponseView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let request: ExtensionRequest
    @State private var response: Bool?
    @State private var comment = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    
    var body: some View {
        Form {
            if showSuccess {
                SuccessResponseView()
            } else {
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
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            response = true
                        }) {
                            VStack {
                                Image(systemName: response == true ? "checkmark.circle.fill" : "checkmark.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(response == true ? .green : .gray)
                                
                                Text("Approve")
                                    .foregroundColor(response == true ? .green : .gray)
                            }
                            .padding()
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            response = false
                        }) {
                            VStack {
                                Image(systemName: response == false ? "xmark.circle.fill" : "xmark.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(response == false ? .red : .gray)
                                
                                Text("Deny")
                                    .foregroundColor(response == false ? .red : .gray)
                            }
                            .padding()
                        }
                        
                        Spacer()
                    }
                    
                    if response == false {
                        Text("Please provide a reason for denying:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $comment)
                            .frame(minHeight: 100)
                    }
                }
                
                Section {
                    Button(action: {
                        submitResponse()
                    }) {
                        if isSubmitting {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Submit Response")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(response == nil || (response == false && comment.isEmpty) || isSubmitting)
                }
            }
        }
        .navigationTitle("Time Extension Request")
    }
    
    private func submitResponse() {
        guard let userResponse = response else { return }
        
        isSubmitting = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // In a real app, this would create an extension response in Supabase
            // and update the request status if threshold is met
            
            isSubmitting = false
            showSuccess = true
        }
    }
}

struct SuccessResponseView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.green)
            
            Text("Response Submitted!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Your response has been recorded. The requester will be notified when enough group members have responded.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

// Extension Request model for preview app
struct ExtensionRequest: Identifiable {
    var id: String = UUID().uuidString
    var appId: String
    var appName: String
    var requestedMinutes: Int
    var reason: String
    var userId: String
    var groupId: String
    var status: ExtensionStatus = .pending
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var responses: [ExtensionResponse] = []
    
    // Mock data for previews
    static let mockRequest = ExtensionRequest(
        appId: "com.instagram.ios",
        appName: "Instagram",
        requestedMinutes: 30,
        reason: "Need to respond to important messages from my team about tomorrow's presentation.",
        userId: "user-2",
        groupId: "group-1"
    )
}

struct ExtensionResponse: Identifiable {
    var id: String = UUID().uuidString
    var requestId: String
    var userId: String
    var approved: Bool
    var comment: String?
    var createdAt: Date = Date()
}

enum ExtensionStatus: String {
    case pending
    case approved
    case denied
}

# ScreenTime Accountability App

An iOS app that helps users stick to their self-imposed screen-time limits by leveraging social accountability through friend groups.

## Features

- **User Authentication**: Email/password sign-up, login, email verification
- **Screen-Time Monitoring**: Set daily limits for specific apps and track usage
- **Accountability Groups**: Create or join a group with friends (2-5 people)
- **Time Extension Requests**: Request extra minutes with approval from group members
- **Notifications**: In-app notifications and push alerts for extension requests
- **Daily Reset**: Automatic reset of counters at midnight

## Technical Details

- **Platform**: iOS 16+
- **Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Backend**: Prepared for Supabase integration (currently using mock data)
- **Notifications**: Ready for APNs integration

## Getting Started

1. Clone the repository
2. Open the project in Xcode
3. Build and run on an iOS 16+ simulator or device

## Project Structure

- `ScreenTimeApp/Sources/Models`: Data models
- `ScreenTimeApp/Sources/ViewModels`: View models for business logic
- `ScreenTimeApp/Sources/Views`: SwiftUI views
- `ScreenTimeApp/Sources/Services`: Service classes for authentication, etc.

## Screenshots

(Coming soon)

## License

This project is licensed under the MIT License - see the LICENSE file for details.
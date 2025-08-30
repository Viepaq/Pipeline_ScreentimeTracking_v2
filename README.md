# ScreenTime Accountability App

An iOS app that helps users stick to their self-imposed screen-time limits by enlisting their friends as accountability partners.

## Features

- **User Authentication**: Email/password sign-up, login, email verification
- **Screen-Time Mock**: Interface to pick apps, set daily limits, and track usage
- **Accountability Groups**: Create or join one group (2-5 people)
- **Time Extension Requests**: Request extra minutes with approval from group members
- **Notifications**: In-app feed and push notifications
- **Daily Reset**: Automatic reset of counters at midnight

## Tech Stack

- **Frontend**: SwiftUI (iOS 16+)
- **Architecture**: MVVM (Model-View-ViewModel)
- **Mock Services**: Local Swift models to simulate backend functionality

## Getting Started

### Prerequisites

- Xcode 14 or later
- iOS 16+ Simulator or device

### Installation

1. Clone the repository
2. Open the project in Xcode
3. Build and run on a simulator or device

## Project Structure

- `ScreenTimeApp/Sources/Models/`: Data models
- `ScreenTimeApp/Sources/ViewModels/`: View models for business logic
- `ScreenTimeApp/Sources/Views/`: SwiftUI views
- `ScreenTimeApp/Sources/Services/`: Mock services

## Running the App

Use the provided script to build and run on the iPhone 16 Pro simulator:

```bash
./run_on_iphone16pro.sh
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
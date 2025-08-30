# APNs Configuration Guide

This document outlines the steps to configure Apple Push Notification service (APNs) for the ScreenTime Accountability App.

## Prerequisites

- An Apple Developer account with an active membership
- Access to the Apple Developer Portal
- Xcode 14 or later installed
- Access to your Supabase project dashboard

## Step 1: Create an App ID

1. Log in to the [Apple Developer Portal](https://developer.apple.com/account/)
2. Navigate to "Certificates, IDs & Profiles"
3. Select "Identifiers" from the sidebar
4. Click the "+" button to register a new identifier
5. Select "App IDs" and click "Continue"
6. Fill in the following details:
   - Description: "ScreenTime Accountability App"
   - Bundle ID: com.yourcompany.screentimeapp (use your actual bundle ID)
7. Scroll down to "Capabilities" and enable "Push Notifications"
8. Click "Continue" and then "Register"

## Step 2: Create an APNs Authentication Key

1. In the Apple Developer Portal, navigate to "Certificates, IDs & Profiles"
2. Select "Keys" from the sidebar
3. Click the "+" button to register a new key
4. Enter a name for your key (e.g., "ScreenTime APNs Key")
5. Check the "Apple Push Notifications service (APNs)" checkbox
6. Click "Continue" and then "Register"
7. Download the key file (.p8) - **Important**: You can only download this file once!
8. Note the Key ID displayed on the page

## Step 3: Configure APNs in Supabase

1. Log in to your [Supabase Dashboard](https://app.supabase.io/)
2. Select your project
3. Navigate to "Settings" > "API"
4. Scroll down to the "Push Notifications" section
5. Click "Configure Apple Push Notifications"
6. Upload your .p8 key file
7. Enter the following details:
   - Key ID: The ID from Step 2
   - Team ID: Your Apple Developer Team ID (found in your Apple Developer account)
   - Bundle ID: The bundle ID from Step 1
8. Click "Save"

## Step 4: Configure Your App for Push Notifications

1. Open your Xcode project
2. Select your app target
3. Go to the "Signing & Capabilities" tab
4. Click "+ Capability" and add "Push Notifications"
5. Also add "Background Modes" and check "Remote notifications"

## Step 5: Update Your Code

Make sure your app registers for remote notifications:

```swift
// In your AppDelegate or SwiftUI App's init()
UIApplication.shared.registerForRemoteNotifications()
```

Handle the device token:

```swift
// In your AppDelegate
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    
    // Send this token to your backend
    NotificationsManager.shared.registerDeviceToken(deviceToken)
}
```

## Testing Push Notifications

1. Build and run your app on a physical device
2. Make sure your app successfully registers for push notifications
3. Use the Supabase dashboard to send a test notification
4. Verify that your device receives the notification

## Troubleshooting

- Make sure your app is built with the correct provisioning profile
- Verify that the bundle ID in your app matches the one in the Apple Developer Portal
- Check that your device has an internet connection
- Look for any errors in the Xcode console when registering for push notifications

## Production vs. Development

APNs has separate environments for development and production:

- Development: Used when running from Xcode
- Production: Used when installed from TestFlight or App Store

Make sure your backend is configured to use the correct environment based on how your app is distributed.

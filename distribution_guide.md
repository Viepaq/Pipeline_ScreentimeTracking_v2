# iOS App Distribution Guide

This document outlines the steps to archive and distribute the ScreenTime Accountability App via TestFlight and the App Store.

## Prerequisites

- Xcode 14 or later installed
- An Apple Developer account with an active membership
- App Store Connect access
- Proper signing certificates and provisioning profiles
- A completed and tested app

## Step 1: Configure App Store Connect

1. Log in to [App Store Connect](https://appstoreconnect.apple.com/)
2. Navigate to "Apps" and click the "+" button to register a new app
3. Fill in the required information:
   - Platform: iOS
   - App Name: ScreenTime Accountability
   - Bundle ID: Select the bundle ID you created in the Apple Developer Portal
   - SKU: A unique identifier for your app (e.g., "screentimeapp2023")
   - Primary Language: English (or your preferred language)
4. Click "Create"

## Step 2: Prepare Your App for Distribution

1. Open your Xcode project
2. Select your app target
3. Go to the "General" tab
4. Ensure your version and build numbers are set correctly
5. Go to the "Signing & Capabilities" tab
6. Make sure "Automatically manage signing" is checked
7. Select your team and distribution certificate

## Step 3: Archive Your App

1. In Xcode, select "Any iOS Device" as the build destination
2. Select "Product" > "Archive" from the menu
3. Wait for the archiving process to complete
4. The Xcode Organizer will open automatically when the archive is complete

## Step 4: Validate Your Archive

1. In the Xcode Organizer, select your new archive
2. Click "Validate App"
3. Select your distribution method (App Store)
4. Follow the prompts to validate your app
5. Fix any issues that arise during validation

## Step 5: Upload to App Store Connect

1. Once validation is successful, click "Distribute App"
2. Select "App Store Connect" as the distribution method
3. Follow the prompts to upload your app
4. Wait for the upload to complete
5. Wait for Apple to process your build (this can take from a few minutes to a few hours)

## Step 6: TestFlight Configuration

1. In App Store Connect, navigate to your app
2. Select the "TestFlight" tab
3. Your build should appear under "Builds" once Apple has processed it
4. Click on the build number
5. Add test information:
   - What to test: Brief description of what testers should focus on
   - Test notes: Any specific instructions for testers
6. If this is your first build, you'll need to complete the "Test Information" section:
   - Contact email: Your support email
   - Contact first name and last name
   - Demo account (if needed)
   - Beta App Review Information

## Step 7: Internal Testing

1. In the TestFlight tab, under "Testers and Groups", select "App Store Connect Users"
2. Add the team members who should have access to the build
3. They will receive an email invitation to test the app

## Step 8: External Testing (Optional)

1. In the TestFlight tab, under "Testers and Groups", click "+" to create a new group
2. Name your group (e.g., "Beta Testers")
3. Add email addresses for your external testers
4. Submit your app for Beta App Review (required for external testing)
5. Wait for Apple's approval (usually 1-2 days)
6. Once approved, your testers will receive an email invitation

## Step 9: Prepare for App Store Submission

1. In App Store Connect, navigate to your app
2. Select the "App Store" tab
3. Complete all required information:
   - App Information
   - Pricing and Availability
   - App Privacy
   - App Review Information
   - Version Information
4. Upload screenshots and app preview videos
5. Write your app description, keywords, and promotional text

## Step 10: Submit for Review

1. Once all information is complete, click "Save" and then "Submit for Review"
2. Answer the export compliance questions
3. Submit your app
4. Wait for Apple's review (typically 1-3 days)

## Command-Line Distribution (Optional)

You can also use the command line for archiving and uploading:

```bash
# Build and archive
xcodebuild -scheme ScreenTimeApp -archivePath ScreenTimeApp.xcarchive archive

# Export the archive to an IPA file
xcodebuild -exportArchive -archivePath ScreenTimeApp.xcarchive -exportPath ./build -exportOptionsPlist ExportOptions.plist

# Upload to App Store Connect
xcrun altool --upload-app -f build/ScreenTimeApp.ipa -t ios -u your@email.com -p app-specific-password
```

You'll need an ExportOptions.plist file:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
</dict>
</plist>
```

## Troubleshooting

- **Archive button is disabled**: Make sure you've selected "Any iOS Device" as the build destination
- **Signing issues**: Verify your certificates and provisioning profiles are valid
- **Upload failures**: Check your internet connection and Apple's system status
- **TestFlight processing issues**: Wait a few hours and try again, or contact Apple Support
- **Rejection**: Carefully read Apple's feedback and address all issues before resubmitting

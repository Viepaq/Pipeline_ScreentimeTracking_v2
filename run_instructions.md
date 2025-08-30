# Running the ScreenTime Accountability App

## Prerequisites

1. Install Xcode from the Mac App Store
2. Ensure you have iOS Simulator installed (comes with Xcode)

## Steps to Run the App

1. Open Xcode:
   ```bash
   open -a Xcode .
   ```
   Or manually open Xcode and use File > Open to navigate to the project directory.

2. Once Xcode opens, it should recognize the Swift Package Manager project. If not, open `Package.swift` directly.

3. Wait for Xcode to resolve dependencies and index the project.

4. Select the target scheme:
   - Click on the scheme selector in the toolbar (next to the Run/Stop buttons)
   - Select "ScreenTimeApp"

5. Select the iPhone 16 simulator:
   - Click on the device selector in the toolbar (next to the scheme selector)
   - Select "iPhone 16" from the list of available simulators
   - If iPhone 16 isn't available, choose another iPhone model running iOS 16 or later

6. Run the app:
   - Click the Run button (play icon) in the toolbar
   - Alternatively, press Cmd+R

7. The simulator will launch and the app will start running

## Troubleshooting

If you encounter any issues:

1. **Missing simulator**: Go to Xcode > Settings > Platforms and download the required simulator

2. **Build errors**: 
   - Make sure all dependencies are resolved
   - Check that you're using Swift 5.7 or later
   - Verify that the target is set to iOS 16 or later

3. **Signing issues**:
   - For development purposes, you can use automatic signing
   - Go to the project settings > Signing & Capabilities and check "Automatically manage signing"

4. **Supabase connection**:
   - Update the Supabase URL and anon key in `ScreenTimeApp/Sources/Services/SupabaseConfig.swift`
   - For testing purposes, the app will work with mock data even without a valid Supabase connection

## Testing the App

Once the app is running:

1. Create an account or use the mock data
2. Explore the three main tabs: Limits, Group, and Settings
3. Try setting app limits and simulating usage
4. Test the group invitation flow
5. Create and respond to time extension requests

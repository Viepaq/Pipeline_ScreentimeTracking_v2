#!/bin/bash

# Navigate to the project directory
cd "$(dirname "$0")"

# Build the app for the simulator
echo "Building ScreenTimeApp for simulator..."
xcodebuild \
  -scheme ScreenTimeApp \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro" \
  -configuration Debug \
  build

# Check if build was successful
if [ $? -eq 0 ]; then
  echo "Build successful! Opening simulator..."
  
  # Open the simulator if not already open
  open -a Simulator
  
  # Launch the app in the simulator
  xcrun simctl launch booted com.example.ScreenTimeApp
else
  echo "Build failed. Please check the errors above."
fi

#!/bin/bash
set -e

# Build the app
xcodebuild -scheme ScreenTimeApp -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=latest" build

# Get the path to the built app
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "*.app" | grep -i ScreenTimeApp | head -n 1)

if [ -z "$APP_PATH" ]; then
    echo "Error: Could not find built app"
    exit 1
fi

echo "Found app at: $APP_PATH"

# Install and launch the app on the simulator
xcrun simctl install booted "$APP_PATH"
xcrun simctl launch booted pipelinedev.ScreenTimeApp
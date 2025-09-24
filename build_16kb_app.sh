#!/bin/bash

# Script to build Android app with 16KB page size support
echo "Building Android app with 16KB page size support..."

# Clean previous builds
echo "Cleaning previous builds..."
cd "/Users/findigiosdev/Desktop/test ios/ios-flavorin/android"
./gradlew clean

# Build debug version with 16KB support
echo "Building debug version with 16KB support..."
./gradlew assemblePayuniDebug

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✓ Debug build successful"
    
    # Check alignment of built libraries
    echo "Checking 16KB alignment of built libraries..."
    cd ..
    ./check_16kb_alignment.sh
    
    echo ""
    echo "Build completed successfully!"
    echo "Next steps:"
    echo "1. Test the app on a device with 16KB page size"
    echo "2. Upload to Google Play Console"
    echo "3. Verify 16KB support in Play Console"
else
    echo "✗ Build failed"
    exit 1
fi

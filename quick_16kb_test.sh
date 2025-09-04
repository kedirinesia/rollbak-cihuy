#!/bin/bash

echo "🚀 Quick 16KB Page Size Test"
echo "============================="

# Check device connection
if ! adb devices | grep -q "device$"; then
    echo "❌ No device connected"
    echo "Please connect your device via USB and enable ADB"
    exit 1
fi

echo "✅ Device connected:"
adb devices | grep "device$"

echo ""
echo "📱 Device Info:"
echo "Android: $(adb shell getprop ro.build.version.release)"
echo "API: $(adb shell getprop ro.build.version.sdk)"
echo "Arch: $(adb shell getprop ro.product.cpu.abi)"

echo ""
echo "🔍 Testing 16KB Support..."
echo "1. Launch your app now"
echo "2. Look for 'This app isn't 16 KB compatible' dialog"
echo "3. Press Enter when ready to check logs..."

read -p "Press Enter to continue..."

echo ""
echo "📋 Checking for 16KB related logs..."
echo "====================================="

# Clear logcat and monitor for 16KB messages
adb logcat -c
adb logcat | grep -E "(16KB|16kb|page.size|page_size|alignment|ELF|APK|compatibility)" --color=always 
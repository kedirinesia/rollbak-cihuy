#!/bin/bash

echo "🔍 Testing 16KB Page Size Support..."
echo "====================================="

# Check if device is connected
if ! adb devices | grep -q "device$"; then
    echo "❌ No device connected. Please connect your device first."
    exit 1
fi

echo "✅ Device connected:"
adb devices | grep "device$"

echo ""
echo "📱 Checking device info..."
echo "Android Version: $(adb shell getprop ro.build.version.release)"
echo "API Level: $(adb shell getprop ro.build.version.sdk)"
echo "Architecture: $(adb shell getprop ro.product.cpu.abi)"

echo ""
echo "🔍 Monitoring 16KB page size logs..."
echo "Press Ctrl+C to stop monitoring"
echo "====================================="

# Monitor logcat for 16KB related messages
adb logcat | grep -E "(16KB|16kb|page.size|page_size|alignment|ELF|APK)" --color=always 
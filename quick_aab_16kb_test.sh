#!/bin/bash

# 🚀 Quick AAB 16KB Test
# Simple test for AAB 16KB page size compatibility

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

AAB_FILE="app-seepays-release.aab"

echo -e "${BLUE}🚀 Quick AAB 16KB Test${NC}"
echo "======================="
echo ""

# Check AAB file
if [ ! -f "$AAB_FILE" ]; then
    echo -e "${RED}❌ AAB file '$AAB_FILE' not found!${NC}"
    echo "Please ensure the AAB file exists in the current directory"
    exit 1
fi

echo -e "${GREEN}✅ AAB file found: $AAB_FILE${NC}"

# Check device
if ! adb devices | grep -q "device$"; then
    echo -e "${RED}❌ No device connected${NC}"
    echo "Please connect your device and enable USB debugging"
    exit 1
fi

echo -e "${GREEN}✅ Device connected${NC}"

# Device info
echo ""
echo -e "${BLUE}📱 Device Info:${NC}"
echo "Android: $(adb shell getprop ro.build.version.release)"
echo "API: $(adb shell getprop ro.build.version.sdk)"
echo "Arch: $(adb shell getprop ro.product.cpu.abi)"

# Check AAB size
aab_size=$(du -h "$AAB_FILE" | cut -f1)
echo ""
echo -e "${BLUE}📦 AAB Info:${NC}"
echo "Size: $aab_size"

# Check for native libraries
echo ""
echo -e "${BLUE}🔍 Checking AAB contents...${NC}"
if unzip -l "$AAB_FILE" | grep -q "lib/"; then
    echo -e "${GREEN}✅ Native libraries found${NC}"
    
    # Extract and check alignment
    temp_dir=$(mktemp -d)
    unzip -q "$AAB_FILE" -d "$temp_dir"
    
    echo "Checking ELF alignment..."
    find "$temp_dir" -name "*.so" -type f | while read -r so_file; do
        if [ -f "$so_file" ]; then
            alignment=$(objdump -p "$so_file" 2>/dev/null | grep LOAD | awk '{print $NF}' | head -1)
            if [[ $alignment =~ 2\*\*(1[4-9]|[2-9][0-9]|[1-9][0-9]{2,}) ]]; then
                echo -e "${GREEN}✅ $(basename "$so_file"): 16KB aligned${NC}"
            else
                echo -e "${YELLOW}⚠️  $(basename "$so_file"): Not 16KB aligned ($alignment)${NC}"
            fi
        fi
    done
    
    rm -rf "$temp_dir"
else
    echo -e "${YELLOW}⚠️  No native libraries found${NC}"
fi

echo ""
echo -e "${BLUE}🧪 Testing Instructions:${NC}"
echo "1. Install the AAB on your device"
echo "2. Launch the app"
echo "3. Look for 'This app isn't 16 KB compatible' dialog"
echo "4. If NO dialog appears → 16KB support SUCCESS ✅"
echo "5. If dialog appears → 16KB support FAILED ❌"

echo ""
echo -e "${YELLOW}💡 To install AAB:${NC}"
echo "Use Android Studio or bundletool to install the AAB"
echo "Or convert to APK first:"
echo "  bundletool build-apks --bundle=$AAB_FILE --output=app.apks"

echo ""
echo -e "${GREEN}🎯 Test completed! Check the results above.${NC}"

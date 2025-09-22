#!/bin/bash

# 🧪 Simple AAB 16KB Test
# Quick test for AAB 16KB page size compatibility

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

AAB_FILE="app-seepays-release.aab"

echo -e "${BLUE}🧪 Simple AAB 16KB Test${NC}"
echo "========================="
echo ""

# Check AAB file
if [ ! -f "$AAB_FILE" ]; then
    echo -e "${RED}❌ AAB file '$AAB_FILE' not found!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ AAB file found: $AAB_FILE${NC}"

# Check device
if ! adb devices | grep -q "device$"; then
    echo -e "${RED}❌ No device connected${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Device connected${NC}"

# Device info
echo ""
echo -e "${BLUE}📱 Device Info:${NC}"
echo "Android: $(adb shell getprop ro.build.version.release)"
echo "API: $(adb shell getprop ro.build.version.sdk)"
echo "Arch: $(adb shell getprop ro.product.cpu.abi)"

# AAB size
aab_size=$(du -h "$AAB_FILE" | cut -f1)
echo ""
echo -e "${BLUE}📦 AAB Info:${NC}"
echo "Size: $aab_size"

# Extract and analyze AAB
echo ""
echo -e "${BLUE}🔍 Analyzing AAB contents...${NC}"

temp_dir=$(mktemp -d)
unzip -q "$AAB_FILE" -d "$temp_dir"

# Check for native libraries
echo "Checking native libraries..."
lib_count=0
aligned_count=0
unaligned_count=0

find "$temp_dir" -name "*.so" -type f | while read -r so_file; do
    if [ -f "$so_file" ]; then
        lib_count=$((lib_count + 1))
        alignment=$(objdump -p "$so_file" 2>/dev/null | grep LOAD | awk '{print $NF}' | head -1)
        lib_name=$(basename "$so_file")
        
        if [[ $alignment =~ 2\*\*(1[4-9]|[2-9][0-9]|[1-9][0-9]{2,}) ]]; then
            echo -e "${GREEN}✅ $lib_name: 16KB aligned ($alignment)${NC}"
            aligned_count=$((aligned_count + 1))
        else
            echo -e "${YELLOW}⚠️  $lib_name: Not 16KB aligned ($alignment)${NC}"
            unaligned_count=$((unaligned_count + 1))
        fi
    fi
done

# Cleanup
rm -rf "$temp_dir"

echo ""
echo -e "${BLUE}📊 Analysis Summary:${NC}"
echo "Total native libraries: $lib_count"
echo "16KB aligned: $aligned_count"
echo "Not 16KB aligned: $unaligned_count"

# Calculate compatibility percentage
if [ $lib_count -gt 0 ]; then
    compatibility_percent=$((aligned_count * 100 / lib_count))
    echo "16KB compatibility: ${compatibility_percent}%"
    
    if [ $compatibility_percent -ge 80 ]; then
        echo -e "${GREEN}✅ GOOD: High 16KB compatibility${NC}"
    elif [ $compatibility_percent -ge 50 ]; then
        echo -e "${YELLOW}⚠️  MODERATE: Partial 16KB compatibility${NC}"
    else
        echo -e "${RED}❌ POOR: Low 16KB compatibility${NC}"
    fi
fi

echo ""
echo -e "${BLUE}🧪 Manual Testing Instructions:${NC}"
echo "1. Install AAB on device using Android Studio or bundletool"
echo "2. Launch the app"
echo "3. Look for 'This app isn't 16 KB compatible' dialog"
echo "4. If NO dialog → 16KB support SUCCESS ✅"
echo "5. If dialog appears → 16KB support FAILED ❌"

echo ""
echo -e "${BLUE}💡 Installation Options:${NC}"
echo "Option 1 - Android Studio:"
echo "  - Open Android Studio"
echo "  - Build → Generate Signed Bundle/APK"
echo "  - Select AAB and install"

echo ""
echo "Option 2 - Bundletool (if available):"
echo "  bundletool build-apks --bundle=$AAB_FILE --output=app.apks --mode=universal"
echo "  bundletool install-apks --apks=app.apks"

echo ""
echo -e "${GREEN}🎯 Test completed! Review the analysis above.${NC}"

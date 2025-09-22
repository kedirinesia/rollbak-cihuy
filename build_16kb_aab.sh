#!/bin/bash

# 🚀 Build AAB with 16KB Page Size Support
# Script untuk build AAB dengan optimasi 16KB page size

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${BLUE}🚀 Building AAB with 16KB Page Size Support${NC}"
echo "=============================================="
echo ""

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Not in Flutter project directory${NC}"
    echo "Please run this script from the Flutter project root"
    exit 1
fi

echo -e "${GREEN}✅ Flutter project detected${NC}"

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
flutter clean
cd android
./gradlew clean
cd ..

echo -e "${GREEN}✅ Clean completed${NC}"

# Get dependencies
echo -e "${YELLOW}📦 Getting Flutter dependencies...${NC}"
flutter pub get

echo -e "${GREEN}✅ Dependencies updated${NC}"

# Build AAB for seepays flavor
echo -e "${YELLOW}🔨 Building AAB for seepays flavor...${NC}"
echo "This may take several minutes..."

flutter build appbundle --flavor seepays --release

echo -e "${GREEN}✅ AAB build completed${NC}"

# Check if AAB was created
AAB_PATH="build/app/outputs/bundle/seepaysRelease/app-seepays-release.aab"
if [ -f "$AAB_PATH" ]; then
    echo -e "${GREEN}✅ AAB file created: $AAB_PATH${NC}"
    
    # Get AAB size
    aab_size=$(du -h "$AAB_PATH" | cut -f1)
    echo -e "${BLUE}📦 AAB Size: $aab_size${NC}"
    
    # Copy to current directory for testing
    cp "$AAB_PATH" ./app-seepays-release.aab
    echo -e "${GREEN}✅ AAB copied to current directory${NC}"
    
    echo ""
    echo -e "${PURPLE}🎯 Next Steps:${NC}"
    echo "1. Test the AAB with: ./quick_aab_16kb_test.sh"
    echo "2. Or run comprehensive test: ./test_aab_16kb.sh"
    echo "3. Check for 16KB compatibility on device"
    
else
    echo -e "${RED}❌ AAB file not found at expected location${NC}"
    echo "Expected: $AAB_PATH"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 Build completed successfully!${NC}"
echo -e "${BLUE}📱 Your AAB is ready for 16KB page size testing${NC}"

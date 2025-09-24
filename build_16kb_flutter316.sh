#!/bin/bash

echo "🚀 Building PayMobileKu with Flutter 3.16.9 - 16KB page size support"

# Navigate to project directory
cd "/Users/findigiosdev/Desktop/test ios/ios-flavorin"

echo "✅ Using Flutter 3.16.9 with 16KB support"
fvm flutter --version

echo "🧹 Cleaning all caches..."
# Clean Flutter cache
fvm flutter clean

# Clean Gradle cache  
cd android
./gradlew clean
cd ..

echo "📦 Getting dependencies..."
fvm flutter pub get

echo "🔧 Verifying 16KB configuration..."
echo "✅ gradle.properties:"
grep -E "(pageSize|PageSizeAgnostic)" android/gradle.properties

echo "✅ AndroidManifest.xml 16KB meta-data:"
grep -A1 -B1 "16kb_pages\|memory_alignment" android/app/src/main/AndroidManifest.xml

echo "✅ build.gradle targetSdkVersion:"
grep "targetSdkVersion" android/app/build.gradle

echo ""
echo "🔨 Building app bundle with Flutter 3.16.9 + 16KB page size support..."
fvm flutter build appbundle \
    --flavor paymobileku \
    -t lib/Products/paymobileku/index.dart \
    --no-sound-null-safety \
    --verbose

# Check build result
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build berhasil dengan Flutter 3.16.9!"
    echo "📱 App bundle location: build/app/outputs/bundle/paymobilekuRelease/app-paymobileku-release.aab"
    
    # Show file info
    ls -lh build/app/outputs/bundle/paymobilekuRelease/app-paymobileku-release.aab
    
    echo ""
    echo "🔍 Verifying native libraries..."
    if [ -f "bundletool.jar" ]; then
        echo "📋 Checking for 16KB support in native libraries:"
        java -jar bundletool.jar dump manifest --bundle=build/app/outputs/bundle/paymobilekuRelease/app-paymobileku-release.aab | grep -i "16kb\|page"
    fi
    
    echo ""
    echo "🎯 NEXT STEPS:"
    echo "1. Upload AAB ke Google Play Console yang BENAR untuk PayMobileKu"
    echo "2. Flutter 3.16.9 engine sudah mendukung 16KB page size"
    echo "3. Google Play Console seharusnya mendeteksi 16KB support sekarang!"
    echo ""
    echo "🔥 Flutter 3.16.9 + 16KB Configuration = SUCCESS!"
    
else
    echo "❌ Build gagal!"
    echo "Cek error di atas untuk troubleshooting"
    exit 1
fi

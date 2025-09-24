#!/bin/bash

echo "🚀 Building PayMobileKu with 16KB page size support - FINAL VERSION"

# Navigate to project directory
cd "/Users/findigiosdev/Desktop/test ios/ios-flavorin"

echo "🧹 Cleaning all caches..."
# Clean Flutter cache
flutter clean

# Clean Gradle cache
cd android
./gradlew clean
cd ..

echo "📦 Getting dependencies..."
flutter pub get

echo "🔧 Verifying 16KB configuration..."
echo "✅ gradle.properties:"
grep -E "(pageSize|PageSizeAgnostic)" android/gradle.properties

echo "✅ AndroidManifest.xml 16KB meta-data:"
grep -A1 -B1 "16kb_pages\|memory_alignment" android/app/src/main/AndroidManifest.xml

echo "✅ build.gradle targetSdkVersion:"
grep "targetSdkVersion" android/app/build.gradle

echo ""
echo "🔨 Building app bundle with 16KB page size support..."
flutter build appbundle \
    --flavor paymobileku \
    -t lib/Products/paymobileku/index.dart \
    --no-sound-null-safety \
    --verbose \
    --dart-define=FLUTTER_WEB_USE_SKIA=true

# Check build result
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build berhasil!"
    echo "📱 App bundle location: build/app/outputs/bundle/paymobilekuRelease/app-paymobileku-release.aab"
    
    # Show file info
    ls -lh build/app/outputs/bundle/paymobilekuRelease/app-paymobileku-release.aab
    
    echo ""
    echo "🔍 Verifying AAB with bundletool..."
    if [ -f "bundletool.jar" ]; then
        echo "📋 Bundle info:"
        java -jar bundletool.jar validate --bundle=build/app/outputs/bundle/paymobilekuRelease/app-paymobileku-release.aab
        
        echo ""
        echo "📊 Bundle analysis:"
        java -jar bundletool.jar dump config --bundle=build/app/outputs/bundle/paymobilekuRelease/app-paymobileku-release.aab
    else
        echo "⚠️  bundletool.jar tidak ditemukan untuk verifikasi"
        echo "   Download dari: https://github.com/google/bundletool/releases"
    fi
    
    echo ""
    echo "🎯 NEXT STEPS:"
    echo "1. Upload AAB ke Google Play Console yang BENAR untuk PayMobileKu"
    echo "2. Pastikan aplikasi dengan package name: id.paymobileku.app"
    echo "3. Google Play Console seharusnya mendeteksi 16KB support"
    echo ""
    echo "🔑 Jika masih ada masalah signing key:"
    echo "   - Pastikan upload ke console aplikasi yang benar"
    echo "   - Atau buat aplikasi baru di Google Play Console"
    
else
    echo "❌ Build gagal!"
    echo "Cek error di atas untuk troubleshooting"
    exit 1
fi

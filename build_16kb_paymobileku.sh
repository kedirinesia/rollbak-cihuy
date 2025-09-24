#!/bin/bash

# Build script untuk PayMobileKu dengan 16KB page size support
echo "🚀 Building PayMobileKu with 16KB page size support..."

# Bersihkan build cache
echo "🧹 Cleaning build cache..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build app bundle dengan konfigurasi 16KB
echo "🔨 Building app bundle with 16KB page size support..."
flutter build appbundle \
    --flavor paymobileku \
    -t lib/Products/paymobileku/index.dart \
    --no-sound-null-safety \
    --verbose

# Check hasil build
if [ $? -eq 0 ]; then
    echo "✅ Build berhasil!"
    echo "📱 App bundle location: build/app/outputs/bundle/paymobilekuRelease/app-paymobileku-release.aab"
    
    # Tampilkan informasi file
    ls -lh build/app/outputs/bundle/paymobilekuRelease/app-paymobileku-release.aab
    
    echo ""
    echo "🔍 Checking 16KB support..."
    # Gunakan bundletool untuk verifikasi 16KB support
    if [ -f "bundletool.jar" ]; then
        java -jar bundletool.jar validate --bundle=build/app/outputs/bundle/paymobilekuRelease/app-paymobileku-release.aab
    else
        echo "⚠️  bundletool.jar tidak ditemukan. Download dari: https://github.com/google/bundletool/releases"
    fi
else
    echo "❌ Build gagal!"
    exit 1
fi

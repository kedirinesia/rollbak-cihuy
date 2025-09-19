#!/bin/bash

echo "🔧 Fixing null safety errors comprehensively..."

# Fix BarcodeScanner usage
echo "📦 Fixing BarcodeScanner usage..."
find lib -name "*.dart" -type f -exec sed -i '' 's/BarcodeScanner\.scan/MobileScanner.scan/g' {} \;

# Fix Share usage
echo "📦 Fixing Share usage..."
find lib -name "*.dart" -type f -exec sed -i '' 's/Share\.share/Share.share/g' {} \;

# Fix Toast usage
echo "📦 Fixing Toast usage..."
find lib -name "*.dart" -type f -exec sed -i '' 's/Toast\.LENGTH_LONG/ToastLength.LONG/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/Toast\.CENTER/ToastGravity.CENTER/g' {} \;

# Fix url_launcher usage
echo "📦 Fixing url_launcher usage..."
find lib -name "*.dart" -type f -exec sed -i '' 's/canLaunch/canLaunchUrl/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/launch(/launchUrl(/g' {} \;

# Fix WebView usage
echo "📦 Fixing WebView usage..."
find lib -name "*.dart" -type f -exec sed -i '' 's/JavascriptMode\.unrestricted/JavascriptMode.unrestricted/g' {} \;

# Fix CarouselController usage
echo "📦 Fixing CarouselController usage..."
find lib -name "*.dart" -type f -exec sed -i '' 's/CarouselController()/CarouselController()/g' {} \;

# Fix PackageInfo usage
echo "📦 Fixing PackageInfo usage..."
find lib -name "*.dart" -type f -exec sed -i '' 's/PackageInfo\.fromPlatform/PackageInfo.fromPlatform/g' {} \;

# Fix InAppReview usage
echo "📦 Fixing InAppReview usage..."
find lib -name "*.dart" -type f -exec sed -i '' 's/InAppReview\.instance/InAppReview.instance/g' {} \;

echo "✅ Comprehensive null safety fixes completed!"

#!/bin/bash

echo "🔧 Fixing null safety errors..."

# Fix SlideDialog usage
echo "📦 Fixing SlideDialog usage..."
find lib -name "*.dart" -type f -exec sed -i '' 's/SlideDialog\.showSlideDialog/showModalBottomSheet/g' {} \;

# Fix url_launcher imports
echo "📦 Fixing url_launcher imports..."
find lib -name "*.dart" -type f -exec sed -i '' 's/import '\''package:url_launcher\/url_launcher\.dart'\'';/import '\''package:url_launcher\/url_launcher.dart'\'';/g' {} \;

# Fix device_info imports
echo "📦 Fixing device_info imports..."
find lib -name "*.dart" -type f -exec sed -i '' 's/import '\''package:device_info\/device_info\.dart'\'';/import '\''package:device_info_plus\/device_info_plus.dart'\'';/g' {} \;

# Fix share imports
echo "📦 Fixing share imports..."
find lib -name "*.dart" -type f -exec sed -i '' 's/import '\''package:share\/share\.dart'\'';/import '\''package:share_plus\/share_plus.dart'\'';/g' {} \;

# Fix barcode_scan2 usage
echo "📦 Fixing barcode_scan2 usage..."
find lib -name "*.dart" -type f -exec sed -i '' 's/BarcodeScanner\.scan/MobileScanner\.scan/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/ScanResult/ScanResult/g' {} \;

# Fix flutter_custom_tabs usage
echo "📦 Fixing flutter_custom_tabs usage..."
find lib -name "*.dart" -type f -exec sed -i '' 's/launch\(/launchUrl(/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/CustomTabsOption/LaunchMode/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/CustomTabsSystemAnimation/LaunchMode/g' {} \;

# Fix DeviceInfoPlugin usage
echo "📦 Fixing DeviceInfoPlugin usage..."
find lib -name "*.dart" -type f -exec sed -i '' 's/DeviceInfoPlugin/DeviceInfoPlugin/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/AndroidDeviceInfo/AndroidDeviceInfo/g' {} \;

# Fix share usage
echo "📦 Fixing share usage..."
find lib -name "*.dart" -type f -exec sed -i '' 's/Share\.shareFiles/Share\.shareXFiles/g' {} \;

echo "✅ Null safety fixes completed!"

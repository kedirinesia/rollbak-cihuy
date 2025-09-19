#!/bin/bash

echo "🔧 Fixing migration errors (v2)..."

# Fix import statements more carefully
echo "📦 Fixing import statements..."

# Replace barcode_scan2 with mobile_scanner imports only
find lib -name "*.dart" -type f -exec sed -i '' 's/import '\''package:barcode_scan2\/barcode_scan2\.dart'\'';/import '\''package:mobile_scanner\/mobile_scanner.dart'\'';/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/import '\''package:barcode_scan2\/platform_wrapper\.dart'\'';/import '\''package:mobile_scanner\/mobile_scanner.dart'\'';/g' {} \;

# Replace share with share_plus imports only
find lib -name "*.dart" -type f -exec sed -i '' 's/import '\''package:share\/share\.dart'\'';/import '\''package:share_plus\/share_plus.dart'\'';/g' {} \;

# Replace package_info with package_info_plus imports only
find lib -name "*.dart" -type f -exec sed -i '' 's/import '\''package:package_info\/package_info\.dart'\'';/import '\''package:package_info_plus\/package_info_plus.dart'\'';/g' {} \;

# Remove problematic imports
find lib -name "*.dart" -type f -exec sed -i '' '/import '\''package:flutter_page_transition\/flutter_page_transition\.dart'\'';/d' {} \;
find lib -name "*.dart" -type f -exec sed -i '' '/import '\''package:slide_popup_dialog\/slide_popup_dialog\.dart'\'';/d' {} \;
find lib -name "*.dart" -type f -exec sed -i '' '/import '\''package:flutter_custom_tabs\/flutter_custom_tabs\.dart'\'';/d' {} \;
find lib -name "*.dart" -type f -exec sed -i '' '/import '\''package:in_app_review\/in_app_review\.dart'\'';/d' {} \;

echo "✅ Import statements fixed!"

# Fix method calls more carefully
echo "🔧 Fixing method calls..."

# Replace BarcodeScanner.scan with MobileScanner.scan
find lib -name "*.dart" -type f -exec sed -i '' 's/BarcodeScanner\.scan/MobileScanner.scan/g' {} \;

# Replace Share.share with Share.share
find lib -name "*.dart" -type f -exec sed -i '' 's/Share\.share/Share.share/g' {} \;

# Replace PackageInfo.fromPlatform with PackageInfo.fromPlatform
find lib -name "*.dart" -type f -exec sed -i '' 's/PackageInfo\.fromPlatform/PackageInfo.fromPlatform/g' {} \;

# Fix Toast usage
find lib -name "*.dart" -type f -exec sed -i '' 's/Toast\.LENGTH_LONG/Toast.lengthLong/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/Toast\.CENTER/Toast.center/g' {} \;

# Fix buttonColor to colorScheme.primary
find lib -name "*.dart" -type f -exec sed -i '' 's/Theme\.of(context)\.buttonColor/Theme.of(context).colorScheme.primary/g' {} \;

echo "✅ Method calls fixed!"

echo "🎉 Migration errors fixed! Now run 'dart migrate --apply-changes' again."

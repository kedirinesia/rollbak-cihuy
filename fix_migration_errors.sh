#!/bin/bash

echo "🔧 Fixing migration errors..."

# Fix import statements
echo "📦 Fixing import statements..."

# Replace barcode_scan2 with mobile_scanner
find lib -name "*.dart" -type f -exec sed -i '' 's/package:barcode_scan2\/barcode_scan2\.dart/package:mobile_scanner\/mobile_scanner.dart/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/package:barcode_scan2\/platform_wrapper\.dart/package:mobile_scanner\/mobile_scanner.dart/g' {} \;

# Replace url_launcher old imports
find lib -name "*.dart" -type f -exec sed -i '' 's/package:url_launcher\/url_launcher\.dart/package:url_launcher\/url_launcher.dart/g' {} \;

# Replace share with share_plus
find lib -name "*.dart" -type f -exec sed -i '' 's/package:share\/share\.dart/package:share_plus\/share_plus.dart/g' {} \;

# Replace package_info with package_info_plus
find lib -name "*.dart" -type f -exec sed -i '' 's/package:package_info\/package_info\.dart/package:package_info_plus\/package_info_plus.dart/g' {} \;

# Remove flutter_page_transition imports (will be replaced with Navigator)
find lib -name "*.dart" -type f -exec sed -i '' '/package:flutter_page_transition\/flutter_page_transition\.dart/d' {} \;

# Remove slide_popup_dialog imports
find lib -name "*.dart" -type f -exec sed -i '' '/package:slide_popup_dialog\/slide_popup_dialog\.dart/d' {} \;

# Remove flutter_custom_tabs imports
find lib -name "*.dart" -type f -exec sed -i '' '/package:flutter_custom_tabs\/flutter_custom_tabs\.dart/d' {} \;

# Remove in_app_review imports
find lib -name "*.dart" -type f -exec sed -i '' '/package:in_app_review\/in_app_review\.dart/d' {} \;

echo "✅ Import statements fixed!"

# Fix method calls
echo "🔧 Fixing method calls..."

# Replace BarcodeScanner with MobileScanner
find lib -name "*.dart" -type f -exec sed -i '' 's/BarcodeScanner\.scan/MobileScanner.scan/g' {} \;

# Replace Share with Share.share
find lib -name "*.dart" -type f -exec sed -i '' 's/Share\.share/Share.share/g' {} \;

# Replace PackageInfo with PackageInfo.fromPlatform
find lib -name "*.dart" -type f -exec sed -i '' 's/PackageInfo\.fromPlatform/PackageInfo.fromPlatform/g' {} \;

# Replace canLaunch with canLaunchUrl
find lib -name "*.dart" -type f -exec sed -i '' 's/canLaunch(/canLaunchUrl(/g' {} \;

# Replace launch with launchUrl
find lib -name "*.dart" -type f -exec sed -i '' 's/launch(/launchUrl(/g' {} \;

# Fix Toast usage
find lib -name "*.dart" -type f -exec sed -i '' 's/Toast\.LENGTH_LONG/Toast.lengthLong/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/Toast\.CENTER/Toast.center/g' {} \;

# Fix buttonColor to colorScheme.primary
find lib -name "*.dart" -type f -exec sed -i '' 's/Theme\.of(context)\.buttonColor/Theme.of(context).colorScheme.primary/g' {} \;

# Fix CarouselController conflicts
find lib -name "*.dart" -type f -exec sed -i '' 's/CarouselController()/carousel_slider.CarouselController()/g' {} \;

echo "✅ Method calls fixed!"

# Fix WebView usage
echo "🌐 Fixing WebView usage..."
find lib -name "*.dart" -type f -exec sed -i '' 's/WebView(/WebViewWidget(controller: WebViewController()..setJavaScriptMode(JavascriptMode.unrestricted)..loadRequest(Uri.parse(/g' {} \;

echo "✅ WebView usage fixed!"

# Remove PageTransition usage (replace with Navigator.push)
echo "🔄 Fixing PageTransition usage..."
find lib -name "*.dart" -type f -exec sed -i '' 's/PageTransition(//g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/PageTransitionType\.//g' {} \;

echo "✅ PageTransition usage fixed!"

echo "🎉 Migration errors fixed! Now run 'dart migrate --apply-changes' again."

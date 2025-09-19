#!/bin/bash

echo "🔧 Fixing imports systematically..."

# Remove @dart=2.9 from all files
echo "📦 Removing @dart=2.9 directives..."
find lib -name "*.dart" -type f -exec sed -i '' '/^\/\/ @dart=2.9$/d' {} \;

# Fix package_info imports
echo "📦 Fixing package_info imports..."
find lib -name "*.dart" -type f -exec sed -i '' 's/import '\''package:package_info\/package_info\.dart'\'';/import '\''package:package_info_plus\/package_info_plus\.dart'\'';/g' {} \;

# Fix share imports
echo "📦 Fixing share imports..."
find lib -name "*.dart" -type f -exec sed -i '' 's/import '\''package:share\/share\.dart'\'';/import '\''package:share_plus\/share_plus\.dart'\'';/g' {} \;

# Fix url_launcher imports
echo "📦 Fixing url_launcher imports..."
find lib -name "*.dart" -type f -exec sed -i '' 's/import '\''package:url_launcher\/url_launcher\.dart'\'';/import '\''package:url_launcher\/url_launcher\.dart'\'';/g' {} \;

# Fix barcode_scan2 imports
echo "📦 Fixing barcode_scan2 imports..."
find lib -name "*.dart" -type f -exec sed -i '' 's/import '\''package:barcode_scan2\/barcode_scan2\.dart'\'';/import '\''package:mobile_scanner\/mobile_scanner\.dart'\'';/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/import '\''package:barcode_scan2\/platform_wrapper\.dart'\'';/import '\''package:mobile_scanner\/mobile_scanner\.dart'\'';/g' {} \;

# Fix webview_flutter imports
echo "📦 Fixing webview_flutter imports..."
find lib -name "*.dart" -type f -exec sed -i '' 's/import '\''package:webview_flutter\/webview_flutter\.dart'\'';/import '\''package:webview_flutter\/webview_flutter\.dart'\'';/g' {} \;

echo "✅ Import fixes completed!"

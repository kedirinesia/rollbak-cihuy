#!/bin/bash

echo "🔧 Fixing remaining migration errors..."

# Remove @dart=2.9 from all files
echo "📦 Removing @dart=2.9 directives..."
find lib -name "*.dart" -type f -exec sed -i '' '/^\/\/ @dart=2.9$/d' {} \;

# Fix slide_popup_dialog imports and usage
echo "📦 Fixing slide_popup_dialog usage..."
find lib -name "*.dart" -type f -exec sed -i '' 's/import '\''package:slide_popup_dialog\/slide_popup_dialog\.dart'\'' as SlideDialog;//g' {} \;

# Fix package_info imports
echo "📦 Fixing package_info imports..."
find lib -name "*.dart" -type f -exec sed -i '' 's/import '\''package:package_info\/package_info\.dart'\'';/import '\''package:package_info_plus\/package_info_plus\.dart'\'';/g' {} \;

# Fix share imports
echo "📦 Fixing share imports..."
find lib -name "*.dart" -type f -exec sed -i '' 's/import '\''package:share\/share\.dart'\'';/import '\''package:share_plus\/share_plus\.dart'\'';/g' {} \;

# Fix barcode_scan2 imports
echo "📦 Fixing barcode_scan2 imports..."
find lib -name "*.dart" -type f -exec sed -i '' 's/import '\''package:barcode_scan2\/barcode_scan2\.dart'\'';/import '\''package:mobile_scanner\/mobile_scanner\.dart'\'';/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/import '\''package:barcode_scan2\/platform_wrapper\.dart'\'';/import '\''package:mobile_scanner\/mobile_scanner\.dart'\'';/g' {} \;

# Fix flutter_page_transition imports
echo "📦 Fixing flutter_page_transition imports..."
find lib -name "*.dart" -type f -exec sed -i '' 's/import '\''package:flutter_page_transition\/flutter_page_transition\.dart'\'';//g' {} \;

echo "✅ Migration fixes completed!"

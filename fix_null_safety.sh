#!/bin/bash

# Script to fix null safety issues in Flutter project

echo "🔧 Starting null safety fixes..."

# Find all .dart files and remove @dart=2.9 directive
echo "📝 Removing @dart=2.9 directives..."
find lib -name "*.dart" -type f -exec sed -i '' '/^\/\/ @dart=2\.9$/d' {} \;

# Remove flutter_page_transition imports
echo "📦 Removing flutter_page_transition imports..."
find lib -name "*.dart" -type f -exec sed -i '' '/^import.*flutter_page_transition.*$/d' {} \;

# Remove slide_popup_dialog imports (the package doesn't exist)
echo "🗑️  Removing slide_popup_dialog imports..."
find lib -name "*.dart" -type f -exec sed -i '' '/^import.*slide_popup_dialog.*$/d' {} \;

# Fix PageTransitionType.rippleRightUp to rightToLeft
echo "🔄 Fixing PageTransitionType references..."
find lib -name "*.dart" -type f -exec sed -i '' 's/PageTransitionType\.rippleRightUp/PageTransitionType.rightToLeft/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/PageTransitionType\.rippleMiddle/PageTransitionType.fade/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/PageTransitionType\.slideInUp/PageTransitionType.bottomToTop/g' {} \;

# Fix @required to required
echo "✅ Fixing @required to required..."
find lib -name "*.dart" -type f -exec sed -i '' 's/@required /required /g' {} \;

# Fix Key key to Key? key
echo "🔑 Fixing Key parameters..."
find lib -name "*.dart" -type f -exec sed -i '' 's/{Key key}/{Key? key}/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/: super(key: key)/: super(key: key)/g' {} \;

echo "✨ Null safety fixes completed!"
echo "🚨 Note: You may still need to manually fix specific API issues like:"
echo "   - Theme.of(context).buttonColor -> Theme.of(context).colorScheme.primary"
echo "   - WebView widget updates"
echo "   - Toast.show parameter changes"
echo "   - IOSInitializationSettings -> DarwinInitializationSettings"


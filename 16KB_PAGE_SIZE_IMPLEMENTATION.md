# 16KB Page Size Support Implementation

## Overview
This document outlines the changes made to enable 16KB page size support for the Android application, addressing the Google Play Console issue showing "Tidak mendukung 16 KB" (Does not support 16 KB).

## Changes Made

### 1. AndroidManifest.xml Updates
- Updated `targetSdkVersion` from 35 to 36
- Added proper meta-data for 16KB page size support:
  - `android.app.page_size_agnostic=true`
  - `android.app.package_alignment=16384`
  - `android.app.elf_alignment=16384`
  - `flutter.embedding.android.PageSizeAgnostic=true`
  - `flutter.embedding.android.PackageAlignment=16384`

### 2. build.gradle Configuration
- Enhanced packaging options for 16KB support
- Added CMake configuration with 16KB alignment flags
- Updated externalNativeBuild settings for all build types
- Added manifest placeholders for 16KB configuration
- Configured NDK settings for proper alignment

### 3. CMakeLists.txt Configuration
- Created new CMake configuration file for 16KB alignment
- Set linker flags for 16KB page size (`-Wl,-z,page-size=16384`)
- Configured section alignment for 16KB pages
- Added page size agnostic compilation flags

### 4. Proguard Configuration
- Updated `proguard-16kb.pro` with 16KB optimization rules
- Added memory optimization settings for large page sizes
- Configured native method preservation

## Files Modified
- `android/app/src/main/AndroidManifest.xml`
- `android/app/build.gradle`
- `android/app/src/main/cpp/CMakeLists.txt` (new file)
- `android/app/proguard-16kb.pro` (updated)

## Files Created
- `check_16kb_alignment.sh` - Script to verify 16KB alignment
- `build_16kb_app.sh` - Script to build app with 16KB support

## Testing Instructions

### 1. Build the Application
```bash
./build_16kb_app.sh
```

### 2. Check Alignment
```bash
./check_16kb_alignment.sh
```

### 3. Verify in Google Play Console
After uploading the new AAB/APK, check the "Detail" tab to verify:
- "Ukuran halaman memori" should show "Mendukung 16 KB" instead of "Tidak mendukung 16 KB"

## Key Configuration Details

### Page Size Agnostic Settings
- `ANDROID_PAGE_SIZE_AGNOSTIC=ON` - Enables page size agnostic compilation
- `ANDROID_PAGE_SIZE=16384` - Sets specific page size to 16KB
- `-Wl,-z,page-size=16384` - Linker flag for 16KB alignment

### Native Library Optimization
- `doNotStrip` configuration for all architectures
- `useLegacyPackaging=false` for modern packaging
- Proper ELF alignment settings

### Flutter Integration
- Flutter embedding configuration for 16KB support
- Package alignment settings
- Page size agnostic compilation

## Expected Results
After implementing these changes:
1. The app should build successfully with 16KB support
2. Native libraries should have proper 16KB alignment
3. Google Play Console should show 16KB support enabled
4. The app should work correctly on devices with 16KB page size

## Troubleshooting
If 16KB support is still not detected:
1. Clean and rebuild the project
2. Verify all configuration files are properly updated
3. Check that CMakeLists.txt is being used during build
4. Ensure all native libraries are properly aligned
5. Test on a physical device with 16KB page size if available

## Notes
- These changes maintain backward compatibility with 4KB page size devices
- The configuration is optimized for both debug and release builds
- All product flavors inherit the 16KB support configuration

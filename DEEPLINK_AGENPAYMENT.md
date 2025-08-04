# Deep Link Setup untuk Agen Payment

## Konfigurasi Deep Link: `agenpayment://login`

### Android Configuration

Deep link sudah dikonfigurasi di `android/app/src/agenpayment/AndroidManifest.xml` dengan intent filter berikut:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="agenpayment" android:host="login" />
</intent-filter>
```

### Flutter Code

Deep link handler sudah diimplementasi di `lib/index.dart` dalam fungsi `appLink()`:

```dart
void appLink() {
  _appLinks = AppLinks(onAppLink: (uri, str) {
    print('Deep link received: $uri');
    
    // Handle agenpayment://login deep link
    if (uri.scheme == 'agenpayment' && uri.host == 'login')     {
      // Navigate to login page
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => configAppBloc.layoutApp.valueWrapper?.value['login'] ?? LoginPage()),
        (route) => false
      );
      showToast(context, 'Navigating to login page via deep link');
    } else {
      showToast(context, str);
    }
  });
}
```

### Cara Penggunaan

1. **Testing di Android:**
   ```bash
   adb shell am start -W -a android.intent.action.VIEW -d "agenpayment://login" id.agenpayment.app
   ```

2. **Testing di Browser:**
   - Buka browser dan ketik: `agenpayment://login`
   - Aplikasi akan terbuka dan langsung navigasi ke halaman login

3. **Testing di Terminal/Command Line:**
   ```bash
   # Android
   adb shell am start -W -a android.intent.action.VIEW -d "agenpayment://login" id.agenpayment.app
   
   # iOS (jika menggunakan simulator)
   xcrun simctl openurl booted "agenpayment://login"
   ```

### Fitur Deep Link

- **Scheme:** `agenpayment`
- **Host:** `login`
- **Full URL:** `agenpayment://login`
- **Fungsi:** Membuka aplikasi dan langsung navigasi ke halaman login
- **Behavior:** Menghapus semua route sebelumnya dan menampilkan halaman login

### Dependencies

Pastikan dependencies berikut sudah ada di `pubspec.yaml`:
```yaml
dependencies:
  app_links: ^2.1.0
```

### Catatan

- Deep link ini hanya berfungsi untuk flavor `agenpayment`
- Aplikasi harus sudah terinstall di device
- Untuk testing, pastikan menggunakan package name yang benar: `id.agenpayment.app` 
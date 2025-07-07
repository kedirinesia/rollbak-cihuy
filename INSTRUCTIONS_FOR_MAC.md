# Instruksi Konfigurasi Flavor iOS di macOS

Berikut adalah langkah-langkah untuk mengonfigurasi flavor iOS untuk proyek Flutter Anda di komputer Mac.

### Langkah 1: Transfer Proyek
Pastikan seluruh direktori proyek Flutter Anda (termasuk file `setup_ios_flavors.rb` yang sudah dibuat) telah disalin ke komputer Mac Anda.

### Langkah 2: Buka Terminal
Di Mac Anda, buka aplikasi Terminal. Anda dapat menemukannya di `Applications/Utilities/Terminal.app` atau mencarinya menggunakan Spotlight.

### Langkah 3: Navigasi ke Direktori Proyek
Gunakan perintah `cd` (change directory) untuk masuk ke direktori root proyek Flutter Anda.
Contoh:
```bash
cd /path/to/your/payuni-mobile-application-maintenance
```

### Langkah 4: Instal 'xcodeproj' Gem
Skrip ini memerlukan 'gem' Ruby untuk memodifikasi file proyek Xcode. Jalankan perintah berikut di terminal. Anda mungkin akan dimintai kata sandi administrator Anda.

```bash
sudo gem install xcodeproj
```

### Langkah 5: Jalankan Skrip Konfigurasi
Setelah gem berhasil diinstal, jalankan skrip Ruby yang telah kita buat.

```bash
ruby setup_ios_flavors.rb
```
Skrip ini akan secara otomatis membuat file `.xcconfig`, memodifikasi proyek Xcode Anda untuk menambahkan *Build Configurations* baru, dan membuat *Scheme* untuk setiap flavor.

### Langkah 6: Modifikasi Manual `Info.plist`
Ini adalah satu-satunya langkah manual yang diperlukan.

1.  Buka proyek iOS di Xcode dengan menjalankan perintah berikut di terminal dari direktori root proyek Anda:
    ```bash
    open ios/Runner.xcworkspace
    ```
2.  Di Xcode, temukan file `Info.plist` di dalam direktori `Runner/Runner`.
3.  Klik kanan pada file `Info.plist` dan pilih **Open As > Source Code**.
4.  Temukan kunci `CFBundleName` dan ubah nilainya menjadi `$(APP_DISPLAY_NAME)`.
5.  Temukan kunci `CFBundleIdentifier` dan ubah nilainya menjadi `$(PRODUCT_BUNDLE_IDENTIFIER)`.

File Anda akan terlihat seperti ini:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- ... Kunci lainnya ... -->

    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleName</key>
    <string>$(APP_DISPLAY_NAME)</string>

    <!-- ... Kunci lainnya ... -->
</dict>
</plist>
```
6. Simpan file (`Cmd + S`).

### Langkah 7: Jalankan Flavor Anda
Selesai! Sekarang Anda dapat membangun atau menjalankan flavor spesifik dari terminal.

Contoh:
```bash
# Menjalankan flavor 'seepays' di simulator/perangkat
flutter run --flavor seepays

# Membangun aplikasi iOS (IPA) untuk flavor 'payku'
flutter build ipa --flavor payku
```

Anda juga dapat memilih *scheme* yang berbeda langsung dari Xcode untuk menjalankan atau mengarsipkannya.
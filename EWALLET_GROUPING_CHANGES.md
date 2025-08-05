# Perubahan Pengelompokan E-Wallet

## Masalah
Sebelumnya, menu e-wallet seperti LinkAja, ShopeePay, dan OVO ditampilkan sebagai item terpisah di halaman "Pilih Metode Pembayaran", membuat tampilan terpecah-pecah dan tidak rapi.

## Solusi
Telah dilakukan modifikasi pada file `lib/Products/mykonterr/layout/topup.dart` untuk mengelompokkan semua metode e-wallet menjadi satu kategori "E-Wallet".

## Perubahan yang Dilakukan

### 1. Menambahkan List Baru
```dart
List<PaymentModel> groupedPayment = [];
```

### 2. Membuat Fungsi Pengelompokan
```dart
void groupPaymentMethods() {
  groupedPayment = [];
  
  // Add non-ewallet methods
  for (PaymentModel payment in listPayment) {
    if (payment.type != 7) { // Exclude individual e-wallet items
      groupedPayment.add(payment);
    }
  }
  
  // Add grouped e-wallet if there are any e-wallet items
  List<PaymentModel> ewalletItems = listPayment.where((p) => p.type == 7).toList();
  if (ewalletItems.isNotEmpty) {
    PaymentModel groupedEwallet = PaymentModel(
      id: 'ewallet_group',
      type: 7,
      title: 'E-Wallet',
      icon: 'assets/img/payuni2/wallet.svg',
      description: 'Deposit menggunakan berbagai e-wallet (LinkAja, OVO, ShopeePay, dll)',
      channel: 'ewallet',
      admin: null,
    );
    groupedPayment.add(groupedEwallet);
  }
}
```

### 3. Menambahkan Support untuk Icon SVG
```dart
child: mm.icon.isNotEmpty
    ? mm.icon.startsWith('assets/')
        ? Padding(
            padding: EdgeInsets.all(10.0),
            child: SvgPicture.asset(
              mm.icon,
              width: 40.0,
              color: Theme.of(context).primaryColor,
            ))
        : Padding(
            padding: EdgeInsets.all(10.0),
            child: CachedNetworkImage(
              imageUrl: mm.icon,
              width: 40.0,
            ))
    : Icon(Icons.list),
```

### 4. Menggunakan List yang Dikelompokkan
```dart
itemCount: groupedPayment.length,
itemBuilder: (_, int index) {
  PaymentModel mm = groupedPayment[index];
  // ...
}
```

## Hasil
Sekarang menu e-wallet akan ditampilkan sebagai satu item "E-Wallet" yang ketika diklik akan membuka halaman e-wallet yang menampilkan semua opsi e-wallet yang tersedia (LinkAja, OVO, ShopeePay, dll).

## File yang Dimodifikasi
- `lib/Products/mykonterr/layout/topup.dart`

## Dependencies yang Ditambahkan
- `flutter_svg` (sudah ada di project) 
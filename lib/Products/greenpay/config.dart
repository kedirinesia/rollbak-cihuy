// @dart=2.9

import 'package:mobile/Products/greenpay/layout/detail-deposit.dart';
import 'package:mobile/Products/greenpay/layout/home.dart';
import 'package:mobile/Products/greenpay/layout/kirim-saldo.dart';
import 'package:mobile/Products/greenpay/layout/topup.dart';
import 'package:mobile/models/deposit.dart';

String sigVendor = '602ddd051d4e77bf18a278bb';

const namaApp = 'Greenpay';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'com.payuni.greenpay';
String brandId;
String copyRight = '';
int templateCode = 3;
String gaId = '';
// String apiUrl = 'https://app.popay.id/api/v1';
String apiUrl = 'http://192.168.48.100:8089/api/v1';
String apiUrlKasir = 'https://api-pos.payuni.co.id/api/v1';
String liveChat = '';
int otpCount = 4;
int pinCount = 4;
bool limitPinLogin = false;
bool autoReload = false;
bool isKasir = false;
bool isMarketplace = false;
bool realtimePrepaid = false;
bool enableMultiChannel = false;

Map<String, String> assetGambar = {
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321',
  'iconProfile':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e',
  'logoPrinter':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Frsz_1rsz_photo_1536510356016.png?alt=media&token=e36a8c56-6414-4f08-9a6e-eaa314ddcc75',
  // 'imageHeader':'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2FBackground%20(2).png?alt=media&token=4c3bf7cc-f40a-497a-b316-470759bbddad',
  'imageHeader':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2FBackground%20(2).png?alt=media&token=4c3bf7cc-f40a-497a-b316-470759bbddad',
  'imageAppbar':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2FBackground%20(3).png?alt=media&token=2e82d294-ba03-49a8-8dea-9cc8b97fb81a',
  'logoApp':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Frsz_1rsz_photo_1536510356016.png?alt=media&token=e36a8c56-6414-4f08-9a6e-eaa314ddcc75',
  'backgroundStruk':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Ficons%2Fprint.png?alt=media&token=916f8a47-fd66-42e4-8270-d9736caebf57',
};

Map<String, dynamic> layout = {
  'home': HomeGreenpay(),
  'topup': TopupPage(),
  'transfer': KirimSaldo(),
  'detail-deposit': (DepositModel d) => DetailDeposit(d)
};

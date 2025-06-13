// @dart=2.9

import 'package:mobile/Products/apkpulsa2/layout/detail-deposit.dart';
import 'package:mobile/Products/apkpulsa2/layout/home.dart';
import 'package:mobile/Products/apkpulsa2/layout/kirim-saldo.dart';
import 'package:mobile/Products/apkpulsa2/layout/login.dart';
import 'package:mobile/Products/apkpulsa2/layout/topup.dart';
import 'package:mobile/models/deposit.dart';

String sigVendor = '608ee35e8abfba47fcbfa23c';

const namaApp = 'APK PULSA';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'mobile.apkpulsa';
String brandId;
String copyRight = '';
int templateCode = 3;
String gaId = '';
String apiUrl = 'https://fupulsa-app.findig.id/api/v1';
String apiUrlKasir = 'https://api-pos.fupulsa.com/api/v1';
String liveChat = 'https://tawk.to/chat/615e7d5125797d7a8902b891/1fhchj1pe';
// String liveChat = 'https://tawk.to/chat/5e6553b38d24fc2265866fdd/default';
int otpCount = 4;
int pinCount = 4;
bool limitPinLogin = false;
bool autoReload = false;
bool isKasir = true;
bool isMarketplace = true;
bool realtimePrepaid = false;
bool enableMultiChannel = false;

Map<String, String> assetGambar = {
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321',
  'iconProfile':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e',
  'logoPrinter':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Ficons%2FPhoto_1536510356016-1%20(1).png?alt=media&token=3853ec11-ed0a-4cc0-8e6e-579824373ae1',
  'imageHeader': 'https://fupulsa.com/img/headerbg1.png',
  'imageAppbar': 'https://fupulsa.com/img/background.png',
  // 'backgroundStruk': 'https://www.payuni.co.id/struk.png',
};

Map<String, dynamic> layout = {
  'home': HomeBlibli(),
  'topup': TopupPage(),
  'transfer': KirimSaldo(),
  'login': LoginPage(),
  'detail-deposit': (DepositModel d) => DetailDeposit(d)
};

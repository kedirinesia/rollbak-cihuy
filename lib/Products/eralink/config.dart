// @dart=2.9

import 'package:mobile/Products/eralink/layout/index.dart';
import 'package:mobile/Products/eralink/layout/detail-deposit.dart';
import 'package:mobile/Products/eralink/layout/login.dart';
import 'package:mobile/Products/eralink/layout/qris.dart';
import 'package:mobile/Products/eralink/layout/topup/topup.dart';
import 'package:mobile/models/deposit.dart';

String sigVendor = '5f70c07c57b282070a1486a1';

const namaApp = 'EraLinK';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'com.eralink.mobileapk';
String brandId;
String copyRight = 'EraLinK';
int templateCode = 4;
String gaId = '';
String apiUrl = 'https://eralink-app.findig.id/api/v1';
String liveChat = 'https://tawk.to/chat/618639c26885f60a50ba94be/1fjq538qa';
int otpCount = 4;
int pinCount = 4;
bool gangguanDisplay = true;
bool qrisStaticOnTopup = true;
bool limitPinLogin = false;
bool autoReload = false;
bool isKasir = false;
bool isMarketplace = false;
bool realtimePrepaid = false;
bool enableMultiChannel = false;
String apiUrlKasir = 'https://api-pos.payuni.co.id/api/v1';

Map<String, String> assetGambar = {
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321',
  'iconProfile':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e',
  'logoPrinter':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Ficons%2FPhoto_1536510356016-1%20(1).png?alt=media&token=3853ec11-ed0a-4cc0-8e6e-579824373ae1',
  'logoLogin':
      'https://dokumen.payuni.co.id/logo/centralbayar/rebranding/IconLoginbaru.png',
  'logoLoginHeader':
      'https://dokumen.payuni.co.id/logo/centralbayar/rebranding/iconhome.png'
};

Map<String, dynamic> layout = {
  'login': LoginPage(),
  'home': CentralBayarHome(),
  'detail-deposit': (DepositModel d) => DetailDeposit(d),
  'qris-static': MyQrisPage(),
  'topup': TopupPage(),
};

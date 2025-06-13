// @dart=2.9

import 'package:mobile/Products/eazyin/layout/index.dart';
import 'package:mobile/Products/eazyin/layout/login.dart';

String sigVendor = '612d1c569810aed60f160d91';

const namaApp = 'Eazyin2';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'com.eazyin.mobile';
String brandId;
String copyRight = '';
int templateCode = 4;
String gaId = '';
String apiUrl = 'https://eazyin-app.findig.id/api/v1';
String liveChat = '';
int otpCount = 4;
int pinCount = 4;
bool limitPinLogin = false;
bool autoReload = false;
bool isKasir = true;
bool isMarketplace = false;
bool realtimePrepaid = false;
bool enableMultiChannel = false;
String apiUrlKasir = 'https://api-kasir.eazyin.co.id/api/v1';

Map<String, String> assetGambar = {
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321',
  'iconProfile':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e',
  'logoPrinter':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Ficons%2FPhoto_1536510356016-1%20(1).png?alt=media&token=3853ec11-ed0a-4cc0-8e6e-579824373ae1',
  'logoLogin': 'https://dokumen.payuni.co.id/logo/eazyin/login.png'
};

Map<String, dynamic> layout = {
  'home': EpulsaHome(),
  'login': LoginPage(),
};

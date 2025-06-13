// @dart=2.9

import 'package:mobile/Products/emobile/layout/main.dart';

String sigVendor = '5f964bb2e355c61014abc79c';

const namaApp = 'E-mobile';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'id.emobile.app';
String brandId;
String copyRight = '';
int templateCode = 4;
String gaId = '';
String apiUrl = 'https://app.emobile.id/api/v1';
String liveChat = 'https://tawk.to/chat/5f93fe9b2915ea4ba0965971/default';
int otpCount = 6;
int pinCount = 6;
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
  'imageHeader':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2FEMOBILE%2Fmobile.png?alt=media&token=a107b0cb-d1f5-414c-a20b-6b273b7442c0',
  'imageAppbar':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2FEMOBILE%2FFrame%201%20(11).png?alt=media&token=963d659f-833e-4fdb-8ff9-342158f3ee47',
  'logoLogin':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2FEMOBILE%2Frsz_logologin.png?alt=media&token=30611d10-21b8-4093-a2ff-033952cf627f',
  'logoLoginHeader':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2FEMOBILE%2Frsz_logoemobile_1.png?alt=media&token=f2eee6a2-8e17-4b1e-8b41-9bea0295164f'
};

Map<String, dynamic> layout = {
  'home': HomePopay(),
};

// @dart=2.9

import 'package:mobile/Products/maripay/layout/index.dart';

String sigVendor = '6117aa5e09db9218805ede63';

const namaApp = 'Mari Pay';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'com.maripay.app';
String brandId;
String copyRight = '';
int templateCode = 4;
String gaId = '';
String apiUrl = 'https://maripay-app.findig.id/api/v1';
String liveChat = 'https://tawk.to/chat/611a38e9649e0a0a5cd157b2/1fd76skd7';
int otpCount = 4;
int pinCount = 4;
bool limitPinLogin = false;
bool autoReload = false;
bool isKasir = true;
bool isMarketplace = true;
bool realtimePrepaid = false;
bool enableMultiChannel = false;
String apiUrlKasir = 'https://api-kasir.maripay.co.id/api/v1';

Map<String, String> assetGambar = {
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321',
  'iconProfile':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e',
  'logoPrinter':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Ficons%2FPhoto_1536510356016-1%20(1).png?alt=media&token=3853ec11-ed0a-4cc0-8e6e-579824373ae1',
  'logoLogin': 'http://maripay.co.id/images/logologin.png'
};

Map<String, dynamic> layout = {
  'home': EpulsaHome(),
};

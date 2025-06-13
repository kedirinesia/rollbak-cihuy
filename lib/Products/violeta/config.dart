// @dart=2.9

import 'package:mobile/Products/violeta/layout/login.dart';

String sigVendor = '6451ffc78fefa1d2622e524f';

const namaApp = 'Violeta Pedia';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'id.violetapedia.mobile';
String brandId;
String copyRight = '';
int templateCode = 3;
String gaId = '';
String apiUrl = 'https://app.payuni.co.id/api/v1';
String liveChat = 'https://tawk.to/chat/6452052531ebfa0fe7fbae35/1gvg687hp';
int otpCount = 4;
int pinCount = 4;
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
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e'
};

Map<String, dynamic> layout = {
  'login': LoginPage(),
};

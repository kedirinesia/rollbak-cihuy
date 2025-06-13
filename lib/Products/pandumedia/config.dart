// @dart=2.9

import 'package:mobile/Products/pandumedia/layout/main.dart';

String sigVendor = '604ed5b9aad5028c91f3d925';

const namaApp = 'Pandumedia';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'com.pandumedia.app';
String brandId;
String copyRight = '';
int templateCode = 6;
String gaId = '';
String apiUrl = 'https://pandumedia-app.findig.id/api/v1';
String apiUrlKasir = 'https://api-pos.pandumedia.id/api/v1';
String liveChat = 'https://tawk.to/chat/60541306067c2605c0ba0f02/1f146kkj9';
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
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e'
};

Map<String, dynamic> layout = {
  'home': PakaiAjaHome(),
};

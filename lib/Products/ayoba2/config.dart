// @dart=2.9

import 'package:mobile/Products/ayoba2/layout/main.dart';

String sigVendor = '60b7436033d9ef1b58ee1f3b';

const namaApp = 'Ayoba';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'ayoba.co.id';
String brandId;
String copyRight = '';
int templateCode = 6;
String gaId = '';
String apiUrl = 'https://ayoba-app.findig.id/api/v1';
String apiUrlKasir = '';
String liveChat = 'https://tawk.to/chat/60b7c30d6699c7280daa5d35/1f76t3s1q';
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
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e'
};

Map<String, dynamic> layout = {
  'home': PakaiAjaHome(),
};

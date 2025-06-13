// @dart=2.9

import 'package:mobile/Products/ecuan/layout/index.dart';

String sigVendor = '5e577a000efa1b22beabf8dd';

const namaApp = 'E-Cuan';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'com.ecuan.mobile';
String brandId;
String copyRight = '';
int templateCode = 1;
String gaId = '';
String apiUrl = 'http://ecuan-app.findig.id/api/v1';
String liveChat = 'https://tawk.to/chat/5e5f1d8ac32b5c1917396b24/default';
int otpCount = 4;
int pinCount = 4;
bool limitPinLogin = true;
bool autoReload = false;
bool isKasir = false;
bool isMarketplace = true;
bool realtimePrepaid = false;
bool enableMultiChannel = false;
String apiUrlKasir = 'https://api-pos.payuni.co.id/api/v1';

Map<String, String> assetGambar = {
  'texture': 'https://dokumen.payuni.co.id/logo/ecuan/texture.png',
  'logoLogin': 'https://dokumen.payuni.co.id/logo/ecuan/logodashboard.png',
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321',
  'iconProfile':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e',
  'imageHeader': 'https://dokumen.payuni.co.id/logo/ecuan/topup.png',
};

Map<String, dynamic> layout = {
  'home': SarinuHome(),
};

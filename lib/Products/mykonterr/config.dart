// @dart=2.9

import 'package:mobile/Products/mykonterr/layout/home.dart';
import 'package:mobile/Products/mykonterr/layout/splash.dart';
import 'package:mobile/Products/mykonterr/layout/onboarding.dart';

String sigVendor = '63a54d23c04ce7c61d034e23';

const namaApp = 'MyKonter';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'id.mykonter.app';
String brandId;
String copyRight = '';
int templateCode = 3;
String gaId = '';
String apiUrl = 'https://app-mykonter.findig.id/api/v1';
String liveChat = 'https://tawk.to/chat/63a56035daff0e1306de04c5/1gkuvvkk1';
int otpCount = 4;
int pinCount = 4;
bool limitPinLogin = false;
bool autoReload = false;
bool isKasir = false;
bool isMarketplace = false;
bool realtimePrepaid = false;
bool enableMultiChannel = false;
bool gangguanDisplay = true;
String apiUrlKasir = 'https://api-pos.payuni.co.id/api/v1';

Map<String, String> assetGambar = {
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321',
  'iconProfile':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e',
  'logoApp': 'https://dokumen.payuni.co.id/logo/mykonter/custom/logo.png',
};

Map<String, dynamic> layout = {
  'home': HomeBlibli(),
  'login': OnBoardingScreen(),
  'splash': SplashScreen(),
};

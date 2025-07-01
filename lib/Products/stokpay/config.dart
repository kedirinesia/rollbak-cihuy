// @dart=2.9

import 'package:mobile/Products/stokpay/layout/home.dart';
import 'package:mobile/Products/stokpay/layout/login.dart';

String sigVendor = '608296573f885ade2acd09d1';

const namaApp = 'Stokpay';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'app.stokpay.com';
String brandId;
String copyRight = 'Stokpay';
int templateCode = 2;
String gaId = '';
String apiUrl = 'https://app.payuni.co.id/api/v1';
// String liveChat = 'https://tawk.to/chat/60827b315eb20e09cf35cf5a/1f3ur2f95';
String liveChat = '';
int otpCount = 4;
int pinCount = 4;
bool limitPinLogin = false;
bool autoReload = false;
bool isKasir = true;
bool isMarketplace = false;
bool realtimePrepaid = false;
bool enableMultiChannel = false;
String apiUrlKasir = 'https://api-kasir.stokpay.com/api/v1';

Map<String, String> assetGambar = {
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321',
  'iconProfile':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e',
  'logoLogin': 'http://img.stokpay.com/logo/login.png',
  'imageHeader': 'http://img.stokpay.com/logo/profile.png',
};

Map<String, dynamic> layout = {
  'home': HomeStokpay(),
  'login': LoginPage(),
};

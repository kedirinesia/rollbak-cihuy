// @dart=2.9

import 'package:mobile/Products/outlet/layout/index.dart';

String sigVendor = '63db2cb02200a001b19f2624';

const namaApp = 'OUTLET PAYMENT';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'id.outletpay.mobile';
String brandId;
String copyRight = '';
int templateCode = 4;
String gaId = '';
String apiUrl = 'https://outletpay-app.findig.id/api/v1';
String liveChat = 'https://tawk.to/chat/6312366954f06e12d8926826/1gbvi9405';
int otpCount = 4;
int pinCount = 4;
bool gangguanDisplay = true;
bool qrisStaticOnTopup = true;
bool dynamicFooterStruk = true;
bool limitPinLogin = false;
bool autoReload = false;
bool isKasir = false;
bool isMarketplace = false;
bool realtimePrepaid = true;
bool enableMultiChannel = false;
String apiUrlKasir = 'https://api-pos.payuni.co.id/api/v1';

Map<String, String> assetGambar = {
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321',
  'iconProfile': 'https://dokumen.payuni.co.id/logo/outlet/logoProfile.png',
  'logoPrinter':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Ficons%2FPhoto_1536510356016-1%20(1).png?alt=media&token=3853ec11-ed0a-4cc0-8e6e-579824373ae1',
  'logoLogin': 'https://dokumen.payuni.co.id/logo/outlet/loginNew.png',
  // 'logoApp': 'https://dokumen.payuni.co.id/logo/outlet/logoWhite.png',
  // 'logoApp': 'https://dokumen.payuni.co.id/logo/outlet/splash1.jpeg',
};

Map<String, dynamic> layout = {
  // 'login': StartWizardPage(),
  'home': EpulsaHome(),
  // 'splash': SplashPopay()
};

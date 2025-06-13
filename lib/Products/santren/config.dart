// @dart=2.9

import 'package:mobile/Products/santren/layout/index.dart';
import 'package:mobile/Products/santren/layout/splash.dart';
import 'package:mobile/Products/santren/layout/wizard.dart';

String sigVendor = '66f3c061b83af34d76ec85e3';

const namaApp = 'SantrenPay';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'com.santrenpay.mobile';
String brandId;
String copyRight = '';
int templateCode = 4;
String gaId = '';
String apiUrl = 'https://santren-app.findig.id/api/v1';
String liveChat = 'https://tawk.to/chat/6765567449e2fd8dfefad80a/1ifhtjf15';
int otpCount = 4;
int pinCount = 4;
bool limitPinLogin = false;
bool autoReload = false;
bool isKasir = true;
bool isMarketplace = false;
bool gangguanDisplay = true;
bool realtimePrepaid = false;
bool enableMultiChannel = false;
String apiUrlKasir = 'https://santren-kasir.findig.id/api/v1';

Map<String, String> assetGambar = {
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321',
  'iconProfile':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e',
  'logoPrinter':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Ficons%2FPhoto_1536510356016-1%20(1).png?alt=media&token=3853ec11-ed0a-4cc0-8e6e-579824373ae1',
  'logoLogin': 'https://dokumen.payuni.co.id/logo/santren/santrenregister.png',
  'logo': 'https://dokumen.payuni.co.id/logo/santren/loginpage.png',
};

Map<String, dynamic> layout = {
  'splash': SplashPage(),
  'login': StartWizardPage(),
  'home': EpulsaHome(),
};

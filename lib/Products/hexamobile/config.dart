// @dart=2.9

import 'package:mobile/Products/hexamobile/layout/detail-deposit.dart';
import 'package:mobile/Products/hexamobile/layout/login.dart';
import 'package:mobile/Products/hexamobile/layout/main.dart';
import 'package:mobile/Products/hexamobile/layout/splash.dart';
import 'package:mobile/Products/hexamobile/layout/topup.dart';
import 'package:mobile/models/deposit.dart';

String sigVendor = '65ba4519b78f35f24d80dd57';

const namaApp = 'HEXAMOBILE';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'com.hexamobile.androidapp';
String brandId;
String copyRight = '';
int templateCode = 6;
String gaId = '';
String apiUrl = 'https://hexapay-app.findig.id/api/v1';
String apiUrlKasir = 'https://hexa-kasir.findig.id/api/v1';
String liveChat = 'https://tawk.to/chat/65ba493c8d261e1b5f59fac3/1hlfqs5h2';
int otpCount = 4;
int pinCount = 4;
bool limitPinLogin = false;
bool autoReload = false;
bool isKasir = true;
bool isMarketplace = true;
bool realtimePrepaid = false;
bool enableMultiChannel = false;
bool gangguanDisplay = true;
bool dynamicFooterStruk = false;

Map<String, String> assetGambar = {
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321',
  'iconProfile':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e',
  'logoPrinter':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Ficons%2FPhoto_1536510356016-1%20(1).png?alt=media&token=3853ec11-ed0a-4cc0-8e6e-579824373ae1',
  'imageHeader': 'https://dokumen.payuni.co.id/logo/hexapay/newAppbar.png',
  'imageAppbar': 'https://dokumen.payuni.co.id/logo/hexapay/newNavbar.png',
  // 'logoLogin': 'https://dokumen.payuni.co.id/logo/hexapay/logopanjangkencil.png',
  'logoApp': 'https://dokumen.payuni.co.id/logo/hexapay/new/splashscreen.png',
};

Map<String, dynamic> layout = {
  'login': LoginPage(),
  'home': PakaiAjaHome(),
  'topup': TopupPage(),
  'detail-deposit': (DepositModel d) => DetailDeposit(d),
  'splash': SplashPopay()
};

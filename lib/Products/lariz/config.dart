// @dart=2.9

import 'package:mobile/Products/lariz/layout/detail-deposit.dart';
import 'package:mobile/Products/lariz/layout/kirim-saldo.dart';
import 'package:mobile/Products/lariz/layout/navbar.dart';
import 'package:mobile/Products/lariz/layout/splash.dart';
import 'package:mobile/Products/lariz/layout/topup.dart';
import 'package:mobile/Products/lariz/layout/wizard/wizard.dart';
import 'package:mobile/models/deposit.dart';

String sigVendor = '651cd60072226b263de5b0c6';

const namaApp = 'Lariz';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'com.lariz.mobile';
String brandId;
String copyRight = '';
int templateCode = 3;
String gaId = '';
String apiUrl = 'https://mba-app.findig.id/api/v1';
String liveChat = 'https://tawk.to/chat/650bf14b0f2b18434fd9b93f/1harad47d';
int otpCount = 4;
int pinCount = 4;
bool limitPinLogin = false;
bool autoReload = false;
bool isKasir = false;
bool isMarketplace = false;
bool realtimePrepaid = false;
bool enableMultiChannel = false;
bool gangguanDisplay = true;
bool dynamicFooterStruk = true;
String apiUrlKasir = 'https://api-pos.payuni.co.id/api/v1';

Map<String, String> assetGambar = {
  // 'texture': 'https://sarinupay.com/images/texture/soft-texture.png',
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321',
  'iconProfile':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e',
  'logoPrinter':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Ficons%2FPhoto_1536510356016-1%20(1).png?alt=media&token=3853ec11-ed0a-4cc0-8e6e-579824373ae1',
  'imageHeader':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpayku%2FPaykuDown.png?alt=media&token=f255e74b-527a-4231-aa56-02363ba73a3a',
  'imageAppbar':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpayku%2FPaykuDown.png?alt=media&token=f255e74b-527a-4231-aa56-02363ba73a3a',
  'imgAppBar': 'https://dokumen.payuni.co.id/icon/mbaid/MBR.png',
  // 'backgroundStruk':
  //     'https://dokumen.payuni.co.id/icon/payku/logocetakstruk.png',
  'logoLogin': 'https://dokumen.payuni.co.id/icon/mbaid/logoweb2.png',
  'logoApp': 'https://dokumen.payuni.co.id/icon/mbaid/splass.png',
};

Map<String, dynamic> layout = {
  'login': IntroScreen(),
  'home': NavbarHome(),
  'topup': TopupPage(),
  'transfer': KirimSaldo(),
  'detail-deposit': (DepositModel d) => DetailDeposit(d),
  'splash': SplashPopay()
};

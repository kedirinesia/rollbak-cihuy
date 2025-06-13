// @dart=2.9

import 'dart:io' show Platform;
import 'package:mobile/Products/paysri/layout/detail-deposit.dart';
import 'package:mobile/Products/paysri/layout/home.dart';
import 'package:mobile/Products/paysri/layout/kirim-saldo.dart';
import 'package:mobile/Products/paysri/layout/splash.dart';
import 'package:mobile/Products/paysri/layout/topup.dart';
import 'package:mobile/models/deposit.dart';

// String sigVendor = '5e523bf7ae1e375162506db7';
String sigVendor = '5ea5b8727ab56e2719bdd3c6';

const namaApp = 'PaySri';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'co.paysri.id';
String brandId;
String copyRight = '';
int templateCode = 3;
String gaId = '';
String apiUrl = 'https://app.popay.id/api/v1';
// String apiUrl = 'http://192.168.1.58:8089/api/v1';
String liveChat = 'https://tawk.to/chat/5f032000760b2b560e6fd3bc/default';
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
  // 'backgroundStruk':
  //     'https://dokumen.payuni.co.id/icon/payku/logocetakstruk.png',
  'logoLogin': 'https://img.paysri.id/wp-content/uploads/logo-paysri-2023-web-report-456.png',
  // 'logoApp': 'https://dokumen.payuni.co.id/logo/payku/splash1.png',
};

Map<String, dynamic> layout = {
  'home': HomePopay(),
  'topup': TopupPage(),
  'transfer': KirimSaldo(),
  'detail-deposit': (DepositModel d) => DetailDeposit(d),
  // 'splash': SplashPopay()
};

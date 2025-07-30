// @dart=2.9

import 'package:mobile/Products/ampedia/layout/detail-deposit.dart';
import 'package:mobile/Products/ampedia/layout/home.dart';
import 'package:mobile/Products/ampedia/layout/kirim-saldo.dart';
import 'package:mobile/Products/ampedia/layout/topup/topup.dart';
import 'package:mobile/models/deposit.dart';

// String sigVendor = '5e523bf7ae1e375162506db7';
String sigVendor = '63c4c9d6aa60a81e28bae34d';

const namaApp = 'AM Pedia';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'com.ampedia.mobile';
String brandId;
String copyRight = '';
int templateCode = 3;
String gaId = '';
String apiUrl = 'https://app.popay.id/api/v1';
// String apiUrl = 'http://192.168.1.58:8089/api/v1';
String liveChat = 'https://tawk.to/chat/6479abaead80445890f09b33/1h1tkd9b7';
int otpCount = 4;
int pinCount = 6;
bool limitPinLogin = false;
bool autoReload = false;
bool isKasir = true;
bool isMarketplace = false;
bool boldNomorTujuan = false;
bool qrisStaticOnTopup = false;
bool enableMultiChannel = false;
bool realtimePrepaid = true;
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
  'imageHeader': 'https://dokumen.payuni.co.id/logo/ampedia/appbar.png',
  'imageAppbar': 'https://dokumen.payuni.co.id/logo/ampedia/ampedia.png',
  // 'backgroundStruk':
  //     'https://dokumen.payuni.co.id/icon/payku/logocetakstruk.png',
  'logoLogin': 'https://dokumen.payuni.co.id/logo/ampedia/logodash.png',
  // 'logoApp': 'https://dokumen.payuni.co.id/logo/payku/splash1.png',
};

Map<String, dynamic> layout = {
  'home': HomePopay(),
  'topup': TopupPage(),
  'transfer': KirimSaldo(),
  'detail-deposit': (DepositModel d) => DetailDeposit(d),
  // 'splash': SplashPopay()
};

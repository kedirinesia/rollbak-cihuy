// @dart=2.9

import 'package:mobile/Products/pdpay/layout/detail-deposit.dart';
import 'package:mobile/Products/pdpay/layout/home.dart';
import 'package:mobile/Products/pdpay/layout/kirim-saldo.dart';
import 'package:mobile/Products/pdpay/layout/login.dart';
import 'package:mobile/Products/pdpay/layout/topup.dart';
import 'package:mobile/models/deposit.dart';

String sigVendor = '6071795c84d3cca10c0de2d8';

const namaApp = 'PDPay';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'pdpay.id';
String brandId;
String copyRight = '';
int templateCode = 3;
String gaId = '';
String apiUrl = 'https://pdpay-app.findig.id/api/v1';
String apiUrlKasir = 'https://api-pos.pdpay.id/api/v1';
String liveChat = 'https://tawk.to/chat/605dc230f7ce182709343232/1f1n3t3na';
// String liveChat = 'https://tawk.to/chat/5e6553b38d24fc2265866fdd/default';
int otpCount = 4;
int pinCount = 4;
bool limitPinLogin = false;
bool autoReload = false;
bool isKasir = true;
bool isMarketplace = true;
bool realtimePrepaid = false;
bool enableMultiChannel = false;

Map<String, String> assetGambar = {
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321',
  'iconProfile':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e',
  'logoPrinter':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Ficons%2FPhoto_1536510356016-1%20(1).png?alt=media&token=3853ec11-ed0a-4cc0-8e6e-579824373ae1',
  'imageHeader': 'https://pdpay.id/images/headerbg.png',
  'imageAppbar': 'https://pdpay.id/images/appbar.png',
  // 'backgroundStruk': 'https://www.payuni.co.id/struk.png',
};

Map<String, dynamic> layout = {
  'home': HomeBlibli(),
  'topup': TopupPage(),
  'transfer': KirimSaldo(),
  'login': LoginPage(),
  'detail-deposit': (DepositModel d) => DetailDeposit(d)
};

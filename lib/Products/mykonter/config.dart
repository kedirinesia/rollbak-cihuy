// @dart=2.9

import 'package:mobile/Products/mykonter/layout/detail-deposit.dart';
import 'package:mobile/Products/mykonter/layout/home.dart';
import 'package:mobile/Products/mykonter/layout/kirim-saldo.dart';
import 'package:mobile/Products/mykonter/layout/login.dart';
import 'package:mobile/Products/mykonter/layout/register.dart';
import 'package:mobile/Products/mykonter/layout/topup.dart';
import 'package:mobile/models/deposit.dart';

String sigVendor = '6020d385a8c2995589dcd20c';

const namaApp = 'MyKonter';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'mykonter.id';
String brandId;
String copyRight = '';
int templateCode = 3;
String gaId = '';
String apiUrl = 'https://mykonter-app.findig.id/api/v1';
// String apiUrl = 'http://192.168.43.170:8089/api/v1';
String apiUrlKasir = 'https://api-kasir.mykonter.id/api/v1';
String liveChat = 'https://tawk.to/chat/600a8a62c31c9117cb714e87/1eskip4db';
// String liveChat = 'https://tawk.to/chat/5e6553b38d24fc2265866fdd/default';
int otpCount = 4;
int pinCount = 4;
bool limitPinLogin = false;
bool autoReload = false;
bool isKasir = true;
bool isMarketplace = true;
bool realtimePrepaid = true;
bool enableMultiChannel = true;

Map<String, String> assetGambar = {
  'logo': 'https://mykonter.id/images/logo.png',
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321',
  'iconProfile':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e',
  'logoPrinter':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Ficons%2FPhoto_1536510356016-1%20(1).png?alt=media&token=3853ec11-ed0a-4cc0-8e6e-579824373ae1',
  'imageHeader': 'https://www.payuni.co.id/img/headerbg.png',
  'imageAppbar': 'https://www.payuni.co.id/img/appbar.png'
};

Map<String, dynamic> layout = {
  'home': HomePopay(),
  'topup': TopupPage(),
  'transfer': KirimSaldo(),
  'detail-deposit': (DepositModel d) => DetailDeposit(d),
  'login': LoginPage(),
  'register': RegisterPage(),
};

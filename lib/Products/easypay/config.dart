// @dart=2.9

import 'package:mobile/Products/easypay/layout/detail-deposit.dart';
import 'package:mobile/Products/easypay/layout/home.dart';
import 'package:mobile/Products/easypay/layout/kirim-saldo.dart';
import 'package:mobile/Products/easypay/layout/topup.dart';
import 'package:mobile/models/deposit.dart';

String sigVendor = '5fc39b050f3c2e898a23ab6e';

const namaApp = 'Easy Payment';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'easypayment.co.id';
String brandId;
String copyRight = '';
int templateCode = 3;
String gaId = 'UA-192310208-1';
String apiUrl = 'https://easypay-app.findig.id/api/v1';
String apiUrlKasir = 'https://api-kasir.easypayment.co.id/api/v1';
// String apiUrl = 'http://192.168.43.170:8089/api/v1';
// String apiUrlKasir = 'http://192.168.43.170:8082/api/v1';
String liveChat = 'https://tawk.to/chat/5fd8b504df060f156a8d461e/1epj866l8';
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
  'imageHeader': 'https://dokumen.payuni.co.id/icon/easypay/headbar.png',
  'imageAppbar': 'https://dokumen.payuni.co.id/icon/easypay/appbar.png'
};

Map<String, dynamic> layout = {
  'home': HomePopay(),
  'topup': TopupPage(),
  'transfer': KirimSaldo(),
  'detail-deposit': (DepositModel d) => DetailDeposit(d)
};

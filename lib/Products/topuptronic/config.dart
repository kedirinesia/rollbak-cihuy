// @dart=2.9

import 'dart:io' show Platform;
import 'package:mobile/Products/topuptronic/layout/detail-deposit.dart';
import 'package:mobile/Products/topuptronic/layout/home.dart';
import 'package:mobile/Products/topuptronic/layout/kirim-saldo.dart';
import 'package:mobile/Products/topuptronic/layout/topup.dart';
import 'package:mobile/models/deposit.dart';

String sigVendor = '5fb7e80ab753a627e2648cad';

const namaApp = 'Topuptronic Digital Payment';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'com.topdipay.apk';
String brandId;
String copyRight = '';
int templateCode = 6;
String gaId = '';
String apiUrl = 'https://topdipay-app.findig.id/api/v1';
String apiUrlKasir = 'https://kasir.payuni.co.id/api/v1';
String liveChat = 'https://tawk.to/chat/5fb7e7f6920fc91564c9049a/default';
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
  'imageHeader':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2FTopup%20Tronik%2Ftopup.png?alt=media&token=fa9fde6f-bfae-40be-855a-00f91d7d1c31',
  'imageAppbar':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2FTopup%20Tronik%2Ftopup1.png?alt=media&token=f561b9e9-214a-4b4b-a6ab-8e112f050dc4'
};

Map<String, dynamic> layout = {
  'home': HomePopay(),
  'topup': TopupPage(),
  'transfer': KirimSaldo(),
  'detail-deposit': (DepositModel d) => DetailDeposit(d)
};

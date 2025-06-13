// @dart=2.9

import 'dart:io' show Platform;
import 'package:mobile/Products/cuanplus/layout/detail-deposit.dart';
import 'package:mobile/Products/cuanplus/layout/home.dart';
import 'package:mobile/Products/cuanplus/layout/kirim-saldo.dart';
import 'package:mobile/Products/cuanplus/layout/topup.dart';
import 'package:mobile/models/deposit.dart';

String sigVendor = '5fb388b276630d18ece55bc7';

const namaApp = 'Cuan Plus';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'com.cuanplus.app';
String brandId;
String copyRight = '';
int templateCode = 3;
String gaId = '';
String apiUrl = 'https://cuanplus-app.findig.id/api/v1';
String apiUrlKasir = 'https://api-pos.payuni.co.id/api/v1';
String liveChat = 'https://tawk.to/chat/5fae505f19a1cc7ca44b6372/default';
// String liveChat = 'https://tawk.to/chat/5e6553b38d24fc2265866fdd/default';
int otpCount = 4;
int pinCount = 4;
bool limitPinLogin = false;
bool autoReload = false;
bool isKasir = false;
bool isMarketplace = false;
bool realtimePrepaid = false;
bool enableMultiChannel = false;
Map<String, String> assetGambar = {
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321',
  'iconProfile':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e',
  'logoPrinter':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Ficons%2FPhoto_1536510356016-1%20(1).png?alt=media&token=3853ec11-ed0a-4cc0-8e6e-579824373ae1',
  'imageHeader': 'https://dokumen.payuni.co.id/logo/cuanplus/headerbg.png',
  'imageAppbar': 'https://dokumen.payuni.co.id/logo/cuanplus/appbar.png'
};

Map<String, dynamic> layout = {
  'home': HomePopay(),
  'topup': TopupPage(),
  'transfer': KirimSaldo(),
  'detail-deposit': (DepositModel d) => DetailDeposit(d)
};

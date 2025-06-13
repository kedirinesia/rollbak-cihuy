// @dart=2.9

import 'dart:io' show Platform;
import 'package:mobile/Products/payuni2/layout/detail_deposit.dart';
import 'package:mobile/Products/payuni2/layout/home.dart';
import 'package:mobile/Products/payuni2/layout/kirim_saldo.dart';
import 'package:mobile/Products/payuni2/layout/topup.dart';
import 'package:mobile/models/deposit.dart';

String sigVendor = '5e7b291771268f3dc3dd73c6';

const namaApp = 'Payuni';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = Platform.isAndroid ? 'mobile.payuni.id' : 'co.payuni.id';
String brandId;
String copyRight = '';
int templateCode = 3;
String gaId = '';
String apiUrl = 'https://payuni-app.findig.id/api/v1';
// String apiUrl = 'https://app.payuni.co.id/api/v1';
// String apiUrl = 'http://192.168.1.38:8089/api/v1';
String apiUrlKasir = 'https://api-pos.payuni.co.id/api/v1';
String liveChat = 'https://tawk.to/chat/5f3f82bc1e7ade5df442bd63/default';
// String liveChat = 'https://tawk.to/chat/5e6553b38d24fc2265866fdd/default';
int otpCount = 4;
int pinCount = 4;
bool limitPinLogin = false;
bool autoReload = false;
bool gangguanDisplay = true;
bool isKasir = true;
bool dynamicFooterStruk = true;
bool isMarketplace = true;
bool realtimePrepaid = true;
bool enableMultiChannel = true;

Map<String, String> assetGambar = {
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321',
  'iconProfile':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e',
  'logoPrinter':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Ficons%2FPhoto_1536510356016-1%20(1).png?alt=media&token=3853ec11-ed0a-4cc0-8e6e-579824373ae1',
  'imageHeader': 'https://dokumen.payuni.co.id/icon/talenta/headbar.png',
  'imageAppbar': 'https://dokumen.payuni.co.id/icon/talenta/appbar.png',
  'backgroundStruk': 'https://www.payuni.co.id/struk.png',
};

Map<String, dynamic> layout = {
  'home': HomePayuni(),
  'topup': TopupPage(),
  'transfer': KirimSaldo(),
  'detail-deposit': (DepositModel d) => DetailDeposit(d)
};

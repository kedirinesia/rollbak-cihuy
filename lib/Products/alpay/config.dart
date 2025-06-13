// @dart=2.9

import 'dart:io' show Platform;
import 'package:mobile/Products/alpay/layout/detail_deposit.dart';
import 'package:mobile/Products/alpay/layout/home.dart';
import 'package:mobile/Products/alpay/layout/kirim_saldo.dart';
import 'package:mobile/Products/alpay/layout/topup.dart';
import 'package:mobile/models/deposit.dart';

String sigVendor = '6371ecf3066c1176f236859a';

const namaApp = 'ALPAY';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'com.alpay.mobile';
String brandId;
String copyRight = '';
int templateCode = 3;
String gaId = '';
String apiUrl = 'https://alpay-app.findig.id/api/v1';
// String apiUrl = 'https://app.payuni.co.id/api/v1';
// String apiUrl = 'http://192.168.1.38:8089/api/v1';
String apiUrlKasir = 'https://api-pos.payuni.co.id/api/v1';
// String liveChat = 'https://tawk.to/chat/6375b1cadaff0e1306d7d788/1gi1rt0u7';
// String liveChatAlpay = 'https://tawk.to/chat/638219a8daff0e1306d98d1f/1giq38fhr';
String liveChat = 'https://tawk.to/chat/63c8fe1347425128790e80aa/1gn4i0vge';
int otpCount = 4;
int pinCount = 4;
bool limitPinLogin = false;
bool autoReload = false;
bool isKasir = false;
bool isMarketplace = false;
bool realtimePrepaid = false;
bool enableMultiChannel = false;
bool dynamicFooterStruk = true;
bool gangguanDisplay = true;

Map<String, String> assetGambar = {
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321',
  'iconProfile':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e',
  'logoPrinter':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Ficons%2FPhoto_1536510356016-1%20(1).png?alt=media&token=3853ec11-ed0a-4cc0-8e6e-579824373ae1',
  'imageHeader': 'https://dokumen.payuni.co.id/logo/ualreload/headerNew.png',
  'imageAppbar': 'https://dokumen.payuni.co.id/logo/ualreload/appbarNew.png',
  // 'backgroundStruk': 'https://www.payuni.co.id/struk.png',
};

Map<String, dynamic> layout = {
  'home': HomePayuni(),
  'topup': TopupPage(),
  'transfer': KirimSaldo(),
  'detail-deposit': (DepositModel d) => DetailDeposit(d)
};

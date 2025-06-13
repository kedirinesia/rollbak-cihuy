// @dart=2.9

import 'dart:io' show Platform;
import 'package:mobile/Products/xenaja/layout/detail-deposit.dart';
import 'package:mobile/Products/xenaja/layout/home.dart';
import 'package:mobile/Products/xenaja/layout/kirim-saldo.dart';
import 'package:mobile/Products/xenaja/layout/splash.dart';
import 'package:mobile/Products/xenaja/layout/topup.dart';
import 'package:mobile/models/deposit.dart';

String sigVendor = '5e523bf7ae1e375162506db7';

const namaApp = 'XenAja';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = Platform.isAndroid ? 'com.xenaja.app' : 'co.payuni.popay';
String brandId;
String copyRight = '';
int templateCode = 3;
String gaId = '';
String apiUrl = 'https://payuni-app.findig.id/api/v1';
// String apiUrl = 'http://192.168.88.163:8089/api/v1';
// String apiUrlKasir = 'http://192.168.43.170:8082/api/v1';

// String apiUrl = 'https://app.popay.id/api/v1';
String apiUrlKasir = 'https://api-pos.payuni.co.id/api/v1';
// String liveChat = 'https://tawk.to/chat/5e7a248669e9320caabc7e0c/default';
String liveChat = '';
int otpCount = 4;
int pinCount = 4;
bool limitPinLogin = false;
bool autoReload = false;
bool isKasir = false;
bool isMarketplace = false;
bool realtimePrepaid = false;
bool enableMultiChannel = false;
bool qrisStaticOnTopup = false;
bool gangguanDisplay = true;
bool dynamicFooterStruk = true;

Map<String, String> assetGambar = {
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321',
  'iconProfile':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e',
  'logoPrinter':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Frsz_1rsz_photo_1536510356016.png?alt=media&token=e36a8c56-6414-4f08-9a6e-eaa314ddcc75',
  'imageHeader': 'https://dokumen.payuni.co.id/logo/xenaja/bghome.png',
  'imageAppbar': 'https://dokumen.payuni.co.id/logo/xenaja/bghome.png',
  'logoApp': 'https://dokumen.payuni.co.id/logo/xenaja/landscape.png',
  'logoLogin': 'https://dokumen.payuni.co.id/logo/xenaja/landscape.png',
  // 'backgroundStruk':
  //     'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Ficons%2Fprint.png?alt=media&token=916f8a47-fd66-42e4-8270-d9736caebf57',
};

Map<String, dynamic> layout = {
  'home': HomePopay(),
  'topup': TopupPage(),
  'transfer': KirimSaldo(),
  'detail-deposit': (DepositModel d) => DetailDeposit(d),
  'splash': SplashPopay()
};

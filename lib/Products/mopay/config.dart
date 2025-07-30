// @dart=2.9

import 'package:mobile/Products/mopay/layout/detail-deposit.dart';
import 'package:mobile/Products/mopay/layout/home.dart';
import 'package:mobile/Products/mopay/layout/kirim-saldo.dart';
import 'package:mobile/Products/mopay/layout/topup.dart';
import 'package:mobile/models/deposit.dart';

String sigVendor = '601e3e5d7c1887357d189ab4';

const namaApp = 'Mopay';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'com.mopay.mobile';
String brandId;
String copyRight = '';
int templateCode = 3;
String gaId = '';
String apiUrl = 'https://mopay-app.findig.id/api/v1';
String apiUrlKasir = 'https://api-pos.payuni.co.id/api/v1';
// String apiUrl = 'http://192.168.43.170:8089/api/v1';
// String apiUrlKasir = 'http://192.168.43.170:8082/api/v1';
String liveChat = 'https://tawk.to/chat/601fae83a9a34e36b9749bbc/1etts3vad';
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
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Frsz_1rsz_photo_1536510356016.png?alt=media&token=e36a8c56-6414-4f08-9a6e-eaa314ddcc75',
  'imageHeader': 'http://dokumen.payuni.co.id/icon/payaja/headerapp.png',
  'imageAppbar': 'http://dokumen.payuni.co.id/icon/payaja/footerapp.png',
  'logoApp':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Frsz_1rsz_photo_1536510356016.png?alt=media&token=e36a8c56-6414-4f08-9a6e-eaa314ddcc75',
  // 'backgroundStruk':
  //     'http://dokumen.payuni.co.id/icon/payaja/struk.png',
};

Map<String, dynamic> layout = {
  'home': HomePopay(),
  'topup': TopupPage(),
  'transfer': KirimSaldo(),
  'detail-deposit': (DepositModel d) => DetailDeposit(d)
};

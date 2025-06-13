// @dart=2.9

import 'package:mobile/Products/pgkreload/layout/detail-deposit.dart';
import 'package:mobile/Products/pgkreload/layout/home.dart';
import 'package:mobile/Products/pgkreload/layout/kirim-saldo.dart';
import 'package:mobile/Products/pgkreload/layout/topup.dart';
import 'package:mobile/models/deposit.dart';

String sigVendor = '640ffdad980aba06b0cf0ba5';

const namaApp = 'PGK Reload';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'com.pgkreload.app';
String brandId;
String copyRight = '';
int templateCode = 3;
String gaId = '';
String apiUrl = 'https://pgkreload-app.findig.id/api/v1';
String liveChat = 'https://tawk.to/chat/64109c9031ebfa0fe7f28bcd/1grge75nf';
int otpCount = 4;
int pinCount = 4;
bool limitPinLogin = false;
bool autoReload = false;
bool isKasir = true;
bool isMarketplace = true;
bool gangguanDisplay = true;
bool realtimePrepaid = false;
bool enableMultiChannel = false;
bool boldNomorTujuan = true;
String apiUrlKasir = 'https://api-pos.pgkreload.com/api/v1';

Map<String, String> assetGambar = {
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321',
  'iconProfile':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e',
  'logoPrinter': 'https://dokumen.payuni.co.id/logo/pgkreload/logoland.png',
  'imageHeader': 'https://dokumen.payuni.co.id/logo/pgkreload/pgkheader.png',
  'imageAppbar': 'https://dokumen.payuni.co.id/logo/pgkreload/pgkappbar.png',
};

Map<String, dynamic> layout = {
  'home': HomeAyoba(),
  'topup': TopupPage(),
  'transfer': KirimSaldo(),
  'detail-deposit': (DepositModel d) => DetailDeposit(d)
};

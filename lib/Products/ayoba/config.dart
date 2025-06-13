// @dart=2.9

import 'package:mobile/Products/ayoba/layout/detail-deposit.dart';
import 'package:mobile/Products/ayoba/layout/home.dart';
import 'package:mobile/Products/ayoba/layout/kirim-saldo.dart';
import 'package:mobile/Products/ayoba/layout/login_wizard.dart';
import 'package:mobile/Products/ayoba/layout/topup.dart';
import 'package:mobile/models/deposit.dart';

String sigVendor = '60b7436033d9ef1b58ee1f3b';

const namaApp = 'Ayoba';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'ayoba.co.id';
String brandId;
String copyRight = '';
int templateCode = 3;
String gaId = '';
String apiUrl = 'https://ayoba-app.findig.id/api/v1';
String liveChat = 'https://tawk.to/chat/60b7c30d6699c7280daa5d35/1f76t3s1q';
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
String apiUrlKasir = 'https://api-pos.ayoba.co.id/api/v1';

Map<String, String> assetGambar = {
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321',
  'iconProfile':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e',
  'logoPrinter': 'https://ayoba.co.id/dokumen/logoprint2.jpeg',
  'imageHeader': 'https://dokumen.payuni.co.id/logo/mypay/headerbg.png',
  'imageAppbar': 'https://dokumen.payuni.co.id/logo/mypay/appbar.png',
};

Map<String, dynamic> layout = {
  'login': LoginWizardPage(),
  'home': HomeAyoba(),
  'topup': TopupPage(),
  'transfer': KirimSaldo(),
  'detail-deposit': (DepositModel d) => DetailDeposit(d)
};

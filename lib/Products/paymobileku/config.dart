// @dart=2.9

import 'package:mobile/Products/paymobileku/layout/detail-deposit.dart';
import 'package:mobile/Products/paymobileku/layout/kirim-saldo.dart';
import 'package:mobile/Products/paymobileku/layout/main.dart';
import 'package:mobile/Products/paymobileku/layout/not_verified_user.dart';
import 'package:mobile/Products/paymobileku/layout/splash.dart';
import 'package:mobile/Products/paymobileku/layout/topup.dart';
import 'package:mobile/Products/paymobileku/layout/wizard.dart';
import 'package:mobile/models/deposit.dart';

String sigVendor = '633fdb81336ccd850f4fd736';

const namaApp = 'PayMobileku';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'id.paymobileku.app';
String brandId;
String copyRight = '';
int templateCode = 6;
String gaId = '';
String apiUrl = 'https://paymobileku-app.findig.id/api/v1';
String apiUrlKasir = '';
String liveChat = 'https://tawk.to/chat/63437ee537898912e96db839/1gevqfcav';
int otpCount = 4;
int pinCount = 4;
bool limitPinLogin = false;
bool autoReload = false;
bool isKasir = false;
bool isMarketplace = true;
bool realtimePrepaid = true;
bool gangguanDisplay = true;
bool dynamicFooterStruk = true;
bool enableMultiChannel = false;

Map<String, String> assetGambar = {
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321',
  'iconProfile':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e'
};

Map<String, dynamic> layout = {
  'splash': SplashPage(),
  'login': StartWizardPage(),
  'home': PakaiAjaHome(),
  'topup': TopupPage(),
  'transfer': KirimSaldo(),
  'not_verified_user': NotVerifiedPage(),
  'detail-deposit': (DepositModel d) => DetailDeposit(d),
};

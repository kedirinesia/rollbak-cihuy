// @dart=2.9

import 'package:mobile/Products/akartoko/layout/detail-deposit.dart';
import 'package:mobile/Products/akartoko/layout/home.dart';
import 'package:mobile/Products/akartoko/layout/kirim-saldo.dart';
import 'package:mobile/Products/akartoko/layout/topup.dart';
import 'package:mobile/models/deposit.dart';

String sigVendor = '6024b19e0f94f70c45aaf7c2';

const namaApp = 'AKARTOKO';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'akartoko.id';
String brandId;
String copyRight = '';
int templateCode = 3;
String gaId = '';
String apiUrl = 'https://akartoko-app.findig.id/api/v1';
String liveChat = 'https://tawk.to/chat/60269ba89c4f165d47c2b385/1eubd035j';
int otpCount = 4;
int pinCount = 4;
bool limitPinLogin = false;
bool autoReload = false;
bool isKasir = true;
bool isMarketplace = true;
bool realtimePrepaid = false;
bool enableMultiChannel = false;
String apiUrlKasir = 'https://api-pos.akartoko.id/api/v1';

Map<String, String> assetGambar = {
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321',
  'iconProfile':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e',
  'logoPrinter': 'https://mobipayment.co.id/images/deposit.png',
  'imageHeader': 'http://akartoko.id/images/headprofile.png',
  'imageAppbar': 'http://akartoko.id/images/headtf.png'
};

Map<String, dynamic> layout = {
  'home': HomePopay(),
  'topup': TopupPage(),
  'transfer': KirimSaldo(),
  'detail-deposit': (DepositModel d) => DetailDeposit(d)
};

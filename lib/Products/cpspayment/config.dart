// @dart=2.9

import 'package:mobile/Products/cpspayment/layout/detail-deposit.dart';
import 'package:mobile/Products/cpspayment/layout/main.dart';
import 'package:mobile/models/deposit.dart';

String sigVendor = '6198a8454e88e9318b9a1817';

const namaApp = 'CPS Payment';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'com.cpspayment.mobile';
String brandId;
String copyRight = '';
int templateCode = 6;
String gaId = '';
String apiUrl = 'https://cpspayment-app.findig.id/api/v1';
String apiUrlKasir = '';
String liveChat = 'https://tawk.to/chat/6199454d6bb0760a4943897d/1fkvbdduh';
int pinCount = 4;
int otpCount = 4;
bool limitPinLogin = false;
bool autoReload = false;
bool isKasir = false;
bool isMarketplace = true;
bool realtimePrepaid = false;
bool enableMultiChannel = true;

Map<String, String> assetGambar = {
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321',
  'iconProfile':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e'
};

Map<String, dynamic> layout = {
  'home': PakaiAjaHome(),
  'detail-deposit': (DepositModel d) => DetailDeposit(d),
};

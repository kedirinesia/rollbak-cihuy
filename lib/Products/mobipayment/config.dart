// @dart=2.9

import 'package:mobile/Products/mobipayment/layout/detail-deposit.dart';
import 'package:mobile/Products/mobipayment/layout/home.dart';
import 'package:mobile/Products/mobipayment/layout/kirim-saldo.dart';
import 'package:mobile/Products/mobipayment/layout/topup.dart';
import 'package:mobile/models/deposit.dart';

String sigVendor = '5ebdb9eda5af48034954daf3';

const namaApp = 'Mobi Pay';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'mobipayment.co.id';
String brandId;
String copyRight = '';
int templateCode = 3;
String gaId = '';
String apiUrl = 'https://mobipay-app.findig.id/api/v1';
String liveChat = 'https://tawk.to/chat/628d99247b967b11799113fd/1g3shse4s';
int otpCount = 4;
int pinCount = 4;
bool limitPinLogin = false;
bool autoReload = false;
bool isKasir = false;
bool isMarketplace = false;
bool realtimePrepaid = false;
bool enableMultiChannel = false;
String apiUrlKasir = 'https://api-pos.payuni.co.id/api/v1';

Map<String, String> assetGambar = {
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321',
  'iconProfile':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e',
  'logoPrinter': 'https://mobipayment.co.id/images/deposit.png',
  'imageHeader':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2FMobipay%2Fbackground-header.png?alt=media&token=ca8614cb-4a32-4cda-8cae-8b7d6269f2ba',
  'imageAppbar':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2FMobipay%2Fbackgroundr.png?alt=media&token=c82045ef-c50d-401d-9b7d-57c8f7c730c5'
};

Map<String, dynamic> layout = {
  'home': HomeMobiPayment(),
  'topup': TopupPage(),
  'transfer': KirimSaldo(),
  'detail-deposit': (DepositModel d) => DetailDeposit(d)
};

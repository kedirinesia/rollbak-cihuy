// @dart=2.9

import 'package:mobile/Products/mocipay/layout/detail-deposit.dart';
import 'package:mobile/Products/mocipay/layout/home.dart';
import 'package:mobile/Products/mocipay/layout/kirim-saldo.dart';
import 'package:mobile/Products/mocipay/layout/topup.dart';
import 'package:mobile/models/deposit.dart';

String sigVendor = '5ebdb9eda5af48034954daf3  ';

const namaApp = 'MOBI PAY';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'com.mobipayment.app';
String brandId;
String copyRight = 'Mobi Payment';
int templateCode = 3;
String gaId = '';
String apiUrl = 'https://app.mobipayment.com/api/v1';
String liveChat = '';
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
  'imageHeader':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fmocipay%2FBackground.png?alt=media&token=5d56c738-3349-462c-9cca-1e392754baa3',
  'imageAppbar':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fmocipay%2FHeader%20Bg%20(1).png?alt=media&token=4dd5eb62-3e99-4354-9fb8-6cac5f27b448',
  'iconLogo':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fmocipay%2Fmocipay_icon.png?alt=media&token=0a852d1e-bb29-4ab0-85eb-9da8776f9f95'
};

Map<String, dynamic> layout = {
  'home': HomePopay(),
  'topup': TopupPage(),
  'transfer': KirimSaldo(),
  'detail-deposit': (DepositModel d) => DetailDeposit(d)
};

// @dart=2.9

import 'package:mobile/Products/mypay/layout/detail-deposit.dart';
import 'package:mobile/Products/mypay/layout/home.dart';
import 'package:mobile/Products/mypay/layout/kirim-saldo.dart';
import 'package:mobile/Products/mypay/layout/topup.dart';
import 'package:mobile/models/deposit.dart';

// String sigVendor = '5e523bf7ae1e375162506db7';
String sigVendor = '60b128784eaa6fe18af5af70';

const namaApp = 'My Pay';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'mypay.co.id';
String brandId;
String copyRight = '';
int templateCode = 3;
String gaId = '';
String apiUrl = 'https://mypay-app.findig.id/api/v1';
// String apiUrl = 'http://192.168.1.58:8089/api/v1';
String liveChat = 'https://tawk.to/chat/60b1f35f6699c7280da98dcd/1f6rhtbhf';
int otpCount = 4;
int pinCount = 4;
bool limitPinLogin = false;
bool autoReload = false;
bool isKasir = false;
bool isMarketplace = true;
bool realtimePrepaid = false;
bool enableMultiChannel = false;
bool gangguanDisplay = true;
String apiUrlKasir = 'https://api-pos.payuni.co.id/api/v1';

Map<String, String> assetGambar = {
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321A',
  'iconProfile':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5eA',
  'logoPrinter':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Ficons%2FPhoto_1536510356016-1%20(1).png?alt=media&token=3853ec11-ed0a-4cc0-8e6e-579824373ae1A',
  'imageHeader': 'https://dokumen.payuni.co.id/logo/mypay/headerbg.png',
  'imageAppbar': 'https://dokumen.payuni.co.id/logo/mypay/appbar.png',
  // 'backgroundStruk':
  //     'https://dokumen.payuni.co.id/icon/payku/logocetakstruk.png',
};

Map<String, dynamic> layout = {
  'home': HomePopay(),
  'topup': TopupPage(),
  'transfer': KirimSaldo(),
  'detail-deposit': (DepositModel d) => DetailDeposit(d)
};

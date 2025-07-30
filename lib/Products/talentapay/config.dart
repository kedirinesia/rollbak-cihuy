// @dart=2.9
import 'package:mobile/Products/talentapay/layout/detail-deposit.dart';
import 'package:mobile/Products/talentapay/layout/home.dart';
import 'package:mobile/Products/talentapay/layout/kirim-saldo.dart';
import 'package:mobile/Products/talentapay/layout/splash.dart';
import 'package:mobile/Products/talentapay/layout/topup.dart';
import 'package:mobile/models/deposit.dart';

String sigVendor = '5fd488662fe32242f243cbd6';

const namaApp = 'Talenta Pay';
const labelSaldo = 'Saldo';
const labelPoint = 'Point';
String packagename = 'com.talentapay.android';
String brandId;
String copyRight = '';
int templateCode = 3;
String gaId = '';
String apiUrl = 'https://talenta-app.findig.id/api/v1';
String apiUrlKasir = 'https://api-kasir.talentapay.com/api/v1';
// String apiUrl = 'http://192.168.43.170:8089/api/v1';
String liveChat = 'https://tawk.to/chat/5fd73357df060f156a8cd052/1epga141b';
// String liveChat = 'https://tawk.to/chat/5e6553b38d24fc2265866fdd/default';
int otpCount = 4;
int pinCount = 4;
bool limitPinLogin = false;
bool autoReload = false;
bool isKasir = true;
bool isMarketplace = true;
bool realtimePrepaid = false;
bool enableMultiChannel = false;
bool dynamicFooterStruk = true;
bool gangguanDisplay = true;

Map<String, String> assetGambar = {
  'iconTransfer':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fapp.png?alt=media&token=4713fa12-4f25-4b40-a8e3-59f4523e4321',
  'iconProfile':
      'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fsmartdigital%2Fshield.png?alt=media&token=24fa363a-0e3d-45ac-910c-509597784c5e',
  'logoPrinter':
      'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Ficons%2FPhoto_1536510356016-1%20(1).png?alt=media&token=3853ec11-ed0a-4cc0-8e6e-579824373ae1',
  'logoApp': 'https://banner.payuni.co.id/talenta/TalentaLogo.png',
  'imageHeader': 'https://dokumen.payuni.co.id/icon/talenta/headbar.png',
  'imageAppbar': 'https://dokumen.payuni.co.id/icon/talenta/appbar.png',
};

Map<String, dynamic> layout = {
  'home': HomePopay(),
  'topup': TopupPage(),
  'transfer': KirimSaldo(),
  'detail-deposit': (DepositModel d) => DetailDeposit(d),
  'splash': SplashTalentapay()
};

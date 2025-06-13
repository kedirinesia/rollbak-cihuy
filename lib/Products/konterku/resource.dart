import './config.dart' as config;
import '../../app_config.dart';

class StringResource implements Resource {
  String sig = config.sigVendor;
  String packagename = config.packagename;
  String brandId = config.brandId;
  String labelSaldo = config.labelSaldo;
  String labelPoint = config.labelPoint;
  String gaId = config.gaId;
  int templateCode = config.templateCode;
  String copyRight = config.copyRight;
  String liveChat = config.liveChat;
  String apiUrl = config.apiUrl;
  String apiUrlKasir = config.apiUrlKasir;
  int pinCount = config.pinCount;
  int otpCount = config.otpCount;
  bool limitPinLogin = config.limitPinLogin;
  bool autoReload = config.autoReload;
  bool gangguanDisplay = false;
  bool boldNomorTujuan = false;
  bool qrisStaticOnTopup = false;
  bool dynamicFooterStruk = false;
  bool isKasir = config.isKasir;
  bool isMarketplace = config.isMarketplace;
  bool realtimePrepaid = config.realtimePrepaid;
  bool enableMultiChannel = config.enableMultiChannel;
  Map<String, String> iconApp = config.assetGambar;
  Map<String, dynamic> layoutApp = {};
}

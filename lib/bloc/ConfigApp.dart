
import 'package:mobile/models/app_info.dart';
import 'package:rxdart/rxdart.dart';

class ConfigAppBloc extends Object {
  final namaApp = BehaviorSubject<String>();
  final labelSaldo = BehaviorSubject<String>();
  final labelPoint = BehaviorSubject<String>();
  final templateCode = BehaviorSubject<int>();
  final copyRight = BehaviorSubject<String>();
  final packagename = BehaviorSubject<String>();
  final brandId = BehaviorSubject<String>();
  final gaId = BehaviorSubject<String>();
  final iconApp = BehaviorSubject<Map<String, String>>();
  final layoutApp = BehaviorSubject<Map<String, dynamic>>();
  final info = BehaviorSubject<AppInfo>();
  final liveChat = BehaviorSubject<String>();
  final pinCount = BehaviorSubject<int>();
  final otpCount = BehaviorSubject<int>();
  final limitPinLogin = BehaviorSubject<bool>();
  final autoReload = BehaviorSubject<bool>();
  final realtimePrepaid = BehaviorSubject<bool>();
  final enableMultiChannel = BehaviorSubject<bool>();
  final isKasir = BehaviorSubject<bool>();
  final isMarketplace = BehaviorSubject<bool>();
  final displayGangguan = BehaviorSubject<bool>();
  final boldNomorTujuan = BehaviorSubject<bool>();
  final qrisStaticOnTopup = BehaviorSubject<bool>();
  final dynamicFooterStruk = BehaviorSubject<bool>();

  dispose() {
    namaApp.close();
    labelSaldo.close();
    labelPoint.close();
    templateCode.close();
    copyRight.close();
    packagename.close();
    brandId.close();
    liveChat.close();
    gaId.close();
    layoutApp.close();
    iconApp.close();
    info.close();
    pinCount.close();
    otpCount.close();
    limitPinLogin.close();
    autoReload.close();
    realtimePrepaid.close();
    enableMultiChannel.close();
    isKasir.close();
    isMarketplace.close();
    displayGangguan.close();
    boldNomorTujuan.close();
    qrisStaticOnTopup.close();
    dynamicFooterStruk.close();
  }
}

final configAppBloc = ConfigAppBloc();

String namaApp = configAppBloc.namaApp.valueWrapper!.value;
String brandId = configAppBloc.brandId.valueWrapper!.value;
String labelSaldo = configAppBloc.labelSaldo.valueWrapper!.value;
String labelPoint = configAppBloc.labelPoint.valueWrapper!.value;
int templateCode = configAppBloc.templateCode.valueWrapper!.value;
String copyRight = configAppBloc.copyRight.valueWrapper!.value;
String gaId = configAppBloc.gaId.valueWrapper!.value;
String liveChat = configAppBloc.liveChat.valueWrapper!.value;
int pinCount = configAppBloc.pinCount.valueWrapper!.value;
int otpCount = configAppBloc.otpCount.valueWrapper!.value;
bool limitPinLogin = configAppBloc.limitPinLogin.valueWrapper!.value;
bool autoReload = configAppBloc.autoReload.valueWrapper!.value ?? false;
bool isKasir = configAppBloc.isKasir.valueWrapper!.value ?? false;
bool isMarketplace = configAppBloc.isMarketplace.valueWrapper!.value ?? false ;
bool realtimePrepaid = configAppBloc.realtimePrepaid.valueWrapper!.value ?? false;
bool enableMultiChannel = configAppBloc.enableMultiChannel.valueWrapper!.value ?? false;
bool dynamicFooterStruk = configAppBloc.dynamicFooterStruk.valueWrapper!.value ?? false;
Map<String, String> iconApp = configAppBloc.iconApp.valueWrapper!.value;
Map<String, dynamic> layoutApp = configAppBloc.layoutApp.valueWrapper!.value;

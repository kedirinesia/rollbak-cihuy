// @dart=2.9

import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart' show bloc;
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/component/custom_scroll_behavior.dart';
import 'package:mobile/config.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/user.dart';
import 'package:mobile/screen/cs.dart';
import 'package:mobile/screen/disable.dart';
import 'package:mobile/screen/kasir/barang/barangView.dart'; // halaman view barang
import 'package:mobile/screen/kasir/category.dart'; // halaman category
import 'package:mobile/screen/kasir/customer/customerView.dart'; // halaman view pelanggan
import 'package:mobile/screen/kasir/hutang-piutang/index.dart'; // halaman hutang piutang
import 'package:mobile/screen/kasir/laporan/indexLap.dart'; // halaman hutang piutang
// PAGE KASIR
import 'package:mobile/screen/kasir/main.dart'; // halaman depan kasir
import 'package:mobile/screen/kasir/penjualan/listProduct.dart'; // halaman depan transaksi penjualan
import 'package:mobile/screen/kasir/persediaan/persediaanView.dart'; // halaman persediaan
import 'package:mobile/screen/kasir/satuan.dart'; // halaman satuan
import 'package:mobile/screen/kasir/supplier/supplierView.dart'; // halaman view supplier
import 'package:mobile/screen/login.dart';
import 'package:mobile/screen/notifikasi/notifikasi.dart';
import 'package:mobile/screen/profile/komisi/riwayat_komisi.dart';
import 'package:mobile/screen/profile/my_qr.dart';
import 'package:mobile/screen/profile/reward/list_reward.dart';
import 'package:mobile/screen/topup/topup.dart';
import 'package:mobile/screen/transfer_saldo/transfer_saldo.dart';
import 'package:mobile/screen/wd/withdraw.dart';
import 'package:nav/nav.dart';
import 'package:path_provider/path_provider.dart' as PathProvider;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info/package_info.dart';

import 'models/user.dart';

Future<void> onMessageHandler(Map<String, dynamic> message) async {
  print("On msg background: $message");
}

class PayuniApp extends StatefulWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  PayuniApp({Key key}) : super(key: key);

  @override
  _PayuniAppState createState() => _PayuniAppState();
}

class _PayuniAppState extends State<PayuniApp> with Nav {
  AppLinks _appLinks;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool loading = true;
  Widget homePageWidget = Container();
  String appVersionCode = '';

  initialState() {
    super.initState();
    print(configAppBloc.layoutApp.valueWrapper?.value.toString());
    updateUserInfo();
  }

  dispose() {
    super.dispose();
  }

  Future<Map<String, dynamic>> getUser(String token) async {
    Map<String, String> headers = {
      'Authorization': token,
    };
    
    if (appVersionCode.isNotEmpty) {
      headers['App-Version'] = appVersionCode;
    }
    
    print('=== GET USER/INFO ===');
    print('URL: $apiUrl/user/info');
    print('Headers: ${json.encode(headers)}');
    print('Method: GET');
    print('Body: null (GET request)');
    print('====================');
    
    http.Response response = await http
        .get(Uri.parse('$apiUrl/user/info'), headers: headers);
    
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('====================');
    
    return json.decode(response.body);
  }

  checkUser() async {
    setState(() {
      loading = true;
    });

    List<String> pkgNameSplashProgress = ['com.talentapay.android'];

    pkgNameSplashProgress.forEach((element) {
      if (element == packageName) {
        SharedPreferences.getInstance().then((value) {
          value.setBool('splash-loading', true);
        });
      }
    });

    await getAppInfo();
    // await getLocationPermission();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int printerType = prefs.getInt('printer_type') ?? 1;
    bloc.printerType.add(printerType);
    int printFontSize = prefs.getInt('printer_font_size') ?? 1;
    bloc.printerFontSize.add(printFontSize);
    String token = prefs.getString('token') ?? '';
    await getDynamicLinks();

    if (token.isEmpty) {
      setState(() {
        loading = false;
        homePageWidget =
            configAppBloc.layoutApp.valueWrapper?.value['login'] ?? LoginPage();
      });
    }

    if (!configAppBloc.info.valueWrapper.value.aktif) {
      setState(() {
        loading = false;
        homePageWidget = DisablePage(DisableType.merchant);
      });
    }

    print('TOKEN: $token');

    if (token.isNotEmpty) {
      Map<String, dynamic> userInfo = await getUser(token);
      if (userInfo['status'] == 200) {
        UserModel profile = UserModel.fromJson(userInfo['data']);
        if (!profile.aktif) {
          setState(() {
            loading = false;
            homePageWidget = DisablePage(DisableType.member);
          });
        } else {
          prefs.setString('id', profile.id);
          prefs.setString('nama', profile.nama);
          prefs.setInt('saldo', profile.saldo);
          prefs.setInt('poin', profile.poin);
          prefs.setInt('komisi', profile.komisi);

          /*
          GET PROFILE USER
          */
          bloc.user..add(profile);
          bloc.token..add(token);
          bloc.userId..add(prefs.getString('id'));
          bloc.username..add(prefs.getString('nama'));
          bloc.poin..add(prefs.getInt('poin'));
          bloc.saldo..add(prefs.getInt('saldo'));
          bloc.komisi..add(prefs.getInt('komisi'));

          sendDeviceToken();
          await getFlashBanner(context);

          pkgNameSplashProgress.forEach((element) {
            if (element == packageName) {
              SharedPreferences.getInstance().then((prefs) {
                prefs.setBool('splash-loading', false);
              });

              Future.delayed(Duration(seconds: 1), () {
                setState(() {
                  loading = false;
                });
              });
            } else {
              setState(() {
                loading = false;
              });
            }
          });

          setState(() {
            homePageWidget =
                configAppBloc.layoutApp.valueWrapper?.value['home'] != null
                    ? configAppBloc.layoutApp.valueWrapper?.value['home']
                    : templateConfig[
                        configAppBloc.templateCode.valueWrapper?.value];
          });
        }
      } else {
        prefs.clear();
        setState(() {
          loading = false;
          homePageWidget =
              configAppBloc.layoutApp.valueWrapper?.value['login'] ??
                  LoginPage();
        });
      }
    } else {
      prefs.clear();
      setState(() {
        loading = false;
        homePageWidget =
            configAppBloc.layoutApp.valueWrapper?.value['login'] ?? LoginPage();
      });
    }

    // return FutureBuilder(
    //   future: check(),
    //   builder: (_, AsyncSnapshot snapshot) {
    //     print(snapshot.error);
    //     if (snapshot.hasError) {
    //       Widget pageError = Scaffold(
    //         body: Container(
    //           child: Center(child: Text('Error')),
    //         ),
    //       );

    //       setState(() {
    //         loading = false;
    //         homePageWidget = pageError;
    //       });
    //     }
    //     if (snapshot.hasData) {
    //       // return snapshot.data;
    //       // return Material(
    //       //   child: snapshot.data,
    //       // );
    //       print('HELLO WORLD');
    //       setState(() {
    //         loading = false;
    //         homePageWidget = snapshot.data;
    //       });
    //     } else {
    //       setState(() {
    //         loading = false;
    //         homePageWidget = snapshot.data;
    //       });
    //       // return configAppBloc.layoutApp.valueWrapper?.value['splash'] ??
    //     }
    //   },
    // );
  }

  @override
  void initState() {
    super.initState();
    checkUser();
    appLink();
    // _requestNotifPermission();
    notificationInit();
    firebaseMessaging();
    initNotif();
    hiveInit();
    // checkContact();
    printVersionInfo(); // Tambahkan ini untuk print version info ke console
    if (configAppBloc.autoReload.valueWrapper.value) {
      SharedPreferences.getInstance().then((instance) {
        String token = instance.getString('token');
        if (token != null) {
          print('TOKEN: $token');

          Timer.periodic(new Duration(seconds: 100), (timer) async {
            UserModel user = await UserProvider().getProfile();
            bloc.user.add(user);
            bloc.userId.add(user.id);
            bloc.username.add(user.nama);
            bloc.poin.add(user.poin);
            bloc.saldo.add(user.saldo);
            bloc.komisi.add(user.komisi);
          });
        }
      });
    }
  }

  Future<void> printVersionInfo() async {
    final info = await PackageInfo.fromPlatform();
    appVersionCode = info.buildNumber;
    print('Version Name: ${info.version}');
    print('Version Code: ${info.buildNumber}');
    print('Package Name: ${info.packageName}');
  }

  void appLink() {
    _appLinks = AppLinks(onAppLink: (uri, str) {
      print('Deep link received: $uri');
      
      // Handle agenpayment://login deep link
      if (uri.scheme == 'agenpayment' && uri.host == 'login') {
        // Navigate to login page
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => configAppBloc.layoutApp.valueWrapper?.value['login'] ?? LoginPage()),
          (route) => false
        );
        showToast(context, 'Navigating to login page via deep link');
      } else {
        showToast(context, str);
      }
    });
  }

  Future<void> hiveInit() async {
    String appDir =
        (await PathProvider.getApplicationDocumentsDirectory()).path;
    Hive.init(appDir);
    await Hive.openBox('cart');
    await Hive.openBox('favorite-menu');
    await Hive.openBox('favorite-menu-choice');
    await Hive.openBox('favorite-menu-postpaid');
    await Hive.openBox('daftar-transfer');
    await Hive.openBox('transfer-terakhir');
    await Hive.openBox('unread-notification');
    await Hive.openBox('ref-code');
  }

  Widget unstableConnection() {
    return Container(
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 200.0,
            color: Theme.of(context).primaryColor,
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text('Opps...'),
            ),
            body: Container(
              padding: EdgeInsets.all(20.0),
              margin: EdgeInsets.all(20.0),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(.2),
                    blurRadius: 10.0,
                    offset: Offset(5, 10))
              ]),
              width: double.infinity,
              height: 300.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Icon(Icons.signal_cellular_connected_no_internet_4_bar,
                      color: Theme.of(context).primaryColor, size: 62.0),
                  Text('Koneksi Tidak Stabil',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20.0)),
                  SizedBox(height: 10.0),
                  Text(
                      'Silahkan Cek Koneksi Kamu Sebelum Membuka Aplikasi Ini, Pastikan Kamu Mempunyai Koneksi Stabil',
                      textAlign: TextAlign.center),
                  SizedBox(height: 20.0),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => PayuniApp()),
                        (route) => false),
                    child: Text(
                      'Reload',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    Map<String, dynamic> notificationData =
        bloc.notificationData.valueWrapper?.value;
    print(notificationData);
    Map<dynamic, dynamic> data = notificationData['data'];
    if (data['type'] == 'transaksi') {
      /*
        PUSH KE HALAMAN TRANSAKSI
        */
    } else if (data['type'] == 'menu') {
      /*
        PUSH KE HALAMAN MENU
        */
    } else if (data['type'] == 'pulsa') {
      /*
        PUSH KE HALAMAN PULSA
        */
    } else {
      /*
        PUSH PESAN SEBAGAI MODAL DIALOG
        */
      print('Action Nothing');
      return showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    data['cover'] != null
                        ? Container(
                            child: CachedNetworkImage(
                                imageUrl: data['cover'],
                                placeholder: (_, String text) {
                                  return CircularProgressIndicator();
                                }),
                          )
                        : Container(),
                    Text('${notificationData['notification']['title']}',
                        style: TextStyle(fontSize: 18.0)),
                    SizedBox(height: 20.0),
                    Text('${notificationData['notification']['body']}',
                        style: TextStyle(fontSize: 14.0)),
                    SizedBox(height: 20.0),
                    Divider(),
                    TextButton(
                        onPressed: () =>
                            Navigator.of(context, rootNavigator: true).pop(),
                        child: Text('Tutup'))
                  ],
                ),
              ),
            );
          });
    }
  }

  void firebaseMessaging() async {
    await Firebase.initializeApp();
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    String deviceToken = await _firebaseMessaging.getToken();
    // if (Platform.isIOS) {
    //   _firebaseMessaging.requestNotificationPermissions(
    //       const IosNotificationSettings(sound: true, badge: true, alert: true));
    //   _firebaseMessaging.onIosSettingsRegistered
    //       .listen((IosNotificationSettings settings) {
    //     print("Settings registered: $settings");
    //   });
    // }
    bloc.deviceToken.add(deviceToken);
  }

  void sendDeviceToken() async {
    Map<String, String> headers = {
      'Authorization': bloc.token.valueWrapper?.value,
      'Content-Type': 'application/json'
    };
    
    if (appVersionCode.isNotEmpty) {
      headers['App-Version'] = appVersionCode;
    }
    
    Map<String, dynamic> body = {'token': bloc.deviceToken.valueWrapper?.value};
    
    print('=== POST USER/DEVICE_TOKEN ===');
    print('URL: $apiUrl/user/device_token');
    print('Headers: ${json.encode(headers)}');
    print('Method: POST');
    print('Body: ${json.encode(body)}');
    print('=============================');
    
    http.Response response = await http.post(Uri.parse('$apiUrl/user/device_token'),
        headers: headers,
        body: json.encode(body));
    
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('=============================');
  }

  // Future<void> _requestNotifPermission() async {
  //   PermissionStatus status = await Permission.notification.request();
  //   print(status);
  //   while (status != PermissionStatus.granted) {
  //     status = await Permission.notification.request();
  //   }
  // }

  void notificationInit() async {
    // var initializationSettingsAndroid = AndroidInitializationSettings('@drawable/app_icon');
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true);
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  void initNotif() async {
    FirebaseMessaging.onMessage.listen((message) async {
      var android = new AndroidNotificationDetails(
        '1',
        'notif',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('ping'),
      );
      var ios = new IOSNotificationDetails();
      var notificationDetails =
          new NotificationDetails(android: android, iOS: ios);
      await flutterLocalNotificationsPlugin.show(
        0,
        message.notification.title,
        message.notification.body,
        notificationDetails,
      );
    });
  }

  Future<void> getDynamicLinks() async {
    try {
      final PendingDynamicLinkData data =
          await FirebaseDynamicLinks.instance.getInitialLink();
      final Uri deepLink = data?.link;

      if (deepLink != null) {
        String url = deepLink.toString();
        List<String> arr = url.split('/');
        String kodeUpline = arr[arr.length - 1];
        bloc.kodeUpline.add(kodeUpline);
        print('KODE UPLINE: $kodeUpline');
      }
    } catch (e) {
      print("ERROR DYNAMIC LINK");
    }
  }

  // FEATURE CONTACTS
  // Future<void> _askPermissions() async {
  //   PermissionStatus status = await Permission.contacts.status;
  //   while (status != PermissionStatus.granted) {
  //     status = await Permission.contacts.status;
  //   }
  // }

  // void checkContact() async {
  //   print('CEK CONTACT MERCHANT BOT. VENDOR : $sigVendor');
  //   // Get all contacts on device
  //   await _askPermissions();
  //   // Get all contacts on device
  //   http.Response response = await http.get(
  //       Uri.parse('$apiUrl/app/checkContact'),
  //       headers: {'Authorization': sigVendor});
  //   if (response.statusCode == 200) {
  //     try {
  //       var res = json.decode(response.body);
  //       String namaMerchant = res['nama_merchant'];
  //       var data = res['data'];
  //       Iterable<Contact> updatedContact =
  //           await ContactsService.getContacts(query: namaMerchant);
  //       print('TOT CONTACT : ${updatedContact.length}');

  //       if (updatedContact.length > 0) {
  //         print('UPDATE CONTACT');
  //         // GENERATE MAP
  //         List<Item> items = [];
  //         for (var v in data) {
  //           var item = Item(label: 'Mobile', value: v['id'].toString());
  //           items.add(item);
  //         }
  //         // UPDATE CONTACT
  //         Contact updatedContact1 = new Contact();
  //         updatedContact1 = updatedContact.first;

  //         // Contact newContact = new Contact();
  //         updatedContact1.displayName = namaMerchant;
  //         updatedContact1.givenName = namaMerchant;

  //         updatedContact1.phones = items;
  //         print('contact phones -> ${updatedContact1.phones}');
  //         await ContactsService.updateContact(updatedContact1);
  //       } else {
  //         print('ADDED CONTACT');
  //         // GENERATE MAP
  //         List<Item> items = [];
  //         for (var v in data) {
  //           var item = Item(label: 'Mobile', value: v['id'].toString());
  //           items.add(item);
  //         }
  //         // END

  //         Contact newContact = new Contact();
  //         newContact.displayName = namaMerchant;
  //         newContact.givenName = namaMerchant;
  //         newContact.phones = items;

  //         await ContactsService.addContact(newContact);
  //         print('Contact : $newContact');
  //         print('Contact Phone : ${newContact.phones}');
  //       }
  //     } catch (err) {
  //       print('ERROR : ${err.toString()}');
  //     }
  //   }
  // }
  // END FEATURE CONTACTS

  @override
  Widget build(BuildContext context) {
    /*
    KHUSUS STATUSBAR PAKAIAJA
    */
    if (configAppBloc.packagename.valueWrapper?.value == 'co.pakaiaja.id') {
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(statusBarColor: Colors.blue));
    } else if (configAppBloc.packagename.valueWrapper?.value ==
        'com.maripay.app') {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Color(0XFFEA4C88),
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      );
    }

    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: Theme.of(context).copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
      ),
      // home: checkUser(),
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      locale: Locale('id'),
      supportedLocales: [
        Locale('id'),
        Locale('en'),
        Locale('fr'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: child,
        );
      },
      onGenerateRoute: (RouteSettings routeSettings) {
        transitionEffect.createCustomEffect(handle: (Curve curve,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child) {
          return new SlideTransition(
            position: new Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: const Offset(0.0, 0.0),
            ).animate(CurvedAnimation(parent: animation, curve: curve)),
            child: child,
          );
        });
        return PageRouteBuilder(
            settings: routeSettings,
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              switch (routeSettings.name) {
                case '/':
                  return Material(
                      child: loading
                          ? configAppBloc
                                  .layoutApp.valueWrapper?.value['splash'] ??
                              Scaffold(
                                  body: Container(
                                color: Theme.of(context).primaryColor,
                                width: double.infinity,
                                height: double.infinity,
                                child: Center(
                                    child: SpinKitFadingCircle(
                                        color: Colors.white, size: 35)),
                              ))
                          : homePageWidget);
                case '/topup':
                  return configAppBloc.layoutApp.valueWrapper?.value['topup'] !=
                          null
                      ? configAppBloc.layoutApp.valueWrapper?.value['topup']
                      : TopupPage();
                case '/notifikasi':
                  return Notifikasi();
                case '/komisi':
                  return RiwayatKomisi();
                case '/transfer':
                  return configAppBloc
                              .layoutApp.valueWrapper?.value['transfer'] !=
                          null
                      ? configAppBloc.layoutApp.valueWrapper?.value['transfer']
                      : TransferSaldo('');
                case '/customer-service':
                  return CS1();
                case '/rewards':
                  return ListReward();
                case '/withdraw':
                  return WithdrawPage();
                case '/myqr':
                  return MyQR();
                // HALAMAN FITUR KASIR
                case '/kasir':
                  return MainKasir();
                case '/kasir/satuan':
                  return SatuanPage();
                case '/kasir/category':
                  return CategoryPage();
                case '/kasir/customer':
                  return CustomerView();
                case '/kasir/supplier':
                  return SupplierView();
                case '/kasir/barang':
                  return BarangView();
                case '/kasir/persediaan':
                  return PersediaanView();
                case '/kasir/trx/penjualan':
                  return ListProduct();
                case '/kasir/hutang-piutang':
                  return HutangPiutang();
                case '/laporan':
                  return IndexLap();
                // END
                default:
                  return null;
              }
            },
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child) {
              return effectMap[PageTransitionType.rippleRightUp](
                  Curves.linear, animation, secondaryAnimation, child);
            });
      },
    );
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => PayuniApp.navigatorKey;
}

import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/screen/privacy_policy.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/config.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/forgot-password/step_1.dart';
import 'package:mobile/screen/otp.dart';
import 'package:mobile/screen/profile/cs/cs.dart';
import '../component/bezierContainer.dart';
import 'package:http/http.dart' as http;
import '../bloc/Api.dart' show apiUrl, sigVendor;
import 'cs.dart';
// import 'package:mobile/utils/debug_helper.dart'; // Unused import

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController nomorHp = TextEditingController();
  TextEditingController pin = TextEditingController();
  bool loading = false;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    analitycs.pageView('/login/', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Login',
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<String> pkgNameBorder = ['com.eralink.mobileapk'];

  submitLogin() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() {
        loading = true;
      });
      Map<String, dynamic> dataToSend = {
        'phone': nomorHp.text,
        'pin': pin.text
      };

      print('=== LOGIN DEBUG ===');
      print('API URL: ${apiUrl}/user/login');
      print('Request body: $dataToSend');
      print('Headers: {content-type: application/json, merchantCode: $sigVendor}');

      http.Response response = await http.post(
          Uri.parse(apiUrl + '/user/login'),
          body: jsonEncode(dataToSend),
          headers: {
            'content-type': 'application/json',
            'merchantCode': sigVendor
          });

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('=== LOGIN DEBUG END ===');
      setState(() {
        loading = false;
      });

      if (response.statusCode == 200) {
        try {
          var responseBody = jsonDecode(response.body);
          var data = responseBody['data'];

          // Debug logging untuk memastikan response structure
          print('Login response body: $responseBody');
          print('Data field: $data');

          if (data != null && data['phone'] != null && data['validate_id'] != null) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => OtpPage(data['phone'], data['validate_id'])));
          } else {
            // Jika data tidak lengkap, coba fallback ke halaman utama
            print('Data tidak lengkap, navigasi ke halaman utama');
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => configAppBloc.layoutApp.valueWrapper?.value['home'] ??
                    templateConfig[configAppBloc.templateCode.valueWrapper?.value ?? 0]));
          }
        } catch (e) {
          print('Error parsing response: $e');
          print('Response body: ${response.body}');
          return showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  title: Text('Error'),
                  content: Text('Terjadi kesalahan parsing response: $e'),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () =>
                            Navigator.of(context, rootNavigator: true).pop(),
                        child: Text('OK'))
                  ],
                );
              });
        }
      } else {
        try {
          String message = json.decode(response.body)['message'] ?? 'Terjadi kesalahan saat login';
          return showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  title: Text('Login Gagal'),
                  content: Text(message),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () =>
                            Navigator.of(context, rootNavigator: true).pop(),
                        child: Text('OK'))
                  ],
                );
              });
        } catch (e) {
          return showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  title: Text('Login Gagal'),
                  content: Text('Terjadi kesalahan saat login'),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () =>
                            Navigator.of(context, rootNavigator: true).pop(),
                        child: Text('OK'))
                  ],
                );
              });
        }
      }
    }
  }

  Widget _entryField(
    String title, {
    bool isPassword = false,
    int? maxLength,
    required TextEditingController controller,
    String? Function(String?)? validator,
    List<TextInputFormatter> formatters = const [],
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          packageName == 'com.eralink.mobileapk'
              ? TextFormField(
                  controller: controller,
                  validator: validator,
                  keyboardType: TextInputType.number,
                  cursorColor: Theme.of(context).primaryColor,
                  obscureText: isPassword,
                  maxLength: maxLength,
                  inputFormatters: formatters,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).secondaryHeaderColor)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).secondaryHeaderColor)),
                      fillColor: Colors.white,
                      filled: true),
                )
              : TextFormField(
                  controller: controller,
                  validator: validator,
                  keyboardType: TextInputType.number,
                  obscureText: isPassword,
                  maxLength: maxLength,
                  inputFormatters: formatters,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: Color(0xfff3f3f4),
                      filled: true))
        ],
      ),
    );
  }

  Widget _submitButton() {
    var loadingWidget = Center(
        child: SpinKitThreeBounce(
            color: Theme.of(context).primaryColor, size: 35));

    return loading
        ? loadingWidget
        : InkWell(
            onTap: submitLogin,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(vertical: 15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.shade200,
                        offset: Offset(2, 4),
                        blurRadius: 5,
                        spreadRadius: 2)
                  ],
                  gradient: packageName == "com.eralink.mobileapk"
                      ? LinearGradient(colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor
                        ])
                      : LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).secondaryHeaderColor,
                            ])),
              child: Text(
                'Masuk',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          );
  }

  Widget _createAccountLabel() {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Belum Punya Akun ?',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => PrivacyPolicyPage()));
            },
            child: Text(
              'Daftar Sekarang',
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageLogo() {
    return Hero(
      tag: 'icon-apk',
      child: Builder(builder: (_) {
        final dynamic iconApp = configAppBloc.iconApp.valueWrapper?.value;
        final String? url = iconApp is Map ? iconApp['logoLogin'] as String? : null;
        if (url == null || url.isEmpty) {
          return Container(
            height: MediaQuery.of(context).size.width * .15,
            alignment: Alignment.center,
            child: Icon(Icons.account_circle, size: MediaQuery.of(context).size.width * .12, color: Colors.grey.shade400),
          );
        }
        return CachedNetworkImage(
          imageUrl: url,
          height: MediaQuery.of(context).size.width * .15,
          fit: BoxFit.contain,
        );
      }),
    );
  }

  Widget _title() {
    return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: configAppBloc.namaApp.valueWrapper?.value,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).primaryColor,
          ),
        ));
  }

  Widget _emailPasswordWidget() {
    return Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          _entryField(
            "Nomor HP",
            controller: nomorHp,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          _entryField(
            "PIN",
            isPassword: true,
            controller: pin,
            maxLength: (configAppBloc.limitPinLogin.valueWrapper?.value == true)
                ? (configAppBloc.pinCount.valueWrapper?.value ?? 6)
                : null,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(pinCount),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
            image: configAppBloc.iconApp.valueWrapper?.value['texture'] != null
                ? DecorationImage(
                    image: CachedNetworkImageProvider(
                        configAppBloc.iconApp.valueWrapper?.value['texture'] ?? ''),
                    fit: BoxFit.fitWidth)
                : null),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -MediaQuery.of(context).size.height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer(),
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
              child: ListView(
                padding: EdgeInsets.all(20),
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height * .2),
                  configAppBloc.iconApp.valueWrapper?.value['logoLogin'] != null
                      ? _imageLogo()
                      : _title(),
                  SizedBox(
                    height: 50,
                  ),
                  _emailPasswordWidget(),
                  SizedBox(
                    height: 20,
                  ),
                  _submitButton(),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => StepOneForgotPIN())),
                      child: Text('Lupa PIN ?',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).primaryColor)),
                    ),
                  ),
                  SizedBox(height: 20),
                  (() {
                    // Debug logging for register condition
                    final info = configAppBloc.info.valueWrapper?.value;
                    print('=== LOGIN REGISTER DEBUG ===');
                    print('ConfigAppBloc.info exists: ${configAppBloc.info.valueWrapper != null}');
                    print('ConfigAppBloc.info.value exists: ${configAppBloc.info.valueWrapper?.value != null}');
                    if (info != null) {
                      print('📋 INFO VALUES:');
                      print('  register: ${info.register} (type: ${info.register.runtimeType})');
                      print('  stopAllRegister: ${info.stopAllRegister} (type: ${info.stopAllRegister.runtimeType})');
                      print('  inviteLink: ${info.inviteLink} (type: ${info.inviteLink.runtimeType})');
                      print('  enableSelectCA: ${info.enableSelectCA} (type: ${info.enableSelectCA.runtimeType})');

                      print('🔍 DETAILED REGISTER CHECK:');
                      print('  register value: "$info.register"');
                      print('  register == true: ${info.register == true}');
                      // register expected to be bool in AppInfo
                      print('  stopAllRegister == false: ${info.stopAllRegister == false}');
                      print('  Combined condition should be: ${(info.register == true && info.stopAllRegister == false)}');

                      // Check if register button should appear
                      bool shouldShowRegister = info.register == true;
                      print('✅ REGISTER BUTTON SHOULD SHOW: $shouldShowRegister');
                    } else {
                      print('❌ ConfigAppBloc.info.value is NULL');
                    }
                    print('=== LOGIN REGISTER DEBUG END ===');

                    return (configAppBloc.info.valueWrapper?.value.register == true)
                        ? Align(
                            alignment: Alignment.bottomCenter,
                            child: _createAccountLabel(),
                          )
                        : SizedBox(width: 0, height: 0);
                  })(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 15,
                left: 15,
              ),
              child: InkWell(
                onTap: () {
                  List<String> packages = [
                    'payku.id',
                    'pdpay.id',
                    'com.maripay.app',
                    'ayoba.co.id',
                    'com.ecuan.mobile',
                    'com.pgkreload.app',
                    Platform.isAndroid ? 'com.payuni.id' : 'co.payuni.id',
                  ];

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          packages.contains(packageName) ? CS1() : CS(),
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      backgroundColor: Theme.of(context).primaryColor,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      child: Icon(Icons.support_agent_rounded),
                      onPressed: null,
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Bantuan',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

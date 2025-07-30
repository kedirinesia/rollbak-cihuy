// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/disable.dart';
import 'package:nav/nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum OTP { sms, whatsapp, email }

class OtpPage extends StatefulWidget {
  final String phone;
  final String validateId;

  OtpPage(this.phone, this.validateId);
  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  bool loading = false;
  // TextEditingController kode = TextEditingController();
  OTP otpMethod;
  String validateId;
  TextEditingController otp1 = TextEditingController();
  TextEditingController otp2 = TextEditingController();
  TextEditingController otp3 = TextEditingController();
  TextEditingController otp4 = TextEditingController();

  void request(OTP method) async {
    setState(() {
      loading = true;
    });

    http.Response response = await http.post(
        Uri.parse('$apiUrl/user/login/send-otp'),
        headers: {
          'Content-Type': 'application/json',
          'merchantCode': sigVendor
        },
        body: json.encode(configAppBloc.brandId.valueWrapper?.value == null
            ? {
                'codeLength': configAppBloc.otpCount.valueWrapper?.value,
                'validate_id': widget.validateId,
                // 'type': method == OTP.sms ? 'sms' : 'whatsapp'
                'type': method == OTP.sms
                    ? 'sms'
                    : (method == OTP.email ? 'email' : 'whatsapp'),
              }
            : {
                'codeLength': configAppBloc.otpCount.valueWrapper?.value,
                'validate_id': widget.validateId,
                // 'type': method == OTP.sms ? 'sms' : 'whatsapp',
                'type': method == OTP.sms
                    ? 'sms'
                    : (method == OTP.email ? 'email' : 'whatsapp'),
                'wl_id': configAppBloc.brandId.valueWrapper?.value
              }));
    if (response.statusCode == 200) {
      this.validateId = json.decode(response.body)['validate_id'];
      this.otpMethod = method;
    } else {
      String message = json.decode(response.body)['message'] ??
          'Terjadi kendala saat meminta kode OTP';
      print(response.body);
      ScaffoldMessenger.of(context).showSnackBar(Alert(
        message,
        isError: true,
      ));
    }

    setState(() {
      loading = false;
    });
  }

  Future<Map<String, dynamic>> getUser(String token) async {
    http.Response response = await http
        .get(Uri.parse('$apiUrl/user/info'), headers: {'Authorization': token});
    return json.decode(response.body);
  }

  void sendDeviceToken() async {
    await http.post(Uri.parse('$apiUrl/user/device_token'),
        headers: {
          'Authorization': bloc.token.valueWrapper?.value,
          'Content-Type': 'application/json'
        },
        body: json.encode({'token': bloc.deviceToken.valueWrapper?.value}));
  }

  void verify() async {
    setState(() {
      loading = true;
    });

    http.Response response = await http.post(
      Uri.parse('$apiUrl/user/login/validate'),
      headers: {
        'Content-Type': 'application/json',
        'merchantCode': sigVendor,
      },
      body: json.encode({
        'phone': widget.phone,
        'otp': otp1.text + otp2.text + otp3.text + otp4.text,
        'validate_id': this.validateId,
      }),
    );

    dynamic data = json.decode(response.body);

    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = data['data'];
      prefs.setString('token', token);

      Map<String, dynamic> userInfo = await getUser(token);
      if (userInfo['status'] == 200) {
        UserModel profile = UserModel.fromJson(userInfo['data']);
        if (!profile.aktif) {
          setState(() {
            loading = false;
            Nav.clearAllAndPush(DisablePage(DisableType.member));
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

          Widget nextWidget = configAppBloc
                      .layoutApp.valueWrapper?.value['home'] !=
                  null
              ? configAppBloc.layoutApp.valueWrapper?.value['home']
              : templateConfig[configAppBloc.templateCode.valueWrapper?.value];
          Nav.clearAllAndPush(nextWidget);
        }
      } else {
        await prefs.clear();
        Widget nextWidget = configAppBloc
                    .layoutApp.valueWrapper?.value['home'] !=
                null
            ? configAppBloc.layoutApp.valueWrapper?.value['home']
            : templateConfig[configAppBloc.templateCode.valueWrapper?.value];
        Nav.clearAllAndPush(nextWidget);
      }
      // Navigator.of(context).pushAndRemoveUntil(
      //     MaterialPageRoute(builder: (_) => PayuniApp()),
      //     (Route<dynamic> route) => false);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(data['message'])));
      otp1.clear();
      otp2.clear();
      otp3.clear();
      otp4.clear();
    }

    setState(() {
      loading = false;
    });
  }

  Widget selectMethod() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: ListView(padding: EdgeInsets.all(20), children: <Widget>[
        SizedBox(height: 20),
        Hero(
          tag: 'icon-apk',
          child: SvgPicture.asset('assets/img/message.svg',
              width: MediaQuery.of(context).size.width * .45),
        ),
        SizedBox(height: 25),
        Text(
            'Kami akan mengirimkan anda ${configAppBloc.otpCount.valueWrapper?.value} digit kode OTP untuk melanjutkan proses masuk, silahkan pilih salah satu metode untuk menerima kode OTP dari kami',
            textAlign: TextAlign.center),
        SizedBox(height: 20),
        packageName == "com.eralink.mobileapk"
            ? Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(.1),
                          offset: Offset(5, 10.0),
                          blurRadius: 20)
                    ]),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(.2),
                    child: SvgPicture.asset('assets/img/sms.svg'),
                  ),
                  title: Text('SMS'),
                  onTap: () {
                    request(OTP.sms);
                  },
                ),
              )
            : SizedBox(),
        SizedBox(height: packageName == "com.eralink.mobileapk" ? 10 : 0),
        Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(.1),
                      offset: Offset(5, 10.0),
                      blurRadius: 20)
                ]),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(.2),
                child: SvgPicture.asset('assets/img/whatsapp.svg'),
              ),
              title: Text('WhatsApp'),
              onTap: () {
                request(OTP.whatsapp);
              },
            )),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(.1),
                    offset: Offset(5, 10.0),
                    blurRadius: 20),
              ]),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Image.asset('assets/img/email.png'),
            ),
            title: Text('Email'),
            onTap: () {
              request(OTP.email);
            },
          ),
        ),
      ]),
    );
  }

  Widget loadingWidget() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: SpinKitThreeBounce(
          color: Theme.of(context).primaryColor,
          size: 35,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          title: Text(otpMethod != null ? 'Verifikasi OTP' : 'Pilih Metode',
              style: TextStyle(color: Theme.of(context).primaryColor)),
          centerTitle: true,
          elevation: 0),
      body: loading
          ? loadingWidget()
          : otpMethod == null
              ? selectMethod()
              : Stack(
                  children: [
                    SafeArea(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 48),
                              padding: EdgeInsets.all(16),
                              child: Image.asset('assets/img/payku/otp.png'),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 19, right: 19),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Masukkan OTP',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Text(
                                    'Kami akan mengirimkan anda ${configAppBloc.otpCount.valueWrapper?.value} digit kode OTP untuk melanjutkan proses masuk, silahkan pilih salah satu metode untuk menerima kode OTP dari kami',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xff030303),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                ],
                              ),
                            ),
                            Form(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    height: 61,
                                    width: 60,
                                    child: TextFormField(
                                      controller: otp1,
                                      onChanged: (value) {
                                        if (value.length == 1) {
                                          FocusScope.of(context).nextFocus();
                                        }
                                      },
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                      decoration: InputDecoration(
                                          hintText: "0",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          filled: true,
                                          fillColor: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(.1)),
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(1),
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    height: 61,
                                    width: 60,
                                    child: TextFormField(
                                      controller: otp2,
                                      onChanged: (value) {
                                        if (value.length == 1) {
                                          FocusScope.of(context).nextFocus();
                                        }
                                      },
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                      decoration: InputDecoration(
                                          hintText: "0",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          filled: true,
                                          fillColor: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(.1)),
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(1),
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    height: 61,
                                    width: 60,
                                    child: TextFormField(
                                      controller: otp3,
                                      onChanged: (value) {
                                        if (value.length == 1) {
                                          FocusScope.of(context).nextFocus();
                                        }
                                      },
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                      decoration: InputDecoration(
                                          hintText: "0",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          filled: true,
                                          fillColor: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(.1)),
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(1),
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    height: 61,
                                    width: 60,
                                    child: TextFormField(
                                      controller: otp4,
                                      onChanged: (value) {
                                        verify();
                                      },
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                      decoration: InputDecoration(
                                          hintText: "0",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          filled: true,
                                          fillColor: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(.1)),
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(1),
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                    ),
                                  ),
                                ],
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
}

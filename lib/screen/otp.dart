// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/config.dart';
import 'package:mobile/index.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/disable.dart';
import 'package:nav/nav.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
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
  TextEditingController kode = TextEditingController();
  OTP otpMethod;
  String validateId;

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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kendala saat meminta kode OTP')));
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
        'otp': int.parse(kode.text),
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
                  .layoutApp.valueWrapper?.value['home'] ??
              templateConfig[configAppBloc.templateCode.valueWrapper?.value];
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
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(data['message'])));
      kode.clear();
    }

    setState(() {
      loading = false;
    });
  }

  List<String> packageNames = ["com.eralink.mobileapk", "com.talentapay.android"];

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
        packageNames.contains(packageName)
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
        SizedBox(height: packageNames.contains(packageName) ? 10 : 0),
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
                blurRadius: 20
              ),
            ]
          ),
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
        )
      ]),
    );
  }

  Widget loadingWidget() {
    return Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
            child: SpinKitThreeBounce(
                color: Theme.of(context).primaryColor, size: 35)));
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
              : Container(
                  width: double.infinity,
                  height: double.infinity,
                  child:
                      ListView(padding: EdgeInsets.all(20), children: <Widget>[
                    SizedBox(height: 35),
                    SvgPicture.asset('assets/img/sent.svg',
                        width: MediaQuery.of(context).size.width * .35),
                    SizedBox(height: 25),
                    Text(
                      'Kami telah mengirimkan anda pesan ${otpMethod == OTP.sms ? 'SMS' : otpMethod == OTP.email ? 'Email' : 'WhatsApp'} berupa kode OTP, silahkan masukkan ${configAppBloc.otpCount.valueWrapper?.value} digit kode OTP untuk melanjutkan proses masuk',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40),
                    
SizedBox(
  height: 80, // ⬅️ tinggi keseluruhan field OTP
  child: PinInputTextField(
    controller: kode,
    pinLength: configAppBloc.otpCount.valueWrapper?.value ?? 4,
    autoFocus: true,
    keyboardType: TextInputType.number,
    decoration: BoxLooseDecoration(
      strokeColorBuilder: PinListenColorBuilder(
        Theme.of(context).primaryColor,
        Colors.grey.shade300,
      ),
      bgColorBuilder: FixedColorBuilder(Colors.white),
      radius: Radius.circular(18),
      strokeWidth: 2,
      gapSpace: 20, 
      textStyle: TextStyle(
        fontSize: 26,  
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    ),
    cursor: Cursor(
      width: 3,
      color: Theme.of(context).primaryColor,
      radius: Radius.circular(1),
      enabled: true,
    ),
    onChanged: (value) {
      if (value.length == configAppBloc.otpCount.valueWrapper?.value) {
        verify();
      }
    },
  ),
)

 ]
                ),
    )
    );
  }
}

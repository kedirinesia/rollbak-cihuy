import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/config.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/cs.dart';
import 'package:mobile/screen/forgot-password/step_1.dart';
import 'package:mobile/screen/otp.dart';
import 'package:mobile/screen/profile/cs/cs.dart';
import 'package:mobile/screen/register.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _phone = TextEditingController();
  TextEditingController _pin = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _phone.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (_loading) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
    });

    http.Response response = await http.post(
      Uri.parse('$apiUrl/user/login'),
      headers: {
        'Content-Type': 'application/json',
        'merchantCode': sigVendor,
      },
      body: json.encode({
        'phone': _phone.text.trim(),
        'pin': _pin.text.trim(),
      }),
    );

    if (response.statusCode == 200) {
      String validateId = json.decode(response.body)['data']['validate_id'];
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpPage(_phone.text.trim(), validateId),
        ),
      );
    } else {
      String message;
      try {
        message = json.decode(response.body)['message'];
      } catch (_) {
        message = 'Terjadi kesalahan saat mengambil data dari server';
      }

      showToast(context, message);
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(),
        children: [
          Container(
            padding: EdgeInsets.all(15),
            color: Theme.of(context).primaryColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top),
                SizedBox(height: 5),
                Align(
                  alignment: Alignment.centerRight,
                  child: MaterialButton(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    color: Colors.white,
                    
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    child: Text(
                      'Bantuan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    shape: StadiumBorder(),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CS1(),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * .075),
                Text(
                  'Selamat Datang di $appName',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Aplikasi isi Pulsa, Data, PPOB, dan Kasir Online',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '$appName aplikasinya PD transaksinya',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * .075),
              ],
            ),
          ),
          Stack(
            fit: StackFit.loose,
            children: [
              Container(
                width: double.infinity,
                height: 50,
                color: Theme.of(context).primaryColor,
              ),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
              ),
            ],
          ),
          ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 15),
            children: [
              Text(
                'Login',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Nomor Telepon',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                textAlignVertical: TextAlignVertical.center,
                autofocus: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  isDense: true,
                  isCollapsed: true,
                  hintText: 'Contoh: 081234567xxx',
                  hintStyle: TextStyle(color: Colors.grey),
                  suffixIcon: Icon(
                    Icons.phone,
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Kode PIN',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              TextField(
                controller: _pin,
                keyboardType: TextInputType.phone,
                textAlignVertical: TextAlignVertical.center,
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: InputDecoration(
                  isDense: true,
                  isCollapsed: true,
                  suffixIcon: Icon(
                    Icons.lock,
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: 10),
              MaterialButton(
                child: _loading
                    ? Container(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : Text(
                        'Login Sekarang',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                color: Colors.grey.shade100,
                textColor: Colors.black,
                minWidth: double.infinity,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                onPressed: login,
              ),
              SizedBox(height: 5),
              Text(
                'Kode OTP untuk Login akan dikirim ke nomor telepon melalui WhatsApp atau SMS',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * .05),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lupa PIN? ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StepOneForgotPIN(),
                      ),
                    ),
                    child: Text(
                      'Atur ulang',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text(
                'Belum punya akun?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              MaterialButton(
                minWidth: double.infinity,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                elevation: 0,
                child: Text(
                  'Daftar Sekarang',
                  style: TextStyle(fontSize: 12),
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RegisterUser(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

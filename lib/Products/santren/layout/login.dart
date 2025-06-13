// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/config.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/forgot-password/step_1.dart';
import 'package:mobile/screen/otp.dart';
import 'package:mobile/Products/santren/layout/register.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loading = false;
  bool _hidePin = true;
  TextEditingController _phone = TextEditingController();
  TextEditingController _pin = TextEditingController();

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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Area atas putih
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Icon(Icons.help_outline, color: Color(0xFF4CAF00), size: 20),
                      SizedBox(width: 6),
                      Text("Bantuan",
                          style: TextStyle(fontSize: 14, color: Color(0xFF4CAF00))),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                configAppBloc.iconApp.valueWrapper?.value['logo'] != null
                    ? CachedNetworkImage(
                        imageUrl: configAppBloc.iconApp.valueWrapper?.value['logo'],
                        width: 170,  
                      )
                    : Text(appName,
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF00))),
                SizedBox(height: 16),
                Text("Jadilah Mitra Santren Pay",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.black)),
                SizedBox(height: 5),
                Text("Bisnis Terbaik, simpel dan dompet jadi tebel",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                    
              ],
              
            ),
          
          ),
          SizedBox(height: 100,),

      
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF4CAF00),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                    children: [
                      Center(
                        child: Text("LOGIN AKUN",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30)),
                      ),
                      SizedBox(height: 25),

                      // Input Nomor HP
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: _phone,
                          style: TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(13),
                          ],
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person, color: Colors.white),
                            hintText: 'Nomor Hp',
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),

                      // Input PIN
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: _pin,
                          style: TextStyle(color: Colors.white),
                          obscureText: _hidePin,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock, color: Colors.white),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _hidePin
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _hidePin = !_hidePin;
                                });
                              },
                            ),
                            hintText: 'Pin Anda',
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),

                      // Tombol Masuk
                      MaterialButton(
                        height: 50,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        onPressed: login,
                        child: _loading
                            ? CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Color(0xFF4CAF00)),
                              )
                            : Text("Masuk",
                                style: TextStyle(
                                    color: Color(0xFF4CAF00),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                      ),
                      SizedBox(height: 30),

                      // Daftar akun
                      Center(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => configAppBloc.layoutApp
                                          .valueWrapper.value['register'] ??
                                      RegisterUser()),
                            );
                          },
                          child: Text("Belum punya akun? Daftar sekarang",
                              style: TextStyle(
                                  color: Colors.yellowAccent,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14)),
                        ),
                      ),
                      SizedBox(height: 10),

                      // Lupa PIN
                      Center(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => StepOneForgotPIN()),
                            );
                          },
                          child: Text("Lupa Pin? Atur Ulang",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

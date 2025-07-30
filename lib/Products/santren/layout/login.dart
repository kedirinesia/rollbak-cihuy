// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/Products/santren/layout/step_1.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/config.dart';
import 'package:mobile/modules.dart';
  
import 'package:mobile/screen/otp.dart';
import 'package:mobile/Products/santren/layout/register.dart';

import 'BantuanScreen.dart';

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
    // Ambil ukuran layar
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;

    // Persentase padding/jarak
    double topPadding = screenHeight * 0.01; // Supaya header naik ke atas
    double logoHeight = screenHeight * 0.15;
    double verticalSpace = screenHeight * 0.03;
    double formPadding = screenWidth * 0.05;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: formPadding,
                    vertical: topPadding,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => BantuanScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.support_agent,
                              size: 25,
                              color: Color(0xFF4CAF00),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Bantuan",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4CAF00),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Kalau ada widget lain di header, tambahkan di sini
                    ],
                  ),
                ),
                SizedBox(height: verticalSpace),
                Center(
                  child: configAppBloc.iconApp.valueWrapper?.value['logo'] !=
                          null
                      ? CachedNetworkImage(
                          imageUrl:
                              configAppBloc.iconApp.valueWrapper?.value['logo'],
                          height: logoHeight,
                          fit: BoxFit.contain,
                        )
                      : Text(
                          appName,
                          style: TextStyle(
                            fontSize: screenWidth * 0.09,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF00),
                          ),
                        ),
                ),
                SizedBox(height: verticalSpace / 1.5),
                Center(
                  child: Text(
                    "Jadilah Mitra Santren Pay",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.07,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 5),
                Center(
                  child: Text(
                    "Bisnis Terbaik, simpel dan dompet jadi tebel",
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                    height: isSmallScreen
                        ? screenHeight * 0.03
                        : screenHeight * 0.07),

                // Area bawah hijau, Expanded agar flexible
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFF4CAF00),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: formPadding,
                          vertical: isSmallScreen ? 16 : 32,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 400),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "LOGIN AKUN",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.065,
                                ),
                              ),
                              SizedBox(height: verticalSpace),

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
                                    prefixIcon:
                                        Icon(Icons.person, color: Colors.white),
                                    hintText: 'Nomor Hp',
                                    hintStyle: TextStyle(color: Colors.white70),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.02,
                                      horizontal: 16,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: verticalSpace / 1.5),

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
                                    prefixIcon:
                                        Icon(Icons.lock, color: Colors.white),
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
                                      vertical: screenHeight * 0.02,
                                      horizontal: 16,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: verticalSpace),

                              // Tombol Masuk
                              SizedBox(
                                width: double.infinity,
                                height: screenHeight * 0.065,
                                child: MaterialButton(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  onPressed: login,
                                  child: _loading
                                      ? SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Color(0xFF4CAF00)),
                                            strokeWidth: 3,
                                          ),
                                        )
                                      : Text(
                                          "Masuk",
                                          style: TextStyle(
                                            color: Color(0xFF4CAF00),
                                            fontWeight: FontWeight.bold,
                                            fontSize: screenWidth * 0.045,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(height: verticalSpace),

                              // Daftar akun
                              Center(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            configAppBloc.layoutApp.valueWrapper
                                                .value['register'] ??
                                            RegisterUser(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Belum punya akun? Daftar sekarang",
                                    style: TextStyle(
                                      color: Colors.yellowAccent,
                                      fontWeight: FontWeight.w500,
                                      fontSize: screenWidth * 0.038,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: verticalSpace / 2),

                              // Lupa PIN
                              Center(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => StepOneForgotPIN(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Lupa Pin? Atur Ulang",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: screenWidth * 0.038,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/config.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/forgot-password/step_2.dart';

class StepOneForgotPIN extends StatefulWidget {
  @override
  _StepOneForgotPINState createState() => _StepOneForgotPINState();
}

class _StepOneForgotPINState extends State<StepOneForgotPIN> {
  TextEditingController nomor = TextEditingController();
  bool loading = false;

  void login() async {
    if (nomor.text.length < 10 || !nomor.text.startsWith('08')) {
      showToast(context, 'Nomor yang anda masukkan tidak valid');
      return;
    }

    setState(() {
      loading = true;
    });

    http.Response response = await http.post(
      Uri.parse('$apiUrl/user/forgot/otp'),
      headers: {'Content-Type': 'application/json', 'merchantCode': sigVendor},
      body: json.encode(
        configAppBloc.brandId.valueWrapper?.value == null
            ? {
                'phone': nomor.text,
                'codeLength': configAppBloc.otpCount.valueWrapper?.value,
              }
            : {
                'phone': nomor.text,
                'codeLength': configAppBloc.otpCount.valueWrapper?.value,
                'wl_id': configAppBloc.brandId.valueWrapper?.value,
              },
      ),
    );

    if (response.statusCode == 200) {
      String id = json.decode(response.body)['data']['validate_id'];
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => StepTwoForgotPIN(nomor.text, id),
        ),
      );
    } else {
      String message = json.decode(response.body)['message'] ??
          'Terjadi kendala pada server';
      showToast(context, message);
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: loading
          ? Center(
              child: SpinKitThreeBounce(
                  color: Theme.of(context).primaryColor, size: 35),
            )
          : Column(
              children: [
                // Header gembok + teks besar
                SizedBox(height: 20),
                Container(
                  height: MediaQuery.of(context).size.height * 0.45,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline,
                          size: 130, color: Color(0xFF4CAF00)),
                      SizedBox(height: 20),
                     RichText(
                      
  textAlign: TextAlign.center,
  text: TextSpan(
    style: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 32,
      color: Colors.black87,
    ),
    children: [
      TextSpan(
        text: 'Forgot\n',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      TextSpan(
        text: 'Password?',
        style: TextStyle(fontWeight: FontWeight.w400),
      ),
    ],
  ),
),
                      SizedBox(height: 12),
                      Text(
                        "Kami akan mengirimkan kode otp untuk memastikan bahwa nomor yang anda gunakan untuk login adalah milik anda",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Form box hijau
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFF4CAF00),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nomor Hp",
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14),
                        ),
                        SizedBox(height: 10),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.phone, color: Color(0xFF4CAF00)),
                              SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: nomor,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                      fontFamily: 'Montserrat', fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'No Hp',
                                    hintStyle: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 14),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              "Kirim Kode",
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }
}

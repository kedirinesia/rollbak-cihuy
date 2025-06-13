// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile/Products/payuni2/config.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/models/user.dart';
import 'package:http/http.dart' as http;

class GenerateRefCode extends StatefulWidget {
  final Function getUserInfo;

  GenerateRefCode(this.getUserInfo, {Key key}) : super(key: key);

  @override
  State<GenerateRefCode> createState() => _GenerateRefCodeState();
}

class _GenerateRefCodeState extends State<GenerateRefCode> {
  TextEditingController refCodeController = TextEditingController(text: '');

  UserModel userInfo;

  @override
  void initState() {
    userInfo = Hive.box('ref-code').length != 0
        ? UserModel.parse(Hive.box('ref-code').getAt(0))
        : null;

    if (userInfo != null) {
      refCodeController.text = userInfo.inviteCode;
    }

    super.initState();
  }

  @override
  void dispose() {
    refCodeController.dispose();
    super.dispose();
  }

  void generateReferalCode() async {
    try {
      if (refCodeController.text.isNotEmpty) {
        final alphanumeric = RegExp(r'^[a-zA-Z0-9_-]+$');
        String refCode = '';
        if (!alphanumeric.hasMatch(refCodeController.text)) {
          SnackBar snackBar = Alert(
              'Kode referal hanya mendukung Huruf, Angka, - (Dash/Strip) dan _ (Underscore)',
              isError: true);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          refCode = refCodeController.text;
        }

        if (refCode.isNotEmpty) {
          http.Response response = await http.post(
            Uri.parse('$apiUrl/user/generate/invite_code'),
            body: jsonEncode({'invite_code': refCode}),
            headers: {
              'content-type': 'application/json',
              'authorization': bloc.token.valueWrapper?.value,
            },
          );

          var data = json.decode(response.body);

          if (response.statusCode == 200) {
            SnackBar snackBar = Alert(data['message']);
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            widget.getUserInfo();
          } else {
            SnackBar snackBar = Alert(data['message'], isError: true);
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        }
      } else {
        SnackBar snackBar =
            Alert('Kode referal tidak boleh kosong!', isError: true);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (Hive.box('ref-code').isEmpty) {
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            isScrollControlled: true,
            builder: (BuildContext context) {
              return Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          'Buat Kode Referal Kamu',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      SizedBox(height: 20),
                      ValueListenableBuilder(
                        valueListenable: Hive.box('ref-code').listenable(),
                        builder: (context, value, child) {
                          return Column(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  enableInteractiveSelection: true,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey.shade200,
                                    prefixIcon: Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          start: 13.0, end: 12.0, top: 16),
                                      child: FaIcon(
                                        FontAwesomeIcons.idCard,
                                        size: 15,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.only(
                                      left: 12.0,
                                      bottom: 2.0,
                                      top: 5.0,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    hintText: "Masukan kode referal kamu",
                                    hintStyle: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  controller: refCodeController,
                                  readOnly: value.length != 0 ? true : false,
                                ),
                              ),
                              SizedBox(height: 20),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: EdgeInsets.only(right: 20),
                                  child: value.length == 0
                                      ? ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            primary:
                                                Theme.of(context).primaryColor,
                                          ),
                                          onPressed: () {
                                            generateReferalCode();
                                            Navigator.of(context).pop(context);
                                          },
                                          icon: FaIcon(
                                            FontAwesomeIcons.floppyDisk,
                                            size: 15,
                                            color: Colors.black,
                                          ),
                                          label: Text(
                                            'SIMPAN PERUBAHAN',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        )
                                      : ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            primary:
                                                Theme.of(context).primaryColor,
                                            onPrimary:
                                                Theme.of(context).primaryColor,
                                            onSurface:
                                                Theme.of(context).primaryColor,
                                          ),
                                          onPressed: null,
                                          icon: FaIcon(
                                            FontAwesomeIcons.floppyDisk,
                                            size: 15,
                                            color: Colors.black12,
                                          ),
                                          label: Text(
                                            'SIMPAN PERUBAHAN',
                                            style: TextStyle(
                                                color: Colors.black12),
                                          ),
                                        ),
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          SnackBar snackBar =
              SnackBar(content: Text('Kode Referal anda sudah pernah dibuat!'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      child: Container(
        child: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.highlighter,
              size: 20,
            ),
            SizedBox(width: 5),
            Text('Generate'),
          ],
        ),
      ),
    );
  }
}

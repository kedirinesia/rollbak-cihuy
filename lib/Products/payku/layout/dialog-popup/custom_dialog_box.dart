// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/Products/payku/layout/dialog-popup/constants.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Bloc.dart' show bloc;
import 'package:quickalert/quickalert.dart';

class CustomDialogBox extends StatefulWidget {
  final String title;
  final String nama;
  final String descriptions;
  final String poin;
  final String text1;
  final String text2;
  final String id;
  // final Image img;

  const CustomDialogBox({
    this.title,
    this.nama,
    this.descriptions,
    this.poin,
    this.text1,
    this.text2,
    this.id,
  });

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  void tukarReward(String id) async {
    http.Response response = await http.post(Uri.parse('$apiUrl/reward/tukar'),
        headers: {
          'Authorization': bloc.token.valueWrapper?.value,
          'Content-Type': 'application/json'
        },
        body: json.encode({'id': id}));

    print(response.body);
    String message = json.decode(response.body)['message'];
    if (response.statusCode == 200) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Penukaran Berhasil',
        text: message,
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
        },
      );
    } else {
      String message = json.decode(response.body)['message'];
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Penukaran Gagal',
        text: message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
              left: Constants.padding,
              top: Constants.avatarRadius + Constants.padding,
              right: Constants.padding,
              bottom: Constants.padding),
          margin: EdgeInsets.only(top: Constants.avatarRadius),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.padding),
              boxShadow: [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.title,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Nama',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              SizedBox(height: 5),
              Text(
                widget.nama ?? '',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Deskripsi',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              SizedBox(height: 5),
              Text(
                widget.descriptions ?? '',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Poin Dibutuhkan',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              SizedBox(height: 5),
              Text(
                widget.poin ?? '',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 22),
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => tukarReward(widget.id),
                      child: Text(
                        widget.text1 ?? '',
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                    SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        widget.text2 ?? '',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: Constants.padding,
          right: Constants.padding,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: Constants.avatarRadius,
            child: ClipRRect(
                borderRadius:
                    BorderRadius.all(Radius.circular(Constants.avatarRadius)),
                child: Image.asset(
                  "assets/img/gift.gif",
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                )),
          ),
        ),
      ],
    );
  }
}

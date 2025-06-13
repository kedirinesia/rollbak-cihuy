// @dart=2.9

import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/Products/funfast/layout/invite/invite_qrcode.style.dart';
import 'package:mobile/Products/funfast/layout/invite/invite_referal_code_info.dart';
import 'package:qr_flutter/qr_flutter.dart';

class InviteQRCode extends StatefulWidget {
  Uri inviteLink;
  bool loading;
  Function getUserInfo;
  InviteQRCode({this.inviteLink, this.loading, this.getUserInfo, Key key})
      : super(key: key);

  @override
  State<InviteQRCode> createState() => _InviteQRCodeState();
}

class _InviteQRCodeState extends State<InviteQRCode> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              SizedBox(height: 15),
              Text(
                'Scan QR untuk Mengundang Teman Kamu',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 28),
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                child: QrImageView(
                  data: widget.inviteLink.toString(),
                  version: QrVersions.auto,
                  size: MediaQuery.of(context).size.width * .65,
                  padding: EdgeInsets.all(30),
                  backgroundColor: Theme.of(context).canvasColor,
                  foregroundColor: Colors.black,
                ),
              ),
              SizedBox(height: 14),
              InkWell(
                onTap: () {
                  Clipboard.setData(
                      ClipboardData(text: widget.inviteLink.toString()));
                  final snackBar = SnackBar(
                    content:
                        const Text('Tautan berhasil disalin ke papan klip'),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      child: Txt(
                        widget.inviteLink.toString(),
                        style: InviteQRCodeStyle.text,
                      ),
                    ),
                    SizedBox(width: 5),
                    FaIcon(
                      FontAwesomeIcons.copy,
                      size: 17,
                      color: Colors.grey.shade800,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Txt(
                'Ini adalah kode referal, kamu harus memberitahukan teman untuk melakukan input kode pada saat melakukan pendaftaran',
                style: InviteQRCodeStyle.text
                  ..clone()
                  ..textColor(Colors.grey.shade600),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
        InviteReferalCodeInfo(widget.getUserInfo)
      ],
    );
  }
}

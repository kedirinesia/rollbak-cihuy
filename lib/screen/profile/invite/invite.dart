// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/config.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/profile/invite/invite_controller.dart';
import 'package:qr_flutter/qr_flutter.dart';

class InvitePage extends StatefulWidget {
  @override
  _InvitePageState createState() => _InvitePageState();
}

class _InvitePageState extends InvitePageController {
  @override
  void initState() {
    super.initState();
    analitycs.pageView('/invite', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Invite Link',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Undang Teman'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: packageName == 'com.lariz.mobile'
              ? Theme.of(context).secondaryHeaderColor
              : Theme.of(context).primaryColor,
        ),
        body: loading
            ? Center(
                child: SpinKitThreeBounce(
                    color: packageName == 'com.lariz.mobile'
                        ? Theme.of(context).secondaryHeaderColor
                        : Theme.of(context).primaryColor,
                    size: 35))
            : Container(
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.all(15),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      QrImageView(
                        data: inviteLink.toString(),
                        version: QrVersions.auto,
                        size: MediaQuery.of(context).size.width * .65,
                        backgroundColor: Theme.of(context).canvasColor,
                        foregroundColor: Colors.black,
                      ),
                      SizedBox(height: 15),
                      Text(
                          'Ajak teman kamu sebanyak-banyaknya dan dapatkan komisi dari setiap transaksi yang dilakukan oleh teman kamu. Salin tautan di bawah ini dan bagikan kepada teman-temanmu agar temanmu dapat mendaftar di $appName melalui ajakanmu',
                          textAlign: TextAlign.center),
                      SizedBox(height: 15),
                      packageName == 'com.eralink.mobileapk'
                        ? TextFormField(
                              style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
                              controller: url,
                              readOnly: true,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                  ),
                                  isDense: true,
                                  suffixIcon: Builder(
                                    builder: (context) => IconButton(
                                      icon: Icon(Icons.content_copy, color: Theme.of(context).primaryColor,),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(
                                            text: inviteLink.toString()));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                              'Tautan berhasil disalin ke papan klip'),
                                        ));
                                      },
                                    ),
                                  )))
                        : TextFormField(
                              controller: url,
                              readOnly: true,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  suffixIcon: Builder(
                                    builder: (context) => IconButton(
                                      icon: Icon(Icons.content_copy),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(
                                            text: inviteLink.toString()));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                              'Tautan berhasil disalin ke papan klip'),
                                        ));
                                      },
                                    ),
                                  ))),
                    ]),
              ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: packageName == 'com.lariz.mobile'
                ? Theme.of(context).secondaryHeaderColor
                : Theme.of(context).primaryColor,
            child: Icon(Icons.share),
            onPressed: () => share()));
  }
}

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/provider/api.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class MyQrisPage extends StatefulWidget {
  @override
  _MyQrisPageState createState() => _MyQrisPageState();
}

class _MyQrisPageState extends State<MyQrisPage> {
  String? _qrImage;

  Future<void> _getQr() async {
    try {
      dynamic data = await api.post('/qris/generate');
      setState(() {
        _qrImage = data['image'];
      });
    } catch (err) {
      print(err);
      ScaffoldMessenger.of(context).showSnackBar(
        Alert(
          'Merchant belum mendukung static QRIS',
          isError: true,
        ),
      );
      return Navigator.of(context).pop();
    }
  }

  Future<void> _downloadImage() async {
    // REQUEST STORAGE PERMISSION
    await [Permission.storage, Permission.accessMediaLocation].request();

    Directory dir = Directory('/storage/emulated/0/Download');
    await dir.create();
    File img = await File(
            '${dir.path}/qris_saya_${bloc.user.valueWrapper!.value.id}.jpg')
        .create();
    http.Response res = await http.get(Uri.parse(_qrImage!));
    await img.writeAsBytes(res.bodyBytes);
    ScaffoldMessenger.of(context).showSnackBar(
        Alert('Berhasil mengunduh dokumen QRIS di \'${dir.path}\''));
  }

  @override
  void initState() {
    _getQr();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QRIS Saya'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _qrImage == null
          ? SpinKitFadingCircle(
              color: Theme.of(context).primaryColor,
            )
          : Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: _qrImage!,
                        progressIndicatorBuilder: (_, __, ___) =>
                            SpinKitFadingCircle(
                          color: Theme.of(context).primaryColor,
                        ),
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    elevation: 0,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.download,
                          size: 18,
                        ),
                        SizedBox(width: 5),
                        Text('Unduh Dokumen'),
                      ],
                    ),
                    onPressed: _downloadImage,
                  ),
                ),
              ],
            ),
    );
  }
}

import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/provider/api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

class MyQrisPage extends StatefulWidget {
  @override
  _MyQrisPageState createState() => _MyQrisPageState();
}

class _MyQrisPageState extends State<MyQrisPage> {
  String? _qrImage;
  ScreenshotController _screenshotController = ScreenshotController();
  File? image;

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

  // Future<void> _downloadImage() async {
  //   // REQUEST STORAGE PERMISSION
  //   await [Permission.storage, Permission.accessMediaLocation].request();

  //   Directory dir = Directory('/storage/emulated/0/Download');
  //   await dir.create();
  //   File img = await File('${dir.path}/qris_saya_${bloc.user.valueWrapper!.value.id}.jpg').create();
  //   http.Response res = await http.get(Uri.parse(_qrImage!));
  //   await img.writeAsBytes(res.bodyBytes);
  //   ScaffoldMessenger.of(context).showSnackBar(Alert('Berhasil mengunduh dokumen QRIS di \'${dir.path}\''));
  // }

  @override
  void initState() {
    _getQr();
    super.initState();
  }

  Future<void> _takeScreenshot() async {
    Directory temp = await getTemporaryDirectory();
    image = await File('${temp.path}/qris.png').create();
    Uint8List? bytes = await _screenshotController.capture(
      pixelRatio: 2.5,
      delay: Duration(milliseconds: 100),
    );
    await image?.writeAsBytes(bytes!);
    if (image == null) return;
    await Share.file(
      'QRIS Saya',
      'qris.png',
      image!.readAsBytesSync(),
      'image/png',
    );
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
                  child: Screenshot(
                    controller: _screenshotController,
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                  "https://dokumen.payuni.co.id/logo/stokpay/bg.png"),
                              fit: BoxFit.cover)),
                      width: double.infinity,
                      height: double.infinity,
                      padding: EdgeInsets.all(30),
                      child: Column(
                        children: [
                          // logo
                          Container(
                            child: CachedNetworkImage(
                              imageUrl:
                                  'https://dokumen.payuni.co.id/logo/stokpay/logo.png',
                              progressIndicatorBuilder: (_, __, ___) =>
                                  SpinKitFadingCircle(
                                color: Theme.of(context).primaryColor,
                              ),
                              width: 180,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
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
                          SizedBox(height: 35.0),
                          // text
                          Container(
                            child: Text(
                              'Menerima Pembayaran Melalui :',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          // futer
                          SizedBox(height: 20.0),
                          Flexible(
                            child: Container(
                              child: CachedNetworkImage(
                                imageUrl:
                                    'https://dokumen.payuni.co.id/logo/stokpay/footer.png',
                                progressIndicatorBuilder: (_, __, ___) =>
                                    SpinKitFadingCircle(
                                  color: Theme.of(context).primaryColor,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
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
                        Text('Unduh QRIS'),
                      ],
                    ),
                    onPressed: _takeScreenshot,
                  ),
                ),
              ],
            ),
    );
  }
  // @override
  // void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  //   super.debugFillProperties(properties);
  //   properties.add(DiagnosticsProperty<File>('_imageFile', _imageFile));
  // }
}
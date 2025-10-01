import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/provider/api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:mobile/utils/debug_helper.dart';

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
      String? imageUrl;
      if (data is Map && data['image'] != null) {
        imageUrl = data['image'] as String;
      } else if (data is String) {
        imageUrl = data;
      }
      setState(() {
        _qrImage = imageUrl;
      });
    } catch (err) {
      DebugHelper.debugPrint('QRIS generate error: $err');
      // Hilangkan validasi: jangan tampilkan error merah, tetap berada di halaman
      // dan biarkan _qrImage null sehingga spinner tampil. Jika ingin fallback,
      // bisa set _qrImage ke string kosong agar tetap render container tanpa error.
      setState(() {
        _qrImage = null;
      });
    }
  }

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _takeScreenshot,
        label: Row(children: [
          Icon(
            Icons.download,
            size: 18,
          ),
          SizedBox(width: 5),
          Text("Unduh QRIS"),
        ]),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(50.0),
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
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
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20.0, bottom: 70.0),
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
                  ),
                ),
              ],
            ),
    );
  }
}

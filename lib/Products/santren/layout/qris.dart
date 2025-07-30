import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Ganti import ini ke file asli WaitingKycPage kamu
import 'package:mobile/screen/kyc/waiting.dart';

import 'index.dart';

class MyQrisPage extends StatefulWidget {
  @override
  _MyQrisPageState createState() => _MyQrisPageState();
}

class _MyQrisPageState extends State<MyQrisPage> {
  ScreenshotController _screenshotController = ScreenshotController();
  File? image;

  Future<Map<String, dynamic>> _getQr() async {
    try {
      print('[DEBUG] Requesting QRIS...');
      final token = bloc.token.valueWrapper?.value;
      final url =
          Uri.parse('https://santren-app.findig.id/api/v1/qris/generate');

      final response = await http.post(
        url,
        headers: {
          'Authorization': token ?? '',
        },
      );

      print('[DEBUG] HTTP status: ${response.statusCode}');
      print('[DEBUG] Raw response body: ${response.body}');
      final data = json.decode(response.body);

      print('[DEBUG] API JSON: $data');

      if (data != null && data['status'] == 500) {
        print('[DEBUG] Status 500 terdeteksi dari API JSON');
        return {'status': 500, 'message': data['message'] ?? ''};
      }

      if (data != null &&
          data['image'] != null &&
          data['image'].toString().trim().isNotEmpty) {
        print('[DEBUG] Berhasil dapat image URL: ${data['image']}');
        return {
          'status': 200,
          'image': data['image'],
        };
      } else if (data != null &&
          data['status'] == 200 &&
          (data['image'] == null || data['image'].toString().trim().isEmpty)) {
        // status 200 tapi image kosong
        print('[DEBUG] Status 200 tapi image kosong');
        return {'status': 200, 'image': ''};
      } else {
        print('[DEBUG] Image kosong/tidak ada!');
        return {'status': -2};
      }
    } catch (err) {
      print('[DEBUG] Exception ketika get QR: $err');
      return {'status': -1, 'error': err.toString()};
    }
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

  Widget _waitingBankVerificationPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Checklist hijau
            Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 8),
            // Selamat (bold)
            Text(
              "Selamat",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            // Deskripsi bawah Selamat
            Text(
              "Akun Anda Berhasil Di Verifikasi\nsekarang anda dapat akses lebih di SantrenPay",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Gambar QRIS diperbesar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey, // Ganti warna border sesuai kebutuhan
                    width: 2, // Ketebalan border
                  ),
                  borderRadius:
                      BorderRadius.circular(16), // Jika mau border radius
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      16), // Samakan dengan border di atas
                  child: Image.asset(
                    'assets/img/santren/qrisdummy.png',
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // (Optional) Tambahkan panah jika ada asset-nya
            const SizedBox(height: 8),
            // Teks status QRIS
            Text(
              "Qris Static Anda Sedang Review\nMohon Tunggu Beberapa Hari Kedepan\nCek Secara Berkala",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            // Tombol Back to Home
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => EpulsaHome()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  "Back to Home",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getQrisWidget(Map<String, dynamic> result) {
    print('[DEBUG] Masuk _getQrisWidget dengan result: $result');
    if (result == null) {
      return Center(child: Text('Terjadi kesalahan tak terduga'));
    }
    int status = result['status'];

    if (status == 500) {
      return WaitingKycPage();
    } else if (status == 200 &&
        (result['image'] == null ||
            result['image'].toString().trim().isEmpty)) {
      return _waitingBankVerificationPage();
    } else if (status == 200 &&
        result['image'] != null &&
        result['image'].toString().trim().isNotEmpty) {
      String imageUrl = result['image'];
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                progressIndicatorBuilder: (_, __, ___) => SpinKitFadingCircle(
                  color: Theme.of(context).primaryColor,
                ),
                fit: BoxFit.contain, // Tidak akan terpotong
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ],
      );
    }
    // 4. Error lain
    else if (result.containsKey('error')) {
      return Center(child: Text('Error: ${result['error']}'));
    } else {
      return Center(
        child: Text('QRIS tidak tersedia saat ini.'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getQr(),
      builder: (context, snapshot) {
        bool showFab = false;
        if (snapshot.hasData) {
          var result = snapshot.data!;
          if (result['status'] == 200 &&
              result['image'] != null &&
              result['image'].toString().trim().isNotEmpty) {
            showFab = true;
          }
        }
        return Scaffold(
          floatingActionButton: showFab
              ? FloatingActionButton.extended(
                  onPressed: _takeScreenshot,
                  label: Row(
                    children: [
                      Icon(Icons.download, size: 18),
                      SizedBox(width: 5),
                      Text("Unduh QRIS"),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                )
              : null,
          body: snapshot.connectionState == ConnectionState.waiting
              ? SpinKitFadingCircle(
                  color: Theme.of(context).primaryColor,
                )
              : snapshot.hasError
                  ? Center(child: Text('Error: ${snapshot.error}'))
                  : snapshot.hasData
                      ? _getQrisWidget(snapshot.data!)
                      : Center(child: Text('QRIS tidak tersedia')),
        );
      },
    );
  }
}

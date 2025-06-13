import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/config.dart';
import 'package:mobile/screen/kyc/verification1.dart';

class KycRejectPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: SvgPicture.asset(
                'assets/img/bgver.svg',
                fit: BoxFit.none,
                color: packageName == 'com.lariz.mobile'
                    ? Theme.of(context).secondaryHeaderColor
                    : Theme.of(context).primaryColor,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 100,
                    child: Image.asset(
                        'assets/img/logover.png'), // Ganti dengan path logo Anda
                  ),
                  // SizedBox(height: 0),
                  Text(
                    'REJECTED!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 48),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 4,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/img/reject.png', // Ganti dengan path gambar orang menunggu Anda
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Verifikasi Ditolak',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Silakan periksa kembali informasi yang\nAnda berikan dan coba kirim ulang.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.symmetric(horizontal: 16),
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        SubmitKyc1())); // Mengarahkan ke Verifikasi Lagi.
          },
          child: Text(
            'Verifikasi Ulang',
            style: TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            primary: packageName == 'com.lariz.mobile'
                ? Theme.of(context).secondaryHeaderColor
                : Theme.of(context).primaryColor,
            onPrimary: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}

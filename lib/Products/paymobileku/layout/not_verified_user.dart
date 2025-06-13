import 'package:flutter/material.dart';
import 'package:mobile/screen/kyc/verification1.dart';
import 'package:mobile/screen/profile/kyc/verification.dart';

class NotVerifiedPage extends StatefulWidget {
  @override
  _NotVerifiedPageState createState() => _NotVerifiedPageState();
}

class _NotVerifiedPageState extends State<NotVerifiedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Belum Verifikasi'), centerTitle: true, elevation: 0),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/img/paymobileku/verify.jpg',
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: MaterialButton(
                color: Colors.white,
                textColor: Colors.black,
                child: Text('Verifikasi Sekarang'),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => SubmitKyc1(),
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

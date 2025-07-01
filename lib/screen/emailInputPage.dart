import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/screen/verifyEmailPage.dart';

class EmailInputPage extends StatefulWidget {
  @override
  State<EmailInputPage> createState() => _EmailInputPageState();
}

class _EmailInputPageState extends State<EmailInputPage> {
  final emailCtrl = TextEditingController();
  bool loading = false;

  Future<void> sendVerification() async {
    setState(() => loading = true);
    try {
      // 1. Cek kalau user belum ada, register dulu pakai email & dummy password random
      String email = emailCtrl.text.trim();
      String tempPassword = DateTime.now().millisecondsSinceEpoch.toString();

      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: tempPassword,
        );
      } catch (e) {
        // Jika user sudah ada, lanjut
      }

      // 2. Kirim email verifikasi
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }

      // 3. Redirect ke halaman verifikasi
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => VerifyEmailPage(email: email),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal kirim verifikasi: $e'))
      );
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Masukkan Email")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: loading ? null : sendVerification,
              child: loading ? CircularProgressIndicator() : Text("Kirim Verifikasi"),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'register.dart';

class VerifyEmailPage extends StatefulWidget {
  final String email;

  const VerifyEmailPage({Key? key, required this.email}) : super(key: key);

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Timer? _timer;
  bool _isResending = false;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    // Auto-cek setiap 3 detik
    _timer = Timer.periodic(Duration(seconds: 3), (_) => _checkEmailVerified());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload(); // Update status dari server
    user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      setState(() {
        _isVerified = true;
      });
      _timer?.cancel();
      // Redirect ke halaman daftar (atau halaman utama)
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => RegisterUser()));
    }
  }

  Future<void> _resendEmail() async {
    setState(() => _isResending = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Verification email resent!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to resend email: $e')));
    }
    setState(() => _isResending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isVerified
            ? CircularProgressIndicator() // While redirecting
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mail, size: 72, color: Colors.purple),
                  SizedBox(height: 16),
                  Text(
                    'Verify your email address',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'We have sent a verification link to\n${widget.email}',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Click on the link to complete the verification process.\n'
                    'You might need to check your spam folder.',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isResending ? null : _resendEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[300],
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: Text('Resend email'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Return to Site'),
                        Icon(Icons.arrow_right_alt),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'You can reach us if you have any questions.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
      ),
    );
  }
}

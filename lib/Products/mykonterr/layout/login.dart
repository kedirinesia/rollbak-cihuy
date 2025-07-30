import 'package:flutter/material.dart';
import 'package:mobile/Products/mykonterr/layout/cs.dart';
import 'package:mobile/Products/mykonterr/layout/forgot-password/step_1.dart';
import 'package:mobile/Products/mykonterr/layout/otp.dart';
import 'package:mobile/Products/mykonterr/layout/privacy_policy.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/api.dart';
import 'package:nav/nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _form = GlobalKey();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _hidePassword = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  void _loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phone = prefs.getString('phone') ?? '';
    String pin = prefs.getString('pin') ?? '';
    setState(() {
      _phone.text = phone;
      _password.text = pin;
    });
  }

  @override
  void dispose() {
    _form.currentState?.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;

    try {
      setState(() {
        _loading = true;
      });

      String phoneNumber = _phone.text.trim();
      if (!phoneNumber.startsWith('0')) {
        phoneNumber = '0$phoneNumber';
      }

      Map<String, dynamic> response = await api.post(
        '/user/login',
        auth: false,
        data: {
          'phone': phoneNumber,
          'pin': _password.text.trim(),
        },
      );

      Map<String, dynamic> data = response['data'];

      Nav.pushReplacement(OtpPage(data['phone'], data['validate_id']));
    } catch (e) {
      String msg = (e as Map<String, dynamic>?)?['message'] ?? e.toString();
      showToast(context, msg);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => CS1(),
                      ));
                    },
                    child: Column(
                      children: [
                        Image.network(
                          'https://dokumen.payuni.co.id/logo/mykonter/custom/cs.png',
                          height: 60,
                          width: 60,
                        ),
                        const SizedBox(height: 4),
                        Text('Bantuan',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.04),
              Column(
                children: [
                  Image.network(
                    'https://dokumen.payuni.co.id/logo/mykonter/custom/logo.png',
                    height: 100,
                  ),
                  const SizedBox(height: 16),
                  const Text('Masuk',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Nomer Hanphone',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Nomer Handphone',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('PIN',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _password,
                        keyboardType: TextInputType.number,
                        obscureText: _hidePassword,
                        decoration: InputDecoration(
                          hintText: 'PIN',
                          suffixIcon: IconButton(
                            icon: Icon(_hidePassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _hidePassword = !_hidePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('Lupa PIN?'),
                          TextButton(
                            onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => StepOneForgotPIN())),
                            child: Text('Atur ulang',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor)),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Masuk',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Belum Mempunyai akun?'),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => PrivacyPolicyPage()));
                            },
                            child: Text('Daftrar',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor)),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/api.dart';
import 'package:nav/nav.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mobile/screen/otp.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _form = GlobalKey();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _hidePassword = true;
  bool _loading = false;

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
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).padding.top,
            color: Theme.of(context).primaryColor,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: 35,
              horizontal: 20,
            ),
            color: Theme.of(context).primaryColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Login dengan',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'akun terdaftar.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 50,
                color: Theme.of(context).primaryColor,
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 25),
                  height: 25,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  transform: Matrix4.translationValues(0, 1, 0),
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    Icons.phone_android,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(15),
              children: [
                Form(
                  key: _form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No. Handphone',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        autofocus: true,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12.5,
                            horizontal: 15,
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).primaryColor.withOpacity(.1),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefix: Text('+62 '),
                          suffixIcon: SizedBox(),
                        ),
                        validator: (value) {
                          String str = value ?? '';

                          if (str.length == 0)
                            return 'Nomor handphone harus diisi';
                          if (str.length < 8)
                            return 'Nomor handphone minimal 9 digit';
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _password,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(
                              configAppBloc.pinCount.value),
                        ],
                        obscureText: _hidePassword,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12.5,
                            horizontal: 15,
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).primaryColor.withOpacity(.1),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            color: Colors.grey,
                            icon: Icon(_hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _hidePassword = !_hidePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          String str = value ?? '';
                          int count = configAppBloc.pinCount.value ?? 4;

                          if (str.length == 0) return 'Password harus diisi';
                          if (str.length < count)
                            return 'Password harus $count karakter';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 60),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                children: [
                  TextSpan(text: 'Dengan melanjutkan, kamu telah menyetujui '),
                  TextSpan(
                    text: 'Syarat & Ketentuan',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: ' dan '),
                  TextSpan(
                    text: 'Kebijakan Privasi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                      text:
                          '. Biaya operator standar mungkin berlaku untuk SMS.'),
                ],
              ),
            ),
          ),
          SizedBox(height: 25),
          InkWell(
            onTap: _login,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(.25),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: _loading
                  ? SpinKitThreeBounce(
                      color: Theme.of(context).primaryColor,
                      size: 25,
                    )
                  : Row(
                      children: [
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.transparent,
                          size: 20,
                        ),
                        Spacer(),
                        Text(
                          'Masuk dengan aman',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

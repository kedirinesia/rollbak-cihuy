import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/Products/ayoba/layout/privacy_policy.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/provider/api.dart';
import 'package:mobile/screen/forgot-password/step_1.dart';
import 'package:mobile/Products/ayoba/layout/otp.dart';
import 'package:nav/nav.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _form = GlobalKey();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _hidePassword = true;
  bool _loading = false;
  bool rememberMe = false;

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

      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (rememberMe) {
        await prefs.setString('phone', phoneNumber);
        await prefs.setString('pin', _password.text.trim());
      } else {
        await prefs.remove('phone');
        await prefs.remove('pin');
      }

      Nav.pushReplacement(OtpPage(data['phone'], data['validate_id']));
    } catch (e) {
      String msg = (e as Map<String, dynamic>?)?['message'] ?? e.toString();
      // showToast(context, msg);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops...',
        text: msg,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SizedBox(
          height: height,
          child: Stack(
            children: [
              Container(
                height: height / 2,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(60),
                      bottomLeft: Radius.circular(60),
                    )),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 70,
                        child: CachedNetworkImage(
                            imageUrl:
                                'https://admin.ayoba.co.id/assets/1705387882319-logo-ayoba-putih.png')),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Satu Genggaman untuk Semua Kebutuhan',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Roboto',
                          fontStyle: FontStyle.normal),
                    )
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Form(
                  key: _form,
                  child: SizedBox(
                    height: height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 20),
                          height: height / 1.9,
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Login Account',
                                style: TextStyle(
                                    fontSize: 23, fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 22,
                              ),
                              SizedBox(
                                height: 40,
                                child: TextFormField(
                                  controller: _phone,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                      labelText: 'Nomor Telepon',
                                      labelStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(26),
                                          borderSide: BorderSide(
                                              color: Color(0XFFDADADA))),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(26)),
                                      ),
                                      suffixIcon: Icon(Icons.phone_android)),
                                  validator: (value) {
                                    String str = value ?? '';

                                    if (str.length == 0) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Error'),
                                            content: Text(
                                                'Nomor handphone harus diisi'),
                                            actions: [
                                              TextButton(
                                                child: Text('OK'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      return null;
                                    }
                                    if (str.length < 8) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Error'),
                                            content: Text(
                                                'Nomor handphone minimal 9 digit'),
                                            actions: [
                                              TextButton(
                                                child: Text('OK'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      return null;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 40,
                                child: TextFormField(
                                  controller: _password,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(
                                        configAppBloc
                                            .pinCount.valueWrapper?.value),
                                  ],
                                  obscureText: _hidePassword,
                                  decoration: InputDecoration(
                                      isDense: true,
                                      // filled: true,
                                      labelText: 'PIN',
                                      labelStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(26),
                                          borderSide: BorderSide(
                                              color: Color(0XFFDADADA))),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(26)),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(_hidePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility),
                                        onPressed: () {
                                          setState(() {
                                            _hidePassword = !_hidePassword;
                                          });
                                        },
                                      )),
                                  validator: (value) {
                                    String str = value ?? '';
                                    int count = configAppBloc
                                            .pinCount.valueWrapper?.value ??
                                        4;

                                    if (str.length == 0) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Error'),
                                            content:
                                                Text('PIN tidak boleh kosong.'),
                                            actions: [
                                              TextButton(
                                                child: Text('OK'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      return null;
                                    }
                                    if (str.length < count) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Error'),
                                            content: Text(
                                                'PIN harus $count karakter'),
                                            actions: [
                                              TextButton(
                                                child: Text('OK'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      return null;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SwitchListTile.adaptive(
                                activeColor: Theme.of(context).primaryColor,
                                value: rememberMe,
                                onChanged: ((bool value) async {
                                  // onChanged should be asynchronous
                                  setState(() {
                                    rememberMe = value;
                                  });
                                  if (rememberMe) {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.setString('password',
                                        _password.text); // Save password
                                  } else {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.remove(
                                        'password'); // Remove password if rememberMe is not checked
                                  }
                                }),
                                contentPadding: const EdgeInsets.all(0),
                                title: Text('Remember me',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0XFFDADADA))),
                              ),
                              MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(31)),
                                height: 40,
                                color: Theme.of(context).primaryColor,
                                onPressed: _loading
                                    ? null
                                    : _login, // disable button when loading
                                child: _loading
                                    ? SpinKitThreeBounce(
                                        color: Colors.white,
                                        size: 20.0,
                                      )
                                    : const Text(
                                        'LOG IN',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700),
                                      ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Divider(
                                      thickness: 1,
                                      height: 1,
                                      color: Color(0XFFDADADA),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Text('or',
                                      style: TextStyle(
                                          color: Color(0XFFDADADA),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Expanded(
                                    child: Divider(
                                      thickness: 1,
                                      height: 1,
                                      color: Color(0XFFDADADA),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Container(
                                child: InkWell(
                                  onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) => StepOneForgotPIN())),
                                  child: Text(
                                    'Forget password?',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0XFFDADADA)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Don’t have an account?',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => PrivacyPolicyPage()));
                              },
                              child: Text(
                                'Sign up now',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w700),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 44,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class Input extends StatelessWidget {
  Input({
    Key? key,
    required this.hint,
    required this.icon,
  }) : super(key: key);

  String hint;
  IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
          labelText: hint,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(26),
              borderSide: BorderSide(color: Color(0XFFDADADA))),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
            borderRadius: const BorderRadius.all(Radius.circular(26)),
          ),
          suffixIcon: Icon(icon)),
    );
  }
}

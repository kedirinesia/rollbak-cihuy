// @dart=2.9

import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/component/bezierContainer.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/lokasi.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/Products/santren/layout/agreement/privacy_page.dart';
import 'package:mobile/Products/santren/layout/agreement/service_page.dart';
import 'package:mobile/screen/select_state/kecamatan.dart';
import 'package:mobile/screen/select_state/kota.dart';
import 'package:mobile/screen/select_state/provinsi.dart';
import 'package:mobile/screen/text_kapital.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterUser extends StatefulWidget {
  @override
  _RegisterUserState createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nama = TextEditingController();
  TextEditingController nomorHp = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController pin = TextEditingController();
  TextEditingController alamat = TextEditingController();
  TextEditingController namaToko = TextEditingController();
  TextEditingController alamatToko = TextEditingController();
  TextEditingController provinsiText = TextEditingController();
  TextEditingController kotaText = TextEditingController();
  TextEditingController kecamatanText = TextEditingController();
  TextEditingController referalCode = TextEditingController();
  TextEditingController otpController = TextEditingController();

  bool loading = false;
  bool sendingOtp = false;
  bool verifyingOtp = false;
  bool otpSent = false;
  bool otpVerified = false;
  int countdown = 0;
  Timer timer;

  Lokasi provinsi;
  Lokasi kota;
  Lokasi kecamatan;
  bool isNamaToko = true;
  bool isAlmtToko = true;
  bool isReferalCode = false;
  bool isAgree = false;

  @override
  void initState() {
    super.initState();
    analitycs.pageView('/register/', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Registrasi',
    });
  }

  @override
  void dispose() {
    nama.dispose();
    nomorHp.dispose();
    email.dispose();
    pin.dispose();
    alamat.dispose();
    namaToko.dispose();
    alamatToko.dispose();
    provinsiText.dispose();
    kotaText.dispose();
    kecamatanText.dispose();
    referalCode.dispose();
    otpController.dispose();
    timer?.cancel();
    super.dispose();
  }

  // ================== Fitur OTP ==================

  void startCountdown() {
    setState(() {
      countdown = 60;
    });
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (countdown > 1) {
        setState(() {
          countdown--;
        });
      } else {
        setState(() {
          countdown = 0;
        });
        timer?.cancel();
      }
    });
  }

  Future<void> sendOtpRegister() async {
    final emailText = email.text.trim();
    final memberNameText = nama.text.trim();

    if (emailText.isEmpty || !RegExp(r'\S+@\S+\.\S+').hasMatch(emailText)) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Kesalahan'),
          content: Text('Masukkan alamat email yang valid!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: Text('TUTUP'),
            ),
          ],
        ),
      );
      return;
    }
    if (memberNameText.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Kesalahan'),
          content: Text('Nama wajib diisi!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: Text('TUTUP'),
            ),
          ],
        ),
      );
      return;
    }
    setState(() {
      sendingOtp = true;
    });
    try {
      final res = await http.post(
        Uri.parse('https://fulung.net/api/Auth/send-otp-register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailText,
          'storeName': 'Verifikasi Pendaftaran',
          'memberName': memberNameText,
          'pesan': "Silakan masukkan kode berikut untuk menyelesaikan proses pendaftaran akun Anda."
        }),
      );
      final json = jsonDecode(res.body);
      setState(() {
        otpSent = res.statusCode == 200;
      });
      if (res.statusCode == 200) startCountdown();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(res.statusCode == 200 ? 'Berhasil' : 'Gagal'),
          content: Text(json['message'] ?? 'Gagal mengirim kode OTP.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: Text('TUTUP'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Gagal'),
          content: Text('Gagal mengirim kode OTP.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: Text('TUTUP'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        sendingOtp = false;
      });
    }
  }

  Future<bool> verifyOtpRegister() async {
    final emailText = email.text.trim();
    final otpText = otpController.text.trim();

    if (emailText.isEmpty || otpText.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Gagal'),
          content: Text('Email dan Kode OTP harus diisi!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: Text('TUTUP'),
            ),
          ],
        ),
      );
      return false;
    }
    setState(() {
      verifyingOtp = true;
    });
    try {
      final res = await http.post(
        Uri.parse('https://fulung.net/api/Auth/verify-otp-register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': emailText, 'otp': otpText}),
      );
      final json = jsonDecode(res.body);
      if (res.statusCode == 200) {
        setState(() {
          otpVerified = true;
        });
        return true;
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Gagal'),
            content: Text(json['message'] ?? 'Kode OTP salah!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                child: Text('TUTUP'),
              ),
            ],
          ),
        );
        return false;
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Gagal'),
          content: Text('Kode OTP Salah atau Kadaluarsa.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: Text('TUTUP'),
            ),
          ],
        ),
      );
      return false;
    } finally {
      setState(() {
        verifyingOtp = false;
      });
    }
  }

  // =============== END Fitur OTP ===============

  Future<void> submitRegister() async {
    if (pin.text.startsWith('0')) {
      return showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Gagal'),
          content: const Text('Nomor PIN Tidak Boleh Diawali Dengan Angka 0'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'TUTUP'),
              child: const Text('TUTUP'),
            ),
          ],
        ),
      );
    }

    if (!_formKey.currentState.validate()) return;

    // VERIFIKASI OTP DULU SEBELUM REGISTER
    final otpOk = await verifyOtpRegister();
    if (!otpOk) return;

    setState(() {
      loading = true;
    });

    String kodeUpline = bloc.kodeUpline.valueWrapper?.value;

    Map<String, dynamic> dataToSend = {
      'name': nama.text,
      'phone': nomorHp.text,
      'email': email.text,
      'pin': pin.text,
      'id_propinsi': provinsi.id,
      'id_kabupaten': kota.id,
      'id_kecamatan': kecamatan.id,
      'alamat': alamat.text,
      'nama_toko': namaToko.text,
      'alamat_toko': alamatToko.text.isEmpty ? alamat.text : alamatToko.text,
    };
    if (referalCode.text.isNotEmpty) {
      dataToSend['kode_upline'] = referalCode.text.toUpperCase();
    }
    if (kodeUpline != null) {
      dataToSend['kode_upline'] = kodeUpline;
    } else if (kodeUpline == null && brandId != null) {
      dataToSend['kode_upline'] = brandId;
    }

    try {
      http.Response response = await http.post(
        Uri.parse('$apiUrl/user/register'),
        headers: {
          'content-type': 'application/json',
          'merchantCode': sigVendor
        },
        body: json.encode(dataToSend),
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String message = data['message'];
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text('Registrasi Berhasil'),
                content: Text(message),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'TUTUP',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(_, rootNavigator: true).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      } else {
        String message = json.decode(response.body)['message'];
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text('Registrasi Gagal'),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  child: Text(
                    'TUTUP',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('Registrasi Gagal'),
            content: Text(e?.toString() ?? 'Terjadi kesalahan pada sistem'),
            actions: <Widget>[
              TextButton(
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(),
                child: Text(
                  'TUTUP',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Color(0xFF4CAF50);
    final double borderRadius = 18;
    final double fieldSpacing = 15;

    OutlineInputBorder _normalBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
      borderRadius: BorderRadius.circular(borderRadius),
    );

    InputDecoration _inputDecoration({String hintText, IconData icon}) {
      return InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: primaryGreen, size: 24),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
        border: _normalBorder,
        enabledBorder: _normalBorder,
        focusedBorder: _normalBorder.copyWith(
          borderSide: BorderSide(color: primaryGreen, width: 2),
        ),
      );
    }

    Widget _agreeLabel() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => setState(() => isAgree = !isAgree),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isAgree ? primaryGreen : Colors.white,
                border: Border.all(
                  color: isAgree ? primaryGreen : Colors.grey.shade400,
                  width: 1.3,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: isAgree
                  ? Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "Lihat ",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(
                    text: "Syarat & Ketentuan ",
                    style: TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ServicePolicyPage(),
                        ));
                      },
                  ),
                  TextSpan(
                    text: "dan ",
                    style: TextStyle(color: Colors.black87, fontSize: 12.5),
                  ),
                  TextSpan(
                    text: "Kebijakan Privasi",
                    style: TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PrivacyPolicyPage(),
                        ));
                      },
                  ),
                  TextSpan(
                    text: "!",
                    style: TextStyle(color: Colors.black87, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    List<String> pkgNameRefCode = [
      'mobile.payuni.id',
      'id.funmo.mobile',
      'id.paymobileku.app',
      'popay.id',
      'id.ualreload.mobile',
      'com.funmoid.app',
      'com.popayfdn',
      'com.xenaja.app',
      'com.alpay.mobile',
    ];
    pkgNameRefCode.forEach((element) {
      if (element == packageName) {
        isReferalCode = true;
      }
    });

    List<String> pkgNameToko = [
      'id.paymobileku.app',
    ];
    pkgNameToko.forEach((element) {
      if (element == packageName) {
        isNamaToko = false;
        isAlmtToko = false;
      }
    });

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: loading
          ? Center(
              child: SpinKitThreeBounce(
                color: primaryGreen,
                size: 35,
              ),
            )
          : Stack(
              children: [
                Container(
                  height: 35,
                  width: double.infinity,
                  color: primaryGreen,
                ),
                Center(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 40),
                          Text(
                            "Selamat Datang Di Santren Pay",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 3),
                          Text(
                            "Lengkapi data data dibawah ini",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12.5,
                              color: Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 18),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                            constraints: BoxConstraints(
                              maxWidth: 500,
                              minWidth: 200,
                            ),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(31),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                    offset: Offset(0, 8))
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: nama,
                                    keyboardType: TextInputType.text,
                                    cursorColor: primaryGreen,
                                    decoration: _inputDecoration(
                                      hintText: 'Nama Lengkap',
                                      icon: Icons.person_rounded,
                                    ),
                                    inputFormatters: [
                                      UpperCaseTextFormatter(),
                                    ],
                                    validator: (val) {
                                      if (val == null || val.isEmpty)
                                        return 'Nama tidak boleh kosong';
                                      else
                                        return null;
                                    },
                                  ),
                                  SizedBox(height: fieldSpacing),
                                  TextFormField(
                                    controller: email,
                                    keyboardType: TextInputType.emailAddress,
                                    cursorColor: primaryGreen,
                                    decoration: _inputDecoration(
                                      hintText: 'Email',
                                      icon: Icons.email_rounded,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Email tidak boleh kosong';
                                      else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value))
                                        return 'Masukkan alamat email yang valid';
                                      else
                                        return null;
                                    },
                                  ),
                                  SizedBox(height: fieldSpacing),
                                  // Tambahkan baris OTP di bawah email (atau di posisi mana pun sesuai selera)
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          controller: otpController,
                                          keyboardType: TextInputType.number,
                                          decoration: _inputDecoration(
                                            hintText: 'Kode OTP',
                                            icon: Icons.verified_user_rounded,
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                            LengthLimitingTextInputFormatter(6),
                                          ],
                                          validator: (value) {
                                            if (value == null || value.isEmpty)
                                              return 'Masukkan kode OTP';
                                            return null;
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        flex: 1,
                                        child: ElevatedButton(
                                          onPressed: (sendingOtp || countdown > 0)
                                              ? null
                                              : sendOtpRegister,
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            padding: EdgeInsets.symmetric(vertical: 16),
                                          ),
                                          child: sendingOtp
                                              ? SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child: CircularProgressIndicator(strokeWidth: 2))
                                              : Text(
                                                  countdown > 0
                                                      ? 'Tunggu $countdown dtk'
                                                      : (otpSent ? 'Terkirim' : 'Kirim OTP'),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: fieldSpacing),
                                  TextFormField(
                                    controller: nomorHp,
                                    keyboardType: TextInputType.phone,
                                    cursorColor: primaryGreen,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(13),
                                    ],
                                    decoration: _inputDecoration(
                                      hintText: 'No Hp',
                                      icon: Icons.phone_rounded,
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty)
                                        return 'Nomor HP tidak boleh kosong';
                                      else
                                        return null;
                                    },
                                  ),
                                  SizedBox(height: fieldSpacing),
                                  TextFormField(
                                    controller: pin,
                                    keyboardType: TextInputType.number,
                                    cursorColor: primaryGreen,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(pinCount),
                                    ],
                                    obscureText: true,
                                    decoration: _inputDecoration(
                                      hintText: 'Pin Anda',
                                      icon: Icons.lock_rounded,
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty)
                                        return 'PIN tidak boleh kosong';
                                      else
                                        return null;
                                    },
                                  ),
                                  SizedBox(height: fieldSpacing),
                                  TextFormField(
                                    controller: provinsiText,
                                    readOnly: true,
                                    decoration: _inputDecoration(
                                      hintText: 'Provinsi',
                                      icon: Icons.place_rounded,
                                    ),
                                    onTap: () async {
                                      Lokasi lokasi = await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => SelectProvinsiPage(),
                                        ),
                                      );
                                      if (lokasi == null) return;
                                      setState(() {
                                        provinsi = lokasi;
                                        kota = null;
                                        kecamatan = null;
                                        provinsiText.text = lokasi.nama;
                                        kotaText.clear();
                                        kecamatanText.clear();
                                      });
                                    },
                                    validator: (val) {
                                      if (val == null || val.isEmpty)
                                        return 'Provinsi tidak boleh kosong';
                                      else
                                        return null;
                                    },
                                  ),
                                  SizedBox(height: fieldSpacing),
                                  TextFormField(
                                    controller: kotaText,
                                    readOnly: true,
                                    decoration: _inputDecoration(
                                      hintText: 'Kota atau Kabupaten',
                                      icon: Icons.place_rounded,
                                    ),
                                    onTap: () async {
                                      if (provinsi == null) return;
                                      Lokasi lokasi = await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => SelectKotaPage(provinsi),
                                        ),
                                      );
                                      if (lokasi == null) return;
                                      setState(() {
                                        kota = lokasi;
                                        kecamatan = null;
                                        kotaText.text = lokasi.nama;
                                        kecamatanText.clear();
                                      });
                                    },
                                    validator: (val) {
                                      if (val == null || val.isEmpty)
                                        return 'Kota tidak boleh kosong';
                                      else
                                        return null;
                                    },
                                  ),
                                  SizedBox(height: fieldSpacing),
                                  TextFormField(
                                    controller: kecamatanText,
                                    readOnly: true,
                                    decoration: _inputDecoration(
                                      hintText: 'Kecamatan',
                                      icon: Icons.place_rounded,
                                    ),
                                    onTap: () async {
                                      if (kota == null) return;
                                      Lokasi lokasi = await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => SelectKecamatanPage(kota),
                                        ),
                                      );
                                      if (lokasi == null) return;
                                      setState(() {
                                        kecamatan = lokasi;
                                        kecamatanText.text = lokasi.nama;
                                      });
                                    },
                                    validator: (val) {
                                      if (val == null || val.isEmpty)
                                        return 'Kecamatan tidak boleh kosong';
                                      else
                                        return null;
                                    },
                                  ),
                                  SizedBox(height: fieldSpacing),
                                  TextFormField(
                                    controller: alamat,
                                    cursorColor: primaryGreen,
                                    keyboardType: TextInputType.text,
                                    decoration: _inputDecoration(
                                      hintText: 'Alamat Rumah',
                                      icon: Icons.home_rounded,
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty)
                                        return 'Alamat Rumah tidak boleh kosong';
                                      else
                                        return null;
                                    },
                                  ),
                                  if (isNamaToko) ...[
                                    SizedBox(height: fieldSpacing),
                                    TextFormField(
                                      controller: namaToko,
                                      cursorColor: primaryGreen,
                                      keyboardType: TextInputType.text,
                                      decoration: _inputDecoration(
                                        hintText: 'Nama Toko',
                                        icon: Icons.storefront_rounded,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty)
                                          return 'Nama Toko tidak boleh kosong';
                                        else
                                          return null;
                                      },
                                    ),
                                  ],
                                  if (isAlmtToko) ...[
                                    SizedBox(height: fieldSpacing),
                                    TextFormField(
                                      controller: alamatToko,
                                      cursorColor: primaryGreen,
                                      keyboardType: TextInputType.text,
                                      decoration: _inputDecoration(
                                        hintText: 'Alamat Toko',
                                        icon: Icons.place_rounded,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty)
                                          return 'Alamat Toko tidak boleh kosong';
                                        else
                                          return null;
                                      },
                                    ),
                                  ],
                                  if (isReferalCode) ...[
                                    SizedBox(height: fieldSpacing),
                                    TextFormField(
                                      controller: referalCode,
                                      cursorColor: primaryGreen,
                                      keyboardType: TextInputType.text,
                                      decoration: _inputDecoration(
                                        hintText: 'Kode Referal',
                                        icon: Icons.groups_sharp,
                                      ),
                                      inputFormatters: [
                                        UpperCaseTextFormatter(),
                                      ],
                                      validator: (value) {
                                        if (packageName == 'id.paymobileku.app' &&
                                            (value == null || value.isEmpty)) {
                                          return 'Kode Referal tidak boleh kosong';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                  SizedBox(height: 18),
                                  _agreeLabel(),
                                  SizedBox(height: 18),
                                  Container(
                                    width: double.infinity,
                                    height: 46,
                                    margin: EdgeInsets.only(top: 0),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor: isAgree
                                            ? primaryGreen
                                            : primaryGreen.withOpacity(.5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(36),
                                        ),
                                        padding:
                                            EdgeInsets.symmetric(vertical: 13),
                                      ),
                                      onPressed: isAgree ? submitRegister : null,
                                      child: Text(
                                        "Daftar Sekarang",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sudah punya akun? ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[800],
                                ),
                              ),
                              InkWell(
                                onTap: Navigator.of(context).pop,
                                child: Text(
                                  'Masuk',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: primaryGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

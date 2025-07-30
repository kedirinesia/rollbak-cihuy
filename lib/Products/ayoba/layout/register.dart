// @dart=2.9

import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/Products/ayoba/layout/agreement/privacy_page.dart';
import 'package:mobile/Products/ayoba/layout/agreement/service_page.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/models/lokasi.dart';
import 'package:mobile/screen/select_state/kecamatan.dart';
import 'package:mobile/screen/select_state/kota.dart';
import 'package:mobile/screen/select_state/provinsi.dart';
import 'package:quickalert/quickalert.dart';

class RegisterUser extends StatefulWidget {
  @override
  _RegisterUserState createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  TextEditingController nama = TextEditingController();
  TextEditingController nomorHp = TextEditingController();
  TextEditingController pin = TextEditingController();
  TextEditingController alamat = TextEditingController();
  TextEditingController namaToko = TextEditingController();
  TextEditingController alamatToko = TextEditingController();
  TextEditingController provinsiText = TextEditingController();
  TextEditingController kotaText = TextEditingController();
  TextEditingController kecamatanText = TextEditingController();
  TextEditingController referalCode = TextEditingController();
  bool loading = false;
  Lokasi provinsi;
  Lokasi kota;
  Lokasi kecamatan;
  bool isReferalCode = false;
  bool isAgree = false;
  int currentStep = 0;
  String fieldNama;
  String fieldNomorHp;
  String fieldPin;
  String fieldAlamat;
  String fieldProvinsi;
  String fieldKota;
  String fieldKecamatan;

  List<GlobalKey<FormState>> _formKey = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  @override
  void dispose() {
    nama.dispose();
    nomorHp.dispose();
    pin.dispose();
    alamat.dispose();
    namaToko.dispose();
    alamatToko.dispose();
    provinsiText.dispose();
    kotaText.dispose();
    kecamatanText.dispose();
    referalCode.dispose();
    super.dispose();
  }

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

    String kodeUpline = bloc.kodeUpline.valueWrapper?.value;

    Map<String, dynamic> dataToSend = {
      'name': nama.text,
      'phone': nomorHp.text,
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
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Registrasi Berhasil',
          text: message,
          onConfirmBtnTap: () {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context).pop();
          },
        );
      } else {
        String message = json.decode(response.body)['message'];
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Registrasi Gagal',
          text: message,
        );
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Registrasi Gagal',
        text: e.toString(),
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registrasi"),
        centerTitle: true,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
            colorScheme:
                ColorScheme.light(primary: Theme.of(context).primaryColor)),
        child: Stepper(
          type: StepperType.horizontal,
          steps: getSteps(),
          currentStep: currentStep,
          onStepContinue: () {
            setState(() {
              fieldNama = nama.text;
              fieldNomorHp = nomorHp.text;
              fieldPin = pin.text;
              fieldProvinsi = provinsiText.text;
              fieldKota = kotaText.text;
              fieldKecamatan = kecamatanText.text;
              fieldAlamat = alamat.text;
            });
            setState(() {
              if (!_formKey[currentStep].currentState.validate()) return;
              setState(() {
                loading = true;
              });

              final isLastStep = currentStep == getSteps().length - 1;

              if (isLastStep) {
                print("Suskes");
              } else {
                setState(() => currentStep += 1);
              }
            });
          },
          // onStepTapped: (step) => setState(() => currentStep = step),
          onStepCancel:
              currentStep == 0 ? null : () => setState(() => currentStep -= 1),
          controlsBuilder:
              (BuildContext context, ControlsDetails controlsDetails) {
            final isLastStep = currentStep == getSteps().length - 1;
            return Container(
              margin: EdgeInsets.only(top: 50),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      child: Text(isLastStep ? 'Register' : 'Lanjut'),
                      onPressed: isLastStep && !isAgree
                          ? null
                          : () {
                              if (isLastStep) {
                                submitRegister();
                              } else {
                                controlsDetails.onStepContinue();
                              }
                            },
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (currentStep != 0)
                    Expanded(
                      child: ElevatedButton(
                        child: Text('Kembali'),
                        onPressed: controlsDetails.onStepCancel,
                      ),
                    )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _agreeLabel(bool checklist) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isAgree
            ? GestureDetector(
                onTap: () => setState(() => isAgree = false),
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          border: Border.all(width: 1.0, color: Colors.grey)),
                      child: Icon(Icons.check_circle,
                          size: 23, color: Theme.of(context).primaryColor)),
                ),
              )
            : GestureDetector(
                onTap: () => setState(() => isAgree = true),
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          border: Border.all(
                              width: 1.0, color: Colors.grey.shade400)),
                      child: Icon(Icons.check_circle,
                          size: 23, color: Colors.grey[300])),
                ),
              ),
        SizedBox(width: 5),
        RichText(
          text: TextSpan(
            text: "Saya mengerti dan menyetujui\n",
            style: TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500),
            children: [
              TextSpan(
                text: "Syarat & Ketentuan ",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return ServicePolicyPage();
                    }));
                  },
              ),
              TextSpan(text: "dan "),
              TextSpan(
                text: "Kebijakan Privasi! ",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return PrivacyPolicyPage();
                      },
                    ));
                  },
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildInfoText(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
            ),
          ),
        ],
      ),
    );
  }

  List<Step> getSteps() => [
        Step(
          state: currentStep > 0 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 0,
          title: Text("Step 1"),
          content: Form(
            key: _formKey[0],
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: nama,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ).copyWith(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                  ).copyWith(
                    prefixIcon: Icon(
                      Icons.person_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                    hintText: 'Nama',
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty)
                      return 'Nama tidak boleh kosong';
                    else
                      return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: nomorHp,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(13),
                  ],
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ).copyWith(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                  ).copyWith(
                    prefixIcon: Icon(
                      Icons.person_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                    hintText: 'Nomor HP',
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty)
                      return 'Nomor HP tidak boleh kosong';
                    else
                      return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: pin,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(pinCount),
                  ],
                  obscureText: true,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ).copyWith(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                  ).copyWith(
                    prefixIcon: Icon(
                      Icons.person_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                    hintText: 'PIN',
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'PIN tidak boleh kosong';
                    } else if (val.length != pinCount) {
                      return 'PIN harus berjumlah $pinCount karakter';
                    } else if (pin.text.startsWith('0')) {
                      return 'Nomor PIN Tidak Boleh Diawali Dengan Angka 0';
                    } else {
                      return null;
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        Step(
          state: currentStep > 1 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 1,
          title: Text("Step 2"),
          content: Form(
            key: _formKey[1],
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: provinsiText,
                  readOnly: true,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ).copyWith(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                  ).copyWith(
                    prefixIcon: Icon(
                      Icons.place_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                    hintText: 'Provinsi',
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
                SizedBox(height: 15),
                TextFormField(
                  controller: kotaText,
                  readOnly: true,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ).copyWith(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                  ).copyWith(
                    prefixIcon: Icon(
                      Icons.place_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                    hintText: 'Kota atau Kabupaten',
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
                SizedBox(height: 15),
                TextFormField(
                  controller: kecamatanText,
                  readOnly: true,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ).copyWith(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                  ).copyWith(
                    prefixIcon: Icon(
                      Icons.place_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                    hintText: 'Kecamatan',
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
                SizedBox(height: 15),
                TextFormField(
                  controller: alamat,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ).copyWith(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                  ).copyWith(
                    prefixIcon: Icon(
                      Icons.home_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                    hintText: 'Alamat Rumah',
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty)
                      return 'Alamat rumah tidak boleh kosong';
                    else
                      return null;
                  },
                ),
              ],
            ),
          ),
        ),
        Step(
          isActive: currentStep >= 2,
          title: Text("Step 3"),
          content: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInfoText("Nama:", fieldNama, Icons.person),
                _buildInfoText("Nomor HP:", fieldNomorHp, Icons.phone),
                _buildInfoText("PIN:", fieldPin, Icons.lock),
                _buildInfoText("Provinsi:", fieldProvinsi, Icons.place),
                _buildInfoText("Kota:", fieldKota, Icons.location_city),
                _buildInfoText("Kecamatan:", fieldKecamatan, Icons.map),
                _buildInfoText("Alamat:", fieldAlamat, Icons.home),
                SizedBox(height: 20),
                _agreeLabel(isAgree),
              ],
            ),
          ),
        )
      ];
}

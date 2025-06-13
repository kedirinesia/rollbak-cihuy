// @dart=2.9

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/config.dart';
import 'package:mobile/modules.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/kyc/custom_camera.dart';
import 'package:mobile/screen/kyc/custom_selfie.dart';
import 'package:mobile/screen/kyc/waiting.dart';

class SubmitKyc2 extends StatefulWidget {
  final String userName;
  final String storeName;
  final String province;
  final String district;
  final String subDistrict;
  final String address;
  final String mccCode;
  final String postalCode;

  SubmitKyc2({
    Key key,
    this.userName,
    this.storeName,
    this.province,
    this.district,
    this.subDistrict,
    this.address,
    this.mccCode,
    this.postalCode,
  }) : super(key: key);
  @override
  _SubmitKyc2State createState() => _SubmitKyc2State();
}

class _SubmitKyc2State extends State<SubmitKyc2> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  TextEditingController nik = TextEditingController();
  File ktp;
  File selfie;

  @override
  void initState() {
    super.initState();
    analitycs.pageView('/verification', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Verifikasi Identitas',
    });
    print(bloc.user.valueWrapper?.value.kyc);
  }

  List<String> packageList = [
    'id.payku.app',
    'mobile.payuni.id',
    'com.xenaja.app',
    'id.paymobileku.app'
  ];

  void getKtp() async {
    File image = await getPhoto();
    if (image != null) {
      setState(() {
        ktp = image;
      });
    }
  }

  void getKtp1() async {
    final image = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CustomCameraScreen()),
    );

    if (image != null) {
      setState(() {
        ktp = image;
      });
    }
  }

  void getSelfie() async {
    File image = await getPhoto();
    if (image != null) {
      setState(() {
        selfie = image;
      });
    }
  }

  void getSelfie1() async {
    final image = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CustomSelfieScreen()),
    );

    if (image != null) {
      setState(() {
        selfie = image;
      });
    }
  }

  void verify() async {
    if (nik.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nomor Induk Kependudukan harus diisi')));
      return;
    } else if (nik.text.length != 16) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nomor Induk Kependudukan belum lengkap')));
      return;
    } else if (ktp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Anda belum mengambil foto KTP')));
      return;
    } else if (selfie == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Anda belum mengambil foto selfie dengan KTP')));
      return;
    }

    setState(() {
      loading = true;
    });

    http.MultipartRequest request =
        http.MultipartRequest('POST', Uri.parse('$apiUrl/kyc/upload'));
    request.headers['Authorization'] = bloc.token.valueWrapper?.value;
    request.fields['nik'] = nik.text;
    request.fields['nama_lengkap'] = widget.userName;
    request.fields['nama_usaha'] = widget.storeName;
    request.fields['alamat_usaha'] = widget.address;
    request.fields['id_propinsi'] = widget.province;
    request.fields['id_kabupaten'] = widget.district;
    request.fields['id_kecamatan'] = widget.subDistrict;
    request.fields['mcc_id'] = widget.mccCode;
    request.fields['kode_pos'] = widget.postalCode;
    request.files.add(await http.MultipartFile.fromPath('ktp', ktp.path));
    request.files
        .add(await http.MultipartFile.fromPath('selfi_ktp', selfie.path));
    print(request.fields);
    http.StreamedResponse response = await request.send();
    Map<String, dynamic> responseData =
        json.decode(await response.stream.bytesToString());

    if (response.statusCode == 200) {
      updateUserInfo();
      nik.text = "";
      ktp = null;
      selfie = null;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => WaitingKycPage()));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(responseData['message'])));
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder _normalBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.shade300,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(27),
    );

    InputDecoration _inputDecoration = InputDecoration(
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      border: _normalBorder,
      enabledBorder: _normalBorder,
      focusedBorder: _normalBorder.copyWith(
        borderSide: BorderSide(
          color: packageName == 'com.lariz.mobile'
              ? Theme.of(context).secondaryHeaderColor
              : Theme.of(context).primaryColor,
          width: 2,
        ),
      ),
      hintStyle: TextStyle(
        color: Colors.grey,
      ),
    );

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
          (bloc.user.valueWrapper?.value.kyc != '' &&
                  bloc.user.valueWrapper?.value.kyc['status'] != 2 &&
                  bloc.user.valueWrapper?.value.kyc_verification == false)
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: EdgeInsets.all(20),
                  child: Center(
                      child: Text(
                          'Bukti identitas diri telah dikirim, menunggu persetujuan dari pihak kami. Mohon tunggu beberapa hari ke depan.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12))),
                )
              : loading
                  ? Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Center(
                          child: SpinKitThreeBounce(
                              color: packageName == 'com.lariz.mobile'
                                  ? Theme.of(context).secondaryHeaderColor
                                  : Theme.of(context).primaryColor,
                              size: 35)))
                  : SafeArea(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
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
                                'SUBMIT KYC',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 30),

                              TextFormField(
                                  controller: nik,
                                  keyboardType: TextInputType.number,
                                  cursorColor: Theme.of(context).primaryColor,
                                  maxLength: 16,
                                  decoration: _inputDecoration.copyWith(
                                    hintText: 'NIK',
                                  )),
                              SizedBox(height: 10),
                              InkWell(
                                onTap: () {
                                  if (packageList.contains(packageName)) {
                                    getKtp1();
                                  } else {
                                    getKtp();
                                  }
                                },
                                child: AspectRatio(
                                    aspectRatio: 4 / 3,
                                    child: Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(27)),
                                      child: ktp == null
                                          ? Center(
                                              child: Text('FOTO KTP',
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold)))
                                          : Image.file(ktp,
                                              fit: BoxFit.contain),
                                    )),
                              ),
                              SizedBox(height: 10),
                              InkWell(
                                onTap: () {
                                  if (packageList.contains(packageName)) {
                                    getSelfie1();
                                  } else {
                                    getSelfie();
                                  }
                                },
                                child: AspectRatio(
                                    aspectRatio: 4 / 3,
                                    child: Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(27)),
                                      child: selfie == null
                                          ? Center(
                                              child: Text('SELFIE DENGAN KTP',
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold)))
                                          : Image.file(selfie,
                                              fit: BoxFit.contain),
                                    )),
                              ),
                              SizedBox(height: 10),
                              ButtonTheme(
                                  height: 40.0,
                                  minWidth: double.infinity,
                                  child: MaterialButton(
                                      color: packageName == 'com.lariz.mobile'
                                          ? Theme.of(context)
                                              .secondaryHeaderColor
                                          : Theme.of(context).primaryColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Text(
                                        'Kirim Berkas'.toUpperCase(),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () => verify()))
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

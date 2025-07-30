// @dart=2.9

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/modules.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/provider/analitycs.dart';

class KycVerification extends StatefulWidget {
  @override
  _KycVerificationState createState() => _KycVerificationState();
}

class _KycVerificationState extends State<KycVerification> {
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

  void getKtp() async {
    File image = await getPhoto();
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
    request.files.add(await http.MultipartFile.fromPath('ktp', ktp.path));
    request.files
        .add(await http.MultipartFile.fromPath('selfi_ktp', selfie.path));

    http.StreamedResponse response = await request.send();
    Map<String, dynamic> responseData =
        json.decode(await response.stream.bytesToString());

    if (response.statusCode == 200) {
      updateUserInfo();
      nik.text = "";
      ktp = null;
      selfie = null;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Berkas berhasil dikirim, kami akan segera memproses data anda')));
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
    return Scaffold(
      appBar: AppBar(
          title: Text('Verifikasi Identitas'), centerTitle: true, elevation: 0),
      body: (bloc.user.valueWrapper?.value.kyc != '' &&
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
                          color: Theme.of(context).primaryColor, size: 35)))
              : Container(
                  width: double.infinity,
                  height: double.infinity,
                  child:
                      ListView(padding: EdgeInsets.all(20), children: <Widget>[
                    TextFormField(
                        controller: nik,
                        keyboardType: TextInputType.number,
                        maxLength: 16,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'NIK',
                            isDense: true)),
                    SizedBox(height: 10),
                    InkWell(
                      onTap: () => getKtp(),
                      child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 2),
                                borderRadius: BorderRadius.circular(8)),
                            child: ktp == null
                                ? Center(
                                    child: Text('FOTO KTP',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold)))
                                : Image.file(ktp, fit: BoxFit.contain),
                          )),
                    ),
                    SizedBox(height: 10),
                    InkWell(
                      onTap: () => getSelfie(),
                      child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 2),
                                borderRadius: BorderRadius.circular(8)),
                            child: selfie == null
                                ? Center(
                                    child: Text('SELFIE DENGAN KTP',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold)))
                                : Image.file(selfie, fit: BoxFit.contain),
                          )),
                    ),
                    SizedBox(height: 10),
                    ButtonTheme(
                        buttonColor: Theme.of(context).primaryColor,
                        textTheme: ButtonTextTheme.primary,
                        minWidth: double.infinity,
                        child: MaterialButton(
                            child: Text('Kirim Berkas'.toUpperCase()),
                            onPressed: () => verify()))
                  ])),
    );
  }
}

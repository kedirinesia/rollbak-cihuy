// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/lokasi.dart';
import 'package:mobile/models/mcc_code.dart';
import 'package:mobile/screen/select_state/kecamatan.dart';
import 'package:mobile/screen/select_state/kota.dart';
import 'package:mobile/screen/select_state/mccid.dart';
import 'package:mobile/screen/select_state/provinsi.dart';
import 'package:mobile/screen/text_kapital.dart';
import 'verification2.dart';

class SubmitKyc1 extends StatefulWidget {
  @override
  _SubmitKyc1State createState() => _SubmitKyc1State();
}

class _SubmitKyc1State extends State<SubmitKyc1> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController provinsiText = TextEditingController();
  TextEditingController kotaText = TextEditingController();
  TextEditingController kecamatanText = TextEditingController();
  TextEditingController mccText = TextEditingController();
  Lokasi provinsi;
  Lokasi kota;
  Lokasi kecamatan;
  String userName = '';
  String storeName = '';
  // String province = '';
  // String district = '';
  // String subDistrict = '';
  String address = '';
  MccCode jenisUsaha;
  String postalCode = '';

  @override
  Widget build(BuildContext context) {
    Color primaryColor = packageName == 'com.lariz.mobile'
        ? Theme.of(context).secondaryHeaderColor
        : Theme.of(context).primaryColor;

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
          SafeArea(
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
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      onChanged: (value) => userName = value,
                      keyboardType: TextInputType.text,
                      cursorColor: Theme.of(context).primaryColor,
                      decoration: _inputDecoration.copyWith(
                        prefixIcon: Icon(
                          Icons.person_rounded,
                          color: packageName == 'com.lariz.mobile'
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).primaryColor,
                        ),
                        hintText: 'Nama',
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
                    SizedBox(height: 15),
                    TextFormField(
                      onChanged: (value) => storeName = value,
                      keyboardType: TextInputType.text,
                      cursorColor: Theme.of(context).primaryColor,
                      decoration: _inputDecoration.copyWith(
                        prefixIcon: Icon(
                          Icons.storefront_rounded,
                          color: packageName == 'com.lariz.mobile'
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).primaryColor,
                        ),
                        hintText: 'Nama Toko',
                      ),
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                      ],
                      validator: (val) {
                        if (val == null || val.isEmpty)
                          return 'Nama toko tidak boleh kosong';
                        else
                          return null;
                      },
                    ),
                    // Anda dapat menggantikan InkWell dengan widget yang Anda inginkan
                    // untuk menavigasi ke halaman seleksi provinsi, kabupaten, dan kecamatan.
                    SizedBox(height: 15),
                    // InkWell(
                    //   onTap: () async {
                    //     // Navigasikan ke halaman seleksi provinsi
                    //     Lokasi lokasi = await Navigator.of(context).push(
                    //       MaterialPageRoute(
                    //         builder: (_) => SelectProvinsiPage(),
                    //       ),
                    //     );

                    //     if (lokasi == null) return;
                    //     // Setelah memilih provinsi, update variabel 'province' di sini
                    //     setState(() {
                    //       provinsi = lokasi;
                    //       kota = null;
                    //       kecamatan = null;

                    //       provinsiText.text = lokasi.nama;
                    //       kotaText.clear();
                    //       kecamatanText.clear();
                    //     });
                    //   },
                    //   child: TextFormField(
                    //     controller: provinsiText,
                    //     readOnly: true,
                    //     decoration: _inputDecoration.copyWith(
                    //       prefixIcon: Icon(
                    //         Icons.place_rounded,
                    //         color: Theme.of(context).primaryColor,
                    //       ),
                    //       hintText: 'Provinsi',
                    //     ),
                    //     validator: (val) {
                    //       if (val == null || val.isEmpty)
                    //         return 'Provinsi tidak boleh kosong';
                    //       else
                    //         return null;
                    //     },
                    //   ),
                    // ),
                    TextFormField(
                      controller: provinsiText,
                      readOnly: true,
                      decoration: _inputDecoration.copyWith(
                        prefixIcon: Icon(
                          Icons.place_rounded,
                          color: packageName == 'com.lariz.mobile'
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).primaryColor,
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
                    // InkWell(
                    //   onTap: () async {
                    //     if (provinsi == null) return;

                    //       Lokasi lokasi = await Navigator.of(context).push(
                    //         MaterialPageRoute(
                    //           builder: (_) => SelectKotaPage(provinsi),
                    //         ),
                    //       );

                    //     if (lokasi == null) return;

                    //       setState(() {
                    //         kota = lokasi;
                    //         kecamatan = null;

                    //         kotaText.text = lokasi.nama;
                    //         kecamatanText.clear();
                    //       });
                    //     },
                    //   child: TextFormField(
                    //     controller: kotaText,
                    //     readOnly: true,
                    //     decoration: _inputDecoration.copyWith(
                    //       prefixIcon: Icon(
                    //         Icons.place_rounded,
                    //         color: Theme.of(context).primaryColor,
                    //       ),
                    //       hintText: 'Kota atau Kabupaten'
                    //     ),
                    //     validator: (val) {
                    //       if (val == null || val.isEmpty)
                    //         return 'Kota atau Kabupaten tidak boleh kosong';
                    //       else
                    //         return null;
                    //     },
                    //   ),
                    // ),
                    TextFormField(
                      controller: kotaText,
                      readOnly: true,
                      decoration: _inputDecoration.copyWith(
                        prefixIcon: Icon(
                          Icons.place_rounded,
                          color: packageName == 'com.lariz.mobile'
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).primaryColor,
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
                    // InkWell(
                    //   onTap: () async {
                    //     // Navigasikan ke halaman seleksi kecamatan
                    //     if (kota == null) return;

                    //       Lokasi lokasi = await Navigator.of(context).push(
                    //         MaterialPageRoute(
                    //           builder: (_) => SelectKecamatanPage(kota),
                    //         ),
                    //       );

                    //       if (lokasi == null) return;

                    //       setState(() {
                    //         kecamatan = lokasi;
                    //         kecamatanText.text = lokasi.nama;
                    //       });
                    //     },
                    //   child: TextFormField(
                    //     controller: kecamatanText,
                    //     readOnly: true,
                    //     decoration: _inputDecoration.copyWith(
                    //       prefixIcon: Icon(
                    //         Icons.place_rounded,
                    //         color: Theme.of(context).primaryColor,
                    //       ),
                    //       hintText: 'Kecamatan',
                    //     ),
                    //     validator: (val) {
                    //       if (val == null || val.isEmpty)
                    //         return 'Kecamatan tidak boleh kosong';
                    //       else
                    //         return null;
                    //     },
                    //   ),
                    // ),
                    TextFormField(
                      controller: kecamatanText,
                      readOnly: true,
                      decoration: _inputDecoration.copyWith(
                        prefixIcon: Icon(
                          Icons.place_rounded,
                          color: packageName == 'com.lariz.mobile'
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).primaryColor,
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
                      onChanged: (value) => address = value,
                      keyboardType: TextInputType.text,
                      cursorColor: Theme.of(context).primaryColor,
                      // maxLines: 5,
                      decoration: _inputDecoration.copyWith(
                        prefixIcon: Icon(
                          Icons.home_rounded,
                          color: packageName == 'com.lariz.mobile'
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).primaryColor,
                        ),
                        hintText: 'Alamat',
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty)
                          return 'Alamat tidak boleh kosong';
                        else
                          return null;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: mccText,
                      readOnly: true,
                      decoration: _inputDecoration.copyWith(
                        prefixIcon: Icon(
                          Icons.store_rounded,
                          color: packageName == 'com.lariz.mobile'
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).primaryColor,
                        ),
                        hintText: 'Jenis Usaha',
                      ),
                      onTap: () async {
                        MccCode mcc = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SelectMccCodePage(),
                          ),
                        );

                        if (mcc == null) return;

                        setState(() {
                          jenisUsaha = mcc;

                          mccText.text = mcc.nama;
                        });
                      },
                      validator: (val) {
                        if (val == null || val.isEmpty)
                          return 'Jenis Usaha tidak boleh kosong';
                        else
                          return null;
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      onChanged: (value) => postalCode = value,
                      keyboardType: TextInputType.number,
                      cursorColor: Theme.of(context).primaryColor,
                      decoration: _inputDecoration.copyWith(
                        prefixIcon: Icon(
                          Icons.chair_alt_rounded,
                          color: packageName == 'com.lariz.mobile'
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).primaryColor,
                        ),
                        hintText: 'Kode Pos',
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty)
                          return 'Kode Pos tidak boleh kosong';
                        else
                          return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SubmitKyc2(
                                  userName: userName,
                                  storeName: storeName,
                                  province: provinsi?.id,
                                  district: kota?.id,
                                  subDistrict: kecamatan?.id,
                                  address: address,
                                  mccCode: jenisUsaha?.id,
                                  postalCode: postalCode,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Harap mengisi semua field yang diperlukan.')),
                            );
                          }
                        },
                        child: Text(
                          'Lanjut',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: packageName == 'com.lariz.mobile'
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).primaryColor,
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
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

// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/lokasi.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/select_state/kecamatan.dart';
import 'package:mobile/screen/select_state/kota.dart';
import 'package:mobile/screen/select_state/provinsi.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _loading = false;
  bool _hidePin = true;
  TextEditingController _name = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _pin = TextEditingController();
  TextEditingController _state = TextEditingController();
  TextEditingController _city = TextEditingController();
  TextEditingController _district = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _storeName = TextEditingController();
  TextEditingController _storeAddress = TextEditingController();
  Lokasi selectedState;
  Lokasi selectedCity;
  Lokasi selectedDistrict;

  final InputBorder border = UnderlineInputBorder(
    borderSide: BorderSide(
      color: Colors.white,
      width: 1,
    ),
  );
  final TextStyle textStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );
  final TextStyle hintStyle = TextStyle(
    color: Colors.white.withOpacity(.5),
  );

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _pin.dispose();
    _state.dispose();
    _city.dispose();
    _district.dispose();
    _address.dispose();
    _storeName.dispose();
    _storeAddress.dispose();
    super.dispose();
  }

  Widget prefixIcon(IconData icon) {
    return Icon(
      icon,
      color: Colors.white.withOpacity(.5),
    );
  }

  Future<void> getState() async {
    Lokasi lokasi = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SelectProvinsiPage(),
      ),
    );

    if (lokasi == null) return;

    selectedState = lokasi;
    selectedCity = null;
    selectedDistrict = null;
    _state.text = lokasi.nama;
    _city.clear();
    _district.clear();

    setState(() {});
  }

  Future<void> getCity() async {
    Lokasi lokasi = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SelectKotaPage(selectedState),
      ),
    );

    if (lokasi == null) return;

    selectedCity = lokasi;
    selectedDistrict = null;
    _city.text = lokasi.nama;
    _district.clear();

    setState(() {});
  }

  Future<void> getDistrict() async {
    Lokasi lokasi = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SelectKecamatanPage(selectedCity),
      ),
    );

    if (lokasi == null) return;

    selectedDistrict = lokasi;
    _district.text = lokasi.nama;

    setState(() {});
  }

  Future<void> register() async {
    if (_loading) return;
    if (_name.text.isEmpty ||
        _phone.text.isEmpty ||
        _pin.text.isEmpty ||
        _state.text.isEmpty ||
        _city.text.isEmpty ||
        _district.text.isEmpty ||
        _address.text.isEmpty ||
        _storeName.text.isEmpty ||
        _storeAddress.text.isEmpty) {
      showToast(context, 'Ada field yang masih kosong');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
    });

    Map<String, dynamic> dataToSend = {
      'name': _name.text.trim(),
      'phone': _phone.text.trim(),
      'pin': _pin.text.trim(),
      'id_propinsi': selectedState.id,
      'id_kabupaten': selectedCity.id,
      'id_kecamatan': selectedDistrict.id,
      'alamat': _address.text.trim(),
      'nama_toko': _storeName.text.trim(),
      'alamat_toko': _storeAddress.text.trim(),
    };

    if (bloc.kodeUpline.valueWrapper?.value != null) {
      dataToSend['kode_upline'] = bloc.kodeUpline.valueWrapper?.value;
    } else if (bloc.kodeUpline.valueWrapper?.value == null && brandId != null) {
      dataToSend['kode_upline'] = brandId;
    }

    http.Response response = await http.post(
      Uri.parse('$apiUrl/user/register'),
      headers: {
        'Content-Type': 'application/json',
        'merchantCode': sigVendor,
      },
      body: json.encode(dataToSend),
    );

    if (response.statusCode == 200) {
      showToast(context,
          'Pendaftaran berhasil, silahkan masuk menggunakan akun baru anda');
      Navigator.of(context).pop();
    } else {
      String message;
      try {
        message = json.decode(response.body)['message'];
      } catch (_) {
        message = 'Terjadi kesalahan saat mengambil data dari server';
      }
      showToast(context, message);
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(.8),
              Theme.of(context).primaryColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * .15),
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),
            configAppBloc.iconApp.valueWrapper?.value['logo'] != null
                ? CachedNetworkImage(
                    imageUrl: configAppBloc.iconApp.valueWrapper?.value['logo'],
                    width: MediaQuery.of(context).size.width * .25,
                    height: MediaQuery.of(context).size.width * .25,
                  )
                : Text(
                    appName,
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            SizedBox(height: 20),
            Text(
              'Daftar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _name,
              keyboardType: TextInputType.name,
              textAlignVertical: TextAlignVertical.center,
              style: textStyle,
              decoration: InputDecoration(
                isDense: true,
                border: border,
                enabledBorder: border,
                focusedBorder: border,
                hintText: 'Nama Lengkap',
                hintStyle: hintStyle,
                prefixIcon: prefixIcon(Icons.person_rounded),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.number,
              textAlignVertical: TextAlignVertical.center,
              style: textStyle,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(13),
              ],
              decoration: InputDecoration(
                isDense: true,
                border: border,
                enabledBorder: border,
                focusedBorder: border,
                hintText: 'Nomor Telepon',
                hintStyle: hintStyle,
                prefixIcon: prefixIcon(Icons.phone_rounded),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _pin,
              keyboardType: TextInputType.number,
              textAlignVertical: TextAlignVertical.center,
              style: textStyle,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              obscureText: _hidePin,
              decoration: InputDecoration(
                isDense: true,
                border: border,
                enabledBorder: border,
                focusedBorder: border,
                hintText: 'Kode PIN',
                hintStyle: hintStyle,
                prefixIcon: prefixIcon(Icons.lock_rounded),
                suffixIcon: IconButton(
                  icon: prefixIcon(_hidePin
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded),
                  onPressed: () {
                    setState(() {
                      _hidePin = !_hidePin;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _state,
              keyboardType: TextInputType.text,
              textAlignVertical: TextAlignVertical.center,
              style: textStyle,
              readOnly: true,
              decoration: InputDecoration(
                isDense: true,
                border: border,
                enabledBorder: border,
                focusedBorder: border,
                hintText: 'Provinsi',
                hintStyle: hintStyle,
                prefixIcon: prefixIcon(Icons.place_rounded),
              ),
              onTap: getState,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _city,
              keyboardType: TextInputType.text,
              textAlignVertical: TextAlignVertical.center,
              style: textStyle,
              readOnly: true,
              decoration: InputDecoration(
                isDense: true,
                border: border,
                enabledBorder: border,
                focusedBorder: border,
                hintText: 'Kota',
                hintStyle: hintStyle,
                prefixIcon: prefixIcon(Icons.place_rounded),
              ),
              onTap: getCity,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _district,
              keyboardType: TextInputType.text,
              textAlignVertical: TextAlignVertical.center,
              style: textStyle,
              readOnly: true,
              decoration: InputDecoration(
                isDense: true,
                border: border,
                enabledBorder: border,
                focusedBorder: border,
                hintText: 'Kecamatan',
                hintStyle: hintStyle,
                prefixIcon: prefixIcon(Icons.place_rounded),
              ),
              onTap: getDistrict,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _address,
              keyboardType: TextInputType.text,
              textAlignVertical: TextAlignVertical.center,
              style: textStyle,
              decoration: InputDecoration(
                isDense: true,
                border: border,
                enabledBorder: border,
                focusedBorder: border,
                hintText: 'Alamat',
                hintStyle: hintStyle,
                prefixIcon: prefixIcon(Icons.home_rounded),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _storeName,
              keyboardType: TextInputType.name,
              textAlignVertical: TextAlignVertical.center,
              style: textStyle,
              decoration: InputDecoration(
                isDense: true,
                border: border,
                enabledBorder: border,
                focusedBorder: border,
                hintText: 'Nama Toko',
                hintStyle: hintStyle,
                prefixIcon: prefixIcon(Icons.store_rounded),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _storeAddress,
              keyboardType: TextInputType.text,
              textAlignVertical: TextAlignVertical.center,
              style: textStyle,
              decoration: InputDecoration(
                isDense: true,
                border: border,
                enabledBorder: border,
                focusedBorder: border,
                hintText: 'Alamat Toko',
                hintStyle: hintStyle,
                prefixIcon: prefixIcon(Icons.storefront_rounded),
              ),
            ),
            SizedBox(height: 25),
            MaterialButton(
              minWidth: double.infinity,
              color: Colors.white,
              elevation: 0,
              shape: StadiumBorder(),
              child: _loading
                  ? Container(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Text('Buat Akun'),
              onPressed: register,
            ),
          ],
        ),
      ),
    );
  }
}

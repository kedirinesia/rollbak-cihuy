// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/Products/payuniblibli/layout/transaksi/list_denom_pulsa.dart';
import 'package:mobile/Products/payuniblibli/layout/transaksi/trx_banner.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/menu.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/models/pulsa.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/transaksi/inquiry_prepaid.dart';

class PulsaPage extends StatefulWidget {
  final MenuModel menu;
  PulsaPage(this.menu);

  @override
  _PulsaPageState createState() => _PulsaPageState();
}

class _PulsaPageState extends State<PulsaPage> {
  TextEditingController _nomor = TextEditingController();
  TextEditingController _denom = TextEditingController();
  List<PulsaModel> denoms = [];
  PulsaModel _selectedDenom;

  @override
  void dispose() {
    _nomor.dispose();
    _denom.dispose();
    super.dispose();
  }

  Future<void> getDenoms(String prefix) async {
    http.Response response = await http.get(
      Uri.parse('$apiUrl/product/pulsa?q=$prefix'),
      headers: {
        'Authorization': bloc.token.valueWrapper?.value,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      setState(() {
        denoms = datas.map((e) => PulsaModel.fromJson(e)).toList();
        _selectedDenom = denoms.first;
        _denom.text = denoms.first.nama;
      });
    } else {
      showToast(context, 'Gagal mengambil daftar denom');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pulsa'),
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade100,
      body: ListView(
        children: [
          BannerTransaction(),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.all(15),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.menu.description,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  'Nomor HP',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _nomor,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    // suffixIcon: _nomor.text.isEmpty
                    //     ? IconButton(
                    //         icon: Icon(Icons.contacts_rounded),
                    //         onPressed: () async {
                    //           String nomor = await Navigator.of(context).push(
                    //             MaterialPageRoute(
                    //               builder: (_) => ContactPage(),
                    //             ),
                    //           );
                    //           if (nomor == null) return;
                    //           if (nomor.startsWith('62')) {
                    //             _nomor.text = '0' + nomor.substring(2);
                    //           } else if (nomor.startsWith('+62')) {
                    //             _nomor.text = '0' + nomor.substring(3);
                    //           } else {
                    //             _nomor.text = nomor;
                    //           }

                    //           getDenoms(_nomor.text.substring(0, 4));
                    //         },
                    //       )
                    //     : IconButton(
                    //         icon: Icon(Icons.close),
                    //         onPressed: () {
                    //           setState(() {
                    //             _nomor.clear();
                    //             denoms.clear();
                    //             _denom.clear();
                    //             _selectedDenom = null;
                    //           });
                    //         },
                    //       ),
                    hintText: 'Contoh: 0812 3456 7890',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    prefix: (denoms.length > 0 &&
                            denoms.first.category is KategoriPulsaModel)
                        ? CachedNetworkImage(
                            imageUrl: denoms.first.category.iconUrl,
                            fit: BoxFit.fitHeight,
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    if (value.length < 4) {
                      setState(() {
                        denoms.clear();
                        _denom.clear();
                        _selectedDenom = null;
                      });
                    } else if (value.length == 4) {
                      getDenoms(value);
                    }
                  },
                ),
                SizedBox(height: denoms.length == 0 ? 0 : 10),
                denoms.length == 0
                    ? SizedBox()
                    : Text(
                        'Denom',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                SizedBox(height: denoms.length == 0 ? 0 : 5),
                denoms.length == 0
                    ? SizedBox()
                    : TextField(
                        controller: _denom,
                        readOnly: true,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.navigate_next_rounded),
                          hintText: 'Pilih Denom',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        onTap: () async {
                          PulsaModel denom = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ListDenomPulsaPage(denoms),
                            ),
                          );

                          if (denom == null) return;
                          setState(() {
                            _selectedDenom = denom;
                            _denom.text = denom.nama;
                          });
                        },
                      ),
                SizedBox(height: denoms.length == 0 ? 0 : 10),
                denoms.length == 0
                    ? SizedBox()
                    : Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          formatRupiah(_selectedDenom.hargaJual),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                SizedBox(height: 30),
                MaterialButton(
                  minWidth: double.infinity,
                  elevation: 0,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  child: Text('Lanjut ke pembayaran'),
                  onPressed: _selectedDenom == null
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => InquiryPrepaid(
                                  _selectedDenom.kodeProduk, _nomor.text),
                            ),
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

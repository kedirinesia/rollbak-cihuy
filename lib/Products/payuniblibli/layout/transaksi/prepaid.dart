// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/Products/payuniblibli/layout/transaksi/list_denom_prepaid.dart';
import 'package:mobile/Products/payuniblibli/layout/transaksi/trx_banner.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/contact.dart';
import 'package:mobile/models/menu.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/models/prepaid-denom.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/transaksi/inquiry_prepaid.dart';

class PrepaidPage extends StatefulWidget {
  final MenuModel menu;
  PrepaidPage(this.menu);

  @override
  _PrepaidPageState createState() => _PrepaidPageState();
}

class _PrepaidPageState extends State<PrepaidPage> {
  TextEditingController _nomor = TextEditingController();
  TextEditingController _denom = TextEditingController();
  List<PrepaidDenomModel> denoms = [];
  PrepaidDenomModel _selectedDenom;

  @override
  void initState() {
    super.initState();
    getDenoms();
  }

  @override
  void dispose() {
    _nomor.dispose();
    _denom.dispose();
    super.dispose();
  }

  Future<void> getDenoms() async {
    http.Response response = await http.get(
      Uri.parse('$apiUrl/product/${widget.menu.category_id}'),
      headers: {
        'Authorization': bloc.token.valueWrapper?.value,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      setState(() {
        denoms = datas.map((e) => PrepaidDenomModel.fromJson(e)).toList();
        _selectedDenom = denoms.first;
        _denom.text = denoms.first.nama;
      });
    } else {
      showToast(context, 'Gagal mengambil daftar denom pada produk ini');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menu.name),
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
                  'Nomor Tujuan',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _nomor,
                  keyboardType: widget.menu.isString
                      ? TextInputType.text
                      : TextInputType.number,
                  inputFormatters: [
                    widget.menu.isString
                        ? FilteringTextInputFormatter.allow(
                            RegExp("[0-9a-zA-Z-_.]"))
                        : FilteringTextInputFormatter.digitsOnly,
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
                    //         },
                    //       )
                    //     : IconButton(
                    //         icon: Icon(Icons.close),
                    //         onPressed: () {
                    //           setState(() {
                    //             _nomor.clear();
                    //           });
                    //         },
                    //       ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Denom',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 5),
                TextField(
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
                    PrepaidDenomModel denom = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ListDenomPrepaidPage(denoms),
                      ),
                    );

                    if (denom == null) return;
                    setState(() {
                      _selectedDenom = denom;
                      _denom.text = denom.nama;
                    });
                  },
                ),
                SizedBox(height: 10),
                _selectedDenom == null
                    ? SizedBox()
                    : Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          formatRupiah(_selectedDenom.harga_jual),
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
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => InquiryPrepaid(
                        _selectedDenom.kode_produk,
                        _nomor.text,
                      ),
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

// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/Products/mykonter/layout/favorite_number.dart';
import 'package:mobile/Products/mykonter/layout/transaksi/inquiry_prepaid.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/contact.dart';
import 'package:mobile/models/favorite_number.dart';
import 'package:mobile/models/menu.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/models/prepaid-denom.dart';
import 'package:mobile/modules.dart';

class PrepaidPage extends StatefulWidget {
  final MenuModel menu;
  PrepaidPage(this.menu);

  @override
  _PrepaidPageState createState() => _PrepaidPageState();
}

class _PrepaidPageState extends State<PrepaidPage> {
  TextEditingController _idpel = TextEditingController();
  TextEditingController _nominal = TextEditingController();
  List<DropdownMenuItem> denoms = [];
  PrepaidDenomModel _denom;

  @override
  void initState() {
    super.initState();
    getDenom();
  }

  @override
  void dispose() {
    _idpel.dispose();
    _nominal.dispose();
    super.dispose();
  }

  Future<void> getDenom() async {
    try {
      http.Response response = await http.get(
        Uri.parse('$apiUrl/product/${widget.menu.category_id}'),
        headers: {
          'Authorization': bloc.token.valueWrapper?.value,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> datas = json.decode(response.body)['data'];
        denoms = datas.map((e) {
          PrepaidDenomModel denom = PrepaidDenomModel.fromJson(e);
          return DropdownMenuItem(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(denom.nama),
                Text(
                  formatRupiah(denom.harga_jual),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            value: denom,
          );
        }).toList();
        setState(() {});
      } else {
        String message = json.decode(response.body)['message'];
        showToast(context, message);
      }
    } catch (_) {
      showToast(context, 'Terjadi kesalahan saat mengambil data dari server');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.menu.name,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.navigate_before),
          onPressed: Navigator.of(context).pop,
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.person_search_rounded),
            onPressed: () async {
              FavoriteNumberModel favNumber = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FavoriteNumberPage(type: 'prepaid'),
                ),
              );

              if (favNumber == null) return;
              _idpel.text = favNumber.tujuan;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(15),
              children: [
                Text(
                  'Nomor Tujuan',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _idpel,
                  keyboardType: widget.menu.isString
                      ? TextInputType.text
                      : TextInputType.number,
                  inputFormatters: [
                    widget.menu.isString
                        ? FilteringTextInputFormatter.allow(
                            RegExp("[0-9a-zA-Z-_.]"))
                        : FilteringTextInputFormatter.digitsOnly,
                  ],
                  autofocus: true,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    isDense: true,
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    // suffixIcon: IconButton(
                    //   icon: Icon(Icons.contacts_rounded),
                    //   onPressed: () async {
                    //     String nomor = await Navigator.of(context).push(
                    //       MaterialPageRoute(
                    //         builder: (_) => ContactPage(),
                    //       ),
                    //     );
                    //     if (nomor == null) return;
                    //     setState(() {
                    //       _idpel.text = nomor.trim();
                    //     });
                    //   },
                    // ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'No. Pelangganmu ada dalam surat tagihan. Simpan datamu supaya kamu cuma perlu memasukannya sekali ini saja',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 15),
                widget.menu.bebasNominal
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nominal',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 5),
                          TextField(
                            controller: _nominal,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            autofocus: true,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              isDense: true,
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              prefixText: 'Rp ',
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pilih Denom',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 5),
                          DropdownButton(
                            items: denoms,
                            value: _denom,
                            onChanged: (value) {
                              setState(() {
                                _denom = value;
                              });
                            },
                            icon: Icon(Icons.keyboard_arrow_down_rounded),
                            isExpanded: true,
                          ),
                        ],
                      ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(.25),
                  blurRadius: 20,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: MaterialButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minWidth: double.infinity,
              elevation: 0,
              child: Text(
                'Lanjutkan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              onPressed: () {
                if (_idpel.text.isEmpty) return;
                if (!widget.menu.bebasNominal && _denom == null) return;
                if (widget.menu.bebasNominal && _nominal.text.isEmpty) return;
                String kodeProduk = widget.menu.bebasNominal
                    ? widget.menu.kodeProduk
                    : _denom.kode_produk;

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => InquiryPrepaidPage(
                      kodeProduk: kodeProduk,
                      nomorTujuan: _idpel.text.trim(),
                      nominal: _nominal.text.isNotEmpty
                          ? int.parse(_nominal.text)
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

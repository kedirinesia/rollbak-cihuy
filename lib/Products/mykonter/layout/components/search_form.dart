// @dart=2.9

import 'dart:convert';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/info.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/info/info.dart';
import 'package:mobile/screen/marketplace/list_produk.dart';
import 'package:mobile/screen/notifikasi/notifikasi.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';
import 'package:http/http.dart' as http;

class SearchForm extends StatefulWidget {
  @override
  _SearchFormState createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  final double aspectRatio = 2.4;
  TextEditingController _searchProduct = TextEditingController();
  List<InfoModel> infos = [];

  @override
  void dispose() {
    _searchProduct.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  Future<void> getInfo() async {
    http.Response response = await http.get(
      Uri.parse('$apiUrl/info/list'),
      headers: {
        'Authorization': bloc.token.valueWrapper?.value,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      setState(() {
        infos = datas.map((e) => InfoModel.fromJson(e)).toList();
      });
    } else {
      String message =
          'Terjadi kesalahan saat mengambil info banner dari server';
      showToast(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        fit: StackFit.loose,
        children: [
          AspectRatio(
            aspectRatio: aspectRatio,
            child: infos.length == 0
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                    ),
                    child: Center(
                      child: Text(
                        'Tidak Ada Banner'.toUpperCase(),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  )
                : CarouselSlider(
                    options: CarouselOptions(
                      autoPlay: false,
                      aspectRatio: aspectRatio,
                      viewportFraction: 1.0,
                    ),
                    items: infos.map((i) {
                      InfoModel info = i;

                      return InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => InfoPage(info),
                          ),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: info.icon,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      );
                    }).toList(),
                  ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 15,
                right: 15,
                left: 15,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 35,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              ScanResult barcode = await BarcodeScanner.scan();
                              if (barcode.rawContent.isNotEmpty) {
                                return Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TransferByQR(barcode.rawContent),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(3),
                                  bottomLeft: Radius.circular(3),
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.qr_code_rounded,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchProduct,
                              keyboardType: TextInputType.text,
                              style: TextStyle(
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                filled: true,
                                contentPadding: EdgeInsets.all(10),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(3),
                                      bottomRight: Radius.circular(3),
                                    )),
                                fillColor: Colors.white,
                                hintText: 'Cari di aplikasi $appName',
                                hintStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                suffixIcon: _searchProduct.text.isEmpty
                                    ? null
                                    : IconButton(
                                        icon: Icon(Icons.close_rounded),
                                        iconSize: 20,
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          setState(() {
                                            _searchProduct.clear();
                                          });
                                        },
                                      ),
                              ),
                              onChanged: (value) {
                                setState(() {});
                              },
                              onSubmitted: (value) =>
                                  Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ListProdukMarketplace(
                                    searchQuery: value,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    child: Icon(
                      Icons.notifications_rounded,
                      color: Colors.white,
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Notifikasi(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

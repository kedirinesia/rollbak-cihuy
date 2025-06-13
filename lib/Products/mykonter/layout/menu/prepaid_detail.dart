// @dart=2.9
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/Products/mykonter/layout/transaksi/inquiry_prepaid.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/models/prepaid-denom.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/modules.dart';

class PrepaidDetailPage extends StatefulWidget {
  final MenuModel menu;
  PrepaidDetailPage(this.menu);

  @override
  _PrepaidDetailPageState createState() => _PrepaidDetailPageState();
}

class _PrepaidDetailPageState extends State<PrepaidDetailPage> {
  TextEditingController _nomor = TextEditingController();

  @override
  void dispose() {
    _nomor.dispose();
    super.dispose();
  }

  Future<List<PrepaidDenomModel>> getDenom() async {
    try {
      http.Response response = await http.get(
        Uri.parse('$apiUrl/product/${widget.menu.category_id}'),
        headers: {
          'Authorization': bloc.token.valueWrapper?.value,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> datas = json.decode(response.body)['data'];
        return datas.map((e) => PrepaidDenomModel.fromJson(e)).toList();
      } else {
        String message = json.decode(response.body)['message'];
        showToast(context, message);
        return [];
      }
    } catch (_) {
      showToast(context, 'Terjadi kesalahan saat mengambil data dari server');
      return [];
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
      ),
      body: FutureBuilder<List<PrepaidDenomModel>>(
        future: getDenom(),
        builder: (ctx, snapshot) {
          if (snapshot.hasError) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(15),
              child: Center(
                child: Text(
                  'TERJADI KESALAHAN',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(15),
              child: Center(
                child: SpinKitThreeBounce(
                  color: Theme.of(context).primaryColor,
                  size: 35,
                ),
              ),
            );
          }

          if (snapshot.data.length == 0) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(15),
              child: Center(
                child: Text(
                  'TIDAK ADA DATA',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ),
            );
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(.25),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.phone_android,
                        size: 25,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: TextField(
                        controller: _nomor,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textAlignVertical: TextAlignVertical.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          prefixText: '+62 ',
                          prefixStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _nomor.clear();
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(15),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.75,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                  ),
                  itemCount: snapshot.data.length,
                  itemBuilder: (_, i) {
                    PrepaidDenomModel denom = snapshot.data.elementAt(i);

                    return InkWell(
                      onTap: () {
                        if (_nomor.text.isEmpty) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => InquiryPrepaidPage(
                              nomorTujuan: '0${_nomor.text}',
                              kodeProduk: denom.kode_produk,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              denom.nama,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Harga: ${formatRupiah(denom.harga_jual)}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/Products/mykonter/layout/favorite_number.dart';
import 'package:mobile/Products/mykonter/layout/transaksi/inquiry_prepaid.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/contact.dart';
import 'package:mobile/models/favorite_number.dart';
import 'package:mobile/models/pulsa.dart';
import 'package:mobile/modules.dart';

class PulsaMenu extends StatefulWidget {
  @override
  _PulsaMenuState createState() => _PulsaMenuState();
}

class _PulsaMenuState extends State<PulsaMenu> {
  bool _loading = false;
  List<PulsaModel> denom = [];
  TextEditingController _nomor = TextEditingController();
  String urlIcon = '';

  @override
  void dispose() {
    _nomor.dispose();
    super.dispose();
  }

  Future<void> getDenom(String prefix) async {
    setState(() {
      _loading = true;
    });

    http.Response response = await http.get(
      Uri.parse('$apiUrl/product/pulsa?q=$prefix'),
      headers: {
        'Authorization': bloc.token.valueWrapper?.value,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      denom = datas.map((e) => PulsaModel.fromJson(e)).toList();
    }

    if (denom.first.category is KategoriPulsaModel &&
        denom.first.category.iconUrl != null) {
      urlIcon = denom.first.category.iconUrl;
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pulsa',
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
              setState(() {
                if (favNumber.tujuan.startsWith('08')) {
                  _nomor.text = favNumber.tujuan.substring(1);
                } else {
                  _nomor.text = favNumber.tujuan;
                }
              });
              denom.clear();
              getDenom(favNumber.tujuan.substring(0, 5));
            },
          ),
        ],
      ),
      body: Column(
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
                urlIcon.isEmpty
                    ? Container(
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
                      )
                    : CachedNetworkImage(
                        imageUrl: urlIcon,
                        width: 40,
                        height: 40,
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
                      //           if (nomor.startsWith('08')) {
                      //             _nomor.text = nomor.substring(1);
                      //           } else if (nomor.startsWith('62')) {
                      //             _nomor.text = nomor.substring(2);
                      //           } else {
                      //             _nomor.text = nomor;
                      //           }

                      //           setState(() {});
                      //         },
                      //       )
                      //     : IconButton(
                      //         icon: Icon(Icons.close),
                      //         onPressed: () {
                      //           setState(() {
                      //             _nomor.clear();
                      //             denom.clear();
                      //           });
                      //         },
                      //       ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                      if (value.length < 3) {
                        setState(() {
                          denom.clear();
                        });
                      } else if (value.length == 3) {
                        getDenom('0$value');
                      }
                    },
                    onEditingComplete: () {
                      if (_nomor.text.length < 4) return;

                      if (_nomor.text.startsWith('08')) {
                        _nomor.text = _nomor.text.substring(1);
                      } else if (_nomor.text.startsWith('62')) {
                        _nomor.text = _nomor.text.substring(2);
                      }

                      String prefix = '0${_nomor.text.substring(0, 3)}';
                      getDenom(prefix);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? Center(
                    child: SpinKitThreeBounce(
                      color: Theme.of(context).primaryColor,
                      size: 35,
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(15),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.75,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                    ),
                    itemCount: denom.length,
                    itemBuilder: (_, i) {
                      PulsaModel pulsa = denom.elementAt(i);

                      return InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => InquiryPrepaidPage(
                              nomorTujuan: '0${_nomor.text}',
                              kodeProduk: pulsa.kodeProduk,
                            ),
                          ),
                        ),
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
                                pulsa.nama,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                //'Harga: ${formatRupiah(pulsa.hargaJual)}',
                                formatRupiah(pulsa.hargaJual),
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
      ),
    );
  }
}

// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/models/prepaid-denom.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/modules.dart';

class ListVoucherDenomPage extends StatefulWidget {
  final MenuModel menu;
  const ListVoucherDenomPage(this.menu, {Key key}) : super(key: key);

  @override
  State<ListVoucherDenomPage> createState() => _ListVoucherDenomPageState();
}

class _ListVoucherDenomPageState extends State<ListVoucherDenomPage> {
  bool _loading = true;
  List<PrepaidDenomModel> _denoms = [];
  PrepaidDenomModel selectedDenom;

  @override
  void initState() {
    _getDenom();
    super.initState();
  }

  _getDenom() async {
    setState(() {
      _loading = true;
    });

    http.Response response = await http.get(
        Uri.parse('$apiUrl/product/${widget.menu.category_id}'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<PrepaidDenomModel> lm = (jsonDecode(response.body)['data'] as List)
          .map((m) => PrepaidDenomModel.fromJson(m))
          .toList();

      setState(() {
        _denoms = lm;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
        _denoms = [];
      });
    }
  }

  onTapdenom(denom) {
    print("onTapdenom called with note: ${denom.note}");
    if (denom.note == 'gangguan') {
      print("Note is 'gangguan'. Showing snackbar.");
      ScaffoldMessenger.of(context).showSnackBar(
        Alert(
          'Produk sedang mengalami gangguan',
          isError: true,
        ),
      );
      return;
    }
    print("Closing current page with selected denom.");
    Navigator.pop(context, denom);
  }

  // Future<void> _getDenom() async {
  //   try {
  //     http.Response response = await http.get(
  //       Uri.parse('$apiUrl/product/${widget.menu.category_id}'),
  //       headers: {
  //         'Authorization': bloc.token.valueWrapper.value,
  //       },
  //     );

  //     _denoms = (json.decode(response.body)['data'] as List)
  //         .map((e) => PrepaidDenomModel.fromJson(e))
  //         .toList();

  //     setState(() {
  //       _loading = false;
  //     });
  //   } catch (err) {
  //     print(err);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Denom'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: packageName == 'com.lariz.mobile'
            ? Theme.of(context).secondaryHeaderColor
            : Theme.of(context).primaryColor,
      ),
      body: _loading
          ? Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(15),
              child: Center(
                child: SpinKitThreeBounce(
                  size: 30,
                  color: packageName == 'com.lariz.mobile'
                      ? Theme.of(context).secondaryHeaderColor
                      : Theme.of(context).primaryColor,
                ),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.all(15),
              itemCount: _denoms.length,
              separatorBuilder: (_, __) => SizedBox(height: 10),
              itemBuilder: (_, i) {
                PrepaidDenomModel denom = _denoms[i];
                bool isPromo = denom.harga_promo != null &&
                    denom.harga_promo > 0 &&
                    denom.harga_jual > denom.harga_promo;

                return InkWell(
                  // onTap: () => Navigator.pop(context, denom),
                  onTap: () => onTapdenom(denom),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(.15),
                          offset: Offset(3, 3),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    width: double.infinity,
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        child: CachedNetworkImage(
                          imageUrl: widget.menu.icon,
                          errorWidget: (_, __, ___) => SizedBox(),
                        ),
                      ),
                      title: Text(
                        denom.nama,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(denom.description),
                      trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: denom.harga_promo == null
                              ? <Widget>[
                                  Text(
                                    formatRupiah(denom.harga_jual),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade600),
                                  ),
                                  SizedBox(
                                    height: !configAppBloc
                                            .displayGangguan.valueWrapper.value
                                        ? 0
                                        : denom.note.isEmpty
                                            ? 0
                                            : 5,
                                  ),
                                  !configAppBloc
                                          .displayGangguan.valueWrapper.value
                                      ? SizedBox()
                                      : denom.note.isEmpty
                                          ? SizedBox()
                                          : Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 3, horizontal: 5),
                                              decoration: BoxDecoration(
                                                color: denom.note == 'gangguan'
                                                    ? Colors.red.shade800
                                                    : denom.note == 'lambat'
                                                        ? Colors.amber.shade800
                                                        : Colors.green.shade800,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Text(
                                                denom.note.toUpperCase(),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                  // Text(
                                  //   formatRupiah(isPromo ? denom.harga_promo : denom.harga_jual),
                                  //   style: TextStyle(
                                  //     fontSize: 12,
                                  //     fontWeight: FontWeight.bold,
                                  //     color: Colors.green.shade600,
                                  //   ),
                                  // ),
                                  // isPromo ? Text(
                                  //   formatRupiah(denom.harga_jual),
                                  //   style: TextStyle(
                                  //     fontSize: 12,
                                  //     fontWeight: FontWeight.w500,
                                  //     color: Colors.red.shade600,
                                  //     decoration: TextDecoration.lineThrough,
                                  //   ),
                                  // ) : SizedBox(),
                                ]
                              : <Widget>[
                                  Text(
                                    formatRupiah(denom.harga_promo),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade600),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    formatRupiah(denom.harga_jual),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  SizedBox(
                                      height: !configAppBloc.displayGangguan
                                              .valueWrapper.value
                                          ? 0
                                          : denom.note.isEmpty
                                              ? 0
                                              : 3),
                                  !configAppBloc
                                          .displayGangguan.valueWrapper.value
                                      ? SizedBox()
                                      : denom.note.isEmpty
                                          ? SizedBox()
                                          : Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 3, horizontal: 5),
                                              decoration: BoxDecoration(
                                                color: denom.note == 'gangguan'
                                                    ? Colors.red.shade800
                                                    : denom.note == 'lambat'
                                                        ? Colors.amber.shade800
                                                        : Colors.green.shade800,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Text(
                                                denom.note.toUpperCase(),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                ]),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

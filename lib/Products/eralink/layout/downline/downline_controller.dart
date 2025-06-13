// @dart=2.9

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/downline.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/Products/eralink/layout/downline/downline.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';
import 'package:mobile/bloc/Bloc.dart' show bloc;

abstract class DownlineController extends State<DownlinePage>
    with TickerProviderStateMixin {
  List<DownlineModel> downlines = [];
  List<DownlineModel> searchResult = [];
  TextEditingController searchQuery = TextEditingController();
  TextEditingController markup = TextEditingController();
  bool loading = true;
  bool loadingMarkup = false;
  int limit = 20;

  @override
  void initState() {
    if (configAppBloc.autoReload.valueWrapper?.value) {
      Timer.periodic(new Duration(seconds: 1), (timer) => getData());
    } else {
      getData();
    }
    super.initState();
  }

  @override
  void dispose() {
    searchQuery.dispose();
    markup.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    String url = '$apiUrl/user/downline/list?page=0&limit=$limit';
    if (widget.id.isNotEmpty) {
      url =
          '$apiUrl/user/downline/list?user_id=${widget.id}&page=0&limit=$limit';
    }

    http.Response response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': bloc.token.valueWrapper?.value,
      },
    );

    if (response.statusCode == 200) {
      downlines.clear();
      searchResult.clear();
      List<dynamic> list = json.decode(response.body)['data'] as List;
      downlines = list.map((item) => DownlineModel.fromJson(item)).toList();
      searchResult = list.map((item) => DownlineModel.fromJson(item)).toList();
    }

    if (this.mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> updateMarkup(String id, int nominal) async {
    showDialog(
      context: context,
      builder: (_) => Center(
        child: SpinKitThreeBounce(
          color: Theme.of(context).primaryColor,
          size: 35,
        ),
      ),
    );
    http.Response response = await http.post(
      Uri.parse('$apiUrl/user/downline/edit-up'),
      headers: {
        'Authorization': bloc.token.valueWrapper?.value,
        'Content-Type': 'application/json',
      },
      body: json.encode(
        {
          'user_id': id,
          'markup': nominal,
        },
      ),
    );

    if (response.statusCode == 200) {
      showToast(context, 'Berhasil merubah markup downline');
      setState(() {
        loading = true;
      });
      getData();
    } else {
      showToast(context, 'Gagal merubah markup downline');
    }

    Navigator.of(context, rootNavigator: true).pop();
  }

  void editMarkup(DownlineModel downline) {
    markup.text = downline.markup.toString();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ubah Markup'),
        content: TextFormField(
          controller: markup,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            prefixText: 'Rp ',
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              'BATAL',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            onPressed: Navigator.of(context, rootNavigator: true).pop,
          ),
          TextButton(
            child: Text(
              'UBAH',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              updateMarkup(downline.id, int.parse(markup.text));
            },
          ),
        ],
      ),
    );
  }

  void onClickMember(DownlineModel downline) {
    showDialog(
      context: context,
      builder: (_) => Center(
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MaterialButton(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minWidth: MediaQuery.of(context).size.width * .6,
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: Text('Lihat Downline'),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DownlinePage(
                        id: downline.id,
                        name: downline.nama,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              MaterialButton(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minWidth: MediaQuery.of(context).size.width * .6,
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: Text('Tambah Saldo'),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TransferByQR(downline.nomor),
                    ),
                  );
                },
              ),
              widget.id.isNotEmpty || packageName == 'com.mocipay.app'
                  ? SizedBox()
                  : SizedBox(height: 10),
              widget.id.isNotEmpty || packageName == 'com.mocipay.app'
                  ? SizedBox()
                  : MaterialButton(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minWidth: MediaQuery.of(context).size.width * .6,
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: Text('Edit Markup'),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        editMarkup(downline);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget loadingWidget() {
    return Center(
        child: SpinKitThreeBounce(
            color: Theme.of(context).primaryColor, size: 35));
  }

  Widget listWidget() {
    if (downlines.length == 0) {
      return Center(
          child: Image.asset(
        'assets/img/downline.png',
        width: MediaQuery.of(context).size.width * .45,
      ));
    } else {
      return Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            widget.id.isEmpty ? SizedBox() : SizedBox(height: 15),
            widget.id.isEmpty
                ? SizedBox()
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Center(
                      child: Text(
                        'Downline dari ${widget.name}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: TextFormField(
                controller: searchQuery,
                cursorColor: Theme.of(context).primaryColor,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor)
                  ),
                  prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).primaryColor,),
                  hintText: 'Pencarian',
                  hintStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor)
                ),
                onChanged: (value) {
                  searchResult = downlines
                      .where((el) =>
                          el.nama.toLowerCase().contains(value.toLowerCase()))
                      .toList();
                  setState(() {});
                },
              ),
            ),
            Expanded(
              child: LazyLoadScrollView(
                scrollOffset: 200,
                onEndOfPage: () {
                  limit += 20;
                  getData();
                },
                child: ListView.separated(
                  padding: EdgeInsets.all(15),
                  separatorBuilder: (_, i) => SizedBox(height: 15),
                  itemCount: searchResult.length,
                  itemBuilder: (context, i) {
                    DownlineModel downline = searchResult[i];

                    return InkWell(
                      onTap: () => onClickMember(downline),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 6,
                              child: Table(
                                columnWidths: {
                                  0: FractionColumnWidth(.3),
                                  1: FractionColumnWidth(.7),
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      Text(
                                        'Nama',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      Text(
                                        downline.nama,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).secondaryHeaderColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(children: [
                                    SizedBox(height: 5),
                                    SizedBox(height: 5),
                                  ]),
                                  TableRow(
                                    children: [
                                      Text(
                                        'Downline',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      Text(
                                        formatNumber(downline.downlineTotal),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).primaryColor
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(children: [
                                    SizedBox(height: 5),
                                    SizedBox(height: 5),
                                  ]),
                                  TableRow(
                                    children: [
                                      Text(
                                        'Status',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      Text(
                                        downline.status ? 'Aktif' : 'Nonaktif',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: downline.status
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              flex: 4,
                              child: Table(
                                columnWidths: {
                                  0: FractionColumnWidth(.4),
                                  1: FractionColumnWidth(.6),
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      Text(
                                        'Saldo',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      Text(
                                        formatRupiah(downline.saldo),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).primaryColor
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(children: [
                                    SizedBox(height: 5),
                                    SizedBox(height: 5),
                                  ]),
                                  TableRow(
                                    children: [
                                      Text(
                                        'Poin',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      Text(
                                        formatNumber(downline.point),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).primaryColor
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(children: [
                                    SizedBox(height: 5),
                                    SizedBox(height: 5),
                                  ]),
                                  TableRow(
                                    children: [
                                      Text(
                                        'Markup',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      Text(
                                        formatRupiah(downline.markup ?? 0),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).primaryColor
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

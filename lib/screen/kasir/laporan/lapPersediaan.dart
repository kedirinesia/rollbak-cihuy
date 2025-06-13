// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

// model
import 'package:mobile/models/kasir/persediaan.dart';

// component
import 'package:mobile/component/loader.dart';

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/modules.dart';

class LapPersediaan extends StatefulWidget {
  @override
  createState() => LapPersediaanState();
}

class LapPersediaanState extends State<LapPersediaan> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final _formKey = new GlobalKey<FormState>();
  TextEditingController query = TextEditingController();
  List<LapPersediaanModel> listPersediaans = [];
  List<LapPersediaanModel> tmpPersediaans = [];

  int page = 0;
  bool isEdge = false;
  bool loading = true;

  @override
  void initState() {
    getData();

    super.initState();
    analitycs.pageView('/lapPersediaan/kasir', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Laporan Persediaan Kasir',
    });
  }

  void getData() async {
    try {
      if (isEdge) return;
      http.Response response = await http.get(
          Uri.parse('$apiUrlKasir/laporan/persediaan?page=$page'),
          headers: {
            'authorization': bloc.token.valueWrapper?.value,
          });

      var responseData = json.decode(response.body);
      String message = responseData['message'] ??
          'Terjadi kesalahan saat mengambil data dari server';
      if (response.statusCode == 200) {
        int status = responseData['status'];
        List<dynamic> datas = responseData['data'];

        if (datas.length == 0)
          setState(() {
            isEdge = true;
            loading = false;
          });
        if (status == 200) {
          datas.forEach((data) {
            listPersediaans.add(LapPersediaanModel.fromJson(data));
            tmpPersediaans.add(LapPersediaanModel.fromJson(data));
          });

          setState(() {
            page++;
          });
        } else {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text('Gagal'),
                    content: Text(message),
                    actions: <Widget>[
                      TextButton(
                        child: Text(
                          'OK',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ));
        }
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('Gagal'),
                  content: Text(message),
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ));
      }
    } catch (err) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Gagal'),
                content: Text(
                    'Terjadi kesalahan saat mengambil data dari server. ${err.toString()}'),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ));
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void refreshData() async {
    setState(() {
      listPersediaans.clear();
      tmpPersediaans.clear();
      page = 0;
      loading = true;
      isEdge = false;
    });

    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        title: Text('Laporan Asset Persediaan'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            formSearch(),
            Flexible(
              flex: 1,
              child: loading
                  ? LoadWidget()
                  : listPersediaans.length == 0
                      ? buildEmpty()
                      : SmartRefresher(
                          controller: _refreshController,
                          enablePullUp: true,
                          enablePullDown: true,
                          onRefresh: () async {
                            refreshData();
                            _refreshController.refreshCompleted();
                          },
                          onLoading: () async {
                            getData();
                            _refreshController.loadComplete();
                          },
                          child: ListView.separated(
                              shrinkWrap: true,
                              physics: ScrollPhysics(),
                              padding: EdgeInsets.all(10.0),
                              itemCount: listPersediaans.length,
                              separatorBuilder: (_, i) => SizedBox(height: 10),
                              itemBuilder: (ctx, i) {
                                LapPersediaanModel asset = listPersediaans[i];
                                return _buildItem(asset);
                              })),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET ITEM
  Widget _buildItem(LapPersediaanModel asset) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.1),
              offset: Offset(5, 10.0),
              blurRadius: 20)
        ]),
        child: ListTile(
          title: Text(
            '${asset.barangModel != null ? asset.barangModel.namaBarang : '-'}',
            style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5.0),
              Text('Harga Jual : ${formatNominal(asset.hargaJual)}',
                  style:
                      TextStyle(fontSize: 13.0, color: Colors.grey.shade700)),
              SizedBox(height: 5.0),
              Text('Total : ${formatNominal(asset.total)}',
                  style:
                      TextStyle(fontSize: 13.0, color: Colors.grey.shade700)),
            ],
          ),
          trailing: Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: Theme.of(context).primaryColor,
            ),
            child: Text('${asset.stock}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ),
      ),
    );
  }

  // FORM PENCARIAN NAMA BARANG
  Widget formSearch() {
    return Container(
      padding:
          EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.1),
            blurRadius: 10.0,
            offset: Offset(5, 10),
          ),
        ],
      ),
      child: TextFormField(
        controller: query,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Cari Nama Barang disini...',
            isDense: true,
            suffixIcon: InkWell(
                child: Icon(Icons.search),
                onTap: () {
                  var list = tmpPersediaans
                      .where((m) => m.barangModel.namaBarang
                          .toLowerCase()
                          .contains(query.text))
                      .toList();

                  setState(() {
                    listPersediaans = list;
                  });
                })),
        onEditingComplete: () {
          var list = tmpPersediaans
              .where((item) => item.barangModel.namaBarang
                  .toLowerCase()
                  .contains(query.text))
              .toList();

          setState(() {
            listPersediaans = list;
          });
        },
        onChanged: (value) {
          var list = tmpPersediaans
              .where((item) => item.barangModel.namaBarang
                  .toLowerCase()
                  .contains(query.text))
              .toList();
          setState(() {
            listPersediaans = list;
          });
        },
      ),
    );
  }

  // WIDGET EMPTY
  Widget buildEmpty() {
    return Center(
      child: SvgPicture.asset('assets/img/empty.svg',
          width: MediaQuery.of(context).size.width * .45),
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}

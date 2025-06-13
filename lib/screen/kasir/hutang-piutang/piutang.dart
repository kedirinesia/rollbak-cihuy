// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

// model
import 'package:mobile/models/kasir/piutang.dart';

// component
import 'package:mobile/component/loader.dart';

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/modules.dart';

// SCREEN PAGE
import 'package:mobile/screen/kasir/hutang-piutang/mutasiPiutang.dart';
import 'package:mobile/screen/kasir/hutang-piutang/form/tambahPiutang.dart';

class PiutangPage extends StatefulWidget {
  @override
  createState() => PiutangPageState();
}

class PiutangPageState extends State<PiutangPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<PiutangModel> listPiutangs = [];
  List<PiutangModel> tmpPiutangs = [];

  int page = 0;
  bool isEdge = false;
  bool loading = true;

  @override
  initState() {
    getData();
    super.initState();
  }

  void getData() async {
    try {
      if (isEdge) return;
      http.Response response = await http.get(
          Uri.parse('$apiUrlKasir/transaksi/piutang?page=$page'),
          headers: {
            'authorization': bloc.token.valueWrapper?.value,
          });

      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan saat mengambil data dari server';
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        int status = responseData['status'];
        List<dynamic> datas = responseData['data'];
        if (datas.length == 0)
          setState(() {
            isEdge = true;
            loading = false;
          });
        if (status == 200) {
          datas.forEach((data) {
            listPiutangs.add(PiutangModel.fromJson(data));
            tmpPiutangs.add(PiutangModel.fromJson(data));
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
      print(err);
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Gagal'),
                content:
                    Text('Terjadi kesalahan saat mengambil data dari server'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Piutang'),
        centerTitle: true,
        elevation: 0.0,
      ),
      floatingActionButton: btnAdd(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Flexible(
                flex: 1,
                child: loading
                    ? LoadWidget()
                    : listPiutangs.length == 0
                        ? buildEmpty()
                        : SmartRefresher(
                            controller: _refreshController,
                            enablePullUp: true,
                            enablePullDown: true,
                            onRefresh: () async {
                              setState(() {
                                listPiutangs.clear();
                                tmpPiutangs.clear();
                                page = 0;
                                loading = true;
                                isEdge = false;
                              });

                              getData();
                              _refreshController.refreshCompleted();
                            },
                            onLoading: () async {
                              getData();
                              _refreshController.loadComplete();
                            },
                            child: ListView.separated(
                                shrinkWrap: true,
                                physics: ScrollPhysics(),
                                itemCount: listPiutangs.length,
                                separatorBuilder: (_, i) =>
                                    SizedBox(height: 10),
                                itemBuilder: (ctx, i) {
                                  var _piutang = listPiutangs[i];
                                  return _buildLitle(i, _piutang);
                                }),
                          )),
          ],
        ),
      ),
    );
  }

  Widget _buildLitle(int index, PiutangModel piutang) {
    return InkWell(
      onTap: () async {
        dynamic response = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MutasiPiutang(piutang),
        ));

        setState(() {
          listPiutangs.clear();
          tmpPiutangs.clear();
          page = 0;
          loading = true;
          isEdge = false;
        });

        getData();
      },
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.1),
              offset: Offset(5, 10.0),
              blurRadius: 20)
        ]),
        child: ListTile(
          leading: CircleAvatar(
            foregroundColor: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(.1),
            child: Text(
              '${piutang.customerModel.nama.split('')[0]}',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
          title: Text(
            '${piutang.customerModel.nama}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          subtitle: piutang.jatuhTempo != ''
              ? Text(
                  formatDate(piutang.jatuhTempo, 'd MMMM yyyy'),
                  style: TextStyle(color: Colors.grey.shade700),
                )
              : null,
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${formatRupiah(piutang.customerModel.saldoHutang)}',
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: piutang.customerModel.saldoHutang > 0
                        ? Colors.red
                        : Colors.green),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget btnAdd() {
    return FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          dynamic response = await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => TambahPiutang(),
          ));

          setState(() {
            listPiutangs.clear();
            tmpPiutangs.clear();
            page = 0;
            loading = true;
            isEdge = false;
          });

          getData();
        });
  }

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

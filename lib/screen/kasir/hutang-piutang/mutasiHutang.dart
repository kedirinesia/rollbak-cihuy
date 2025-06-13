// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

// model
import 'package:mobile/models/kasir/hutang.dart';

// component
import 'package:mobile/component/loader.dart';

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/modules.dart';

// SCREEN PAGE
import 'package:mobile/screen/kasir/hutang-piutang/form/formHutang.dart';

class MutasiHutang extends StatefulWidget {
  HutangModel hutang;

  MutasiHutang(this.hutang);
  @override
  createState() => DetailHutangState();
}

class DetailHutangState extends State<MutasiHutang> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<MutasiHutangModel> detailHutangs = [];

  int page = 0;
  bool loading = true;
  bool isEdge = false;
  int saldoHutang = 0;

  @override
  initState() {
    getData();
    super.initState();
  }

  void getData() async {
    try {
      if (isEdge) return;
      Map<String, dynamic> dataToSend = {
        'id_hutang': widget.hutang.id,
      };

      http.Response response = await http.post(
          Uri.parse('$apiUrlKasir/transaksi/hutang/detail?page=$page'),
          headers: {
            'Content-Type': 'application/json',
            'authorization': bloc.token.valueWrapper?.value,
          },
          body: json.encode(dataToSend));

      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan saat mengambil data dari server';
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        int status = responseData['status'];

        if (status == 200) {
          List<dynamic> datas = responseData['data'];
          datas.forEach((data) {
            detailHutangs.add(MutasiHutangModel.fromJson(data));
          });
          setState(() {
            page++;
            saldoHutang = responseData['saldoHutang'];
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
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ));
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void onPressed() async {
    dynamic response = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FormHutang(widget.hutang, saldoHutang),
    ));

    if (response != null) {
      setState(() {
        page = 0;
        isEdge = false;
        detailHutangs.clear();
      });
      getData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          '${widget.hutang.supplierModel.nama}',
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              size: 30.0,
              color: Colors.white,
            ),
            onPressed: () => onPressed(),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            _buildBoxTop(),
            SizedBox(height: 10.0),
            _buildTopHeader(),
            SizedBox(height: 5.0),
            Flexible(
              flex: 1,
              child: loading
                  ? LoadWidget()
                  : detailHutangs.length == 0
                      ? buildEmpty()
                      : SmartRefresher(
                          controller: _refreshController,
                          enablePullUp: true,
                          enablePullDown: true,
                          onRefresh: () async {
                            page = 0;
                            isEdge = false;
                            detailHutangs.clear();
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
                              itemCount: detailHutangs.length,
                              separatorBuilder: (_, i) => SizedBox(height: 5),
                              itemBuilder: (ctx, i) {
                                MutasiHutangModel _detailHutang =
                                    detailHutangs[i];
                                return _buildItem(_detailHutang);
                              }),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(MutasiHutangModel detailHutang) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.1),
              offset: Offset(5, 10.0),
              blurRadius: 20)
        ]),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${detailHutang.keterangan} ',
                    textScaleFactor: 0.9,
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    formatDate(detailHutang.created_at, 'd MMMM yyyy'),
                    textScaleFactor: 0.8,
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                '${formatNominal(detailHutang.debet)}',
                textScaleFactor: 1.2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.green,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '${formatNominal(detailHutang.kredit)}',
                textScaleFactor: 1.2,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // LABEL HEADER LIST
  Widget _buildTopHeader() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Catatan',
              textScaleFactor: 0.9,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Membayar',
              textScaleFactor: 0.9,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Meminta',
              textScaleFactor: 0.9,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // BOX TOP
  Widget _buildBoxTop() {
    return Container(
      margin: EdgeInsets.all(20.0),
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(.1),
            blurRadius: 10.0,
            offset: Offset(5, 10))
      ]),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                saldoHutang > 0 ? 'Hutang Saya' : 'Lunas',
                style: TextStyle(
                  fontSize: 18.0,
                  color: saldoHutang > 0 ? Colors.grey.shade700 : Colors.green,
                  fontWeight:
                      saldoHutang > 0 ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              Text(
                '${formatRupiah(saldoHutang > 0 ? saldoHutang : 0)}',
                style: TextStyle(
                  fontSize: 20.0,
                  color: saldoHutang > 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: widget.hutang.jatuhTempo != '' ? 5.0 : 0.0),
          widget.hutang.jatuhTempo != '' ? Divider() : SizedBox(height: 0),
          SizedBox(height: widget.hutang.jatuhTempo != '' ? 5.0 : 0.0),
          widget.hutang.jatuhTempo != ''
              ? Text(
                  formatDate(widget.hutang.jatuhTempo, 'd MMMM yyyy'),
                  style: TextStyle(fontSize: 15.0, color: Colors.grey.shade700),
                )
              : Text(
                  'Sampai Akhir Hayat',
                  style: TextStyle(fontSize: 15.0, color: Colors.grey.shade700),
                )
        ],
      ),
    );
  }

  // WIDGET DATA EMPTY
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

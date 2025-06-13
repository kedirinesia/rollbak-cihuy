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

class LapDetailStock extends StatefulWidget {
  String namaBarang;
  String id_barang;
  String tglAwal;
  String tglAkhir;

  LapDetailStock(this.namaBarang, this.id_barang, this.tglAwal, this.tglAkhir);

  @override
  createState() => LapDetailStockState();
}

class LapDetailStockState extends State<LapDetailStock> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<LapStockModel> listStocks = [];

  int page = 0;
  bool isEdge = false;
  bool loading = true;
  int totalDebet = 0;
  int totalKredit = 0;
  int totalStock = 0;

  @override
  void initState() {
    getData();

    super.initState();
    analitycs.pageView('/lapDetailStok/kasir', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Laporan Detail Stok Kasir',
    });
  }

  void getData() async {
    try {
      if (isEdge) return;
      Map<String, dynamic> dataToSend = {
        'id_barang': widget.id_barang,
        'tgl_awal': widget.tglAwal,
        'tgl_akhir': widget.tglAkhir
      };

      http.Response response = await http.post(
          Uri.parse('$apiUrlKasir/laporan/arus-stock/detail?page=$page'),
          headers: {
            'Content-Type': 'application/json',
            'authorization': bloc.token.valueWrapper?.value,
          },
          body: json.encode(dataToSend));

      var responseData = json.decode(response.body);
      String message = responseData['message'] ??
          'Terjadi kesalahan saat mengambil data dari server';
      if (response.statusCode == 200) {
        int status = responseData['status'];
        var datas = responseData['data'];
        var hasil = datas['hasil'];
        var total = datas['total'];

        if (hasil.length == 0)
          setState(() {
            isEdge = true;
            loading = false;
          });
        if (status == 200) {
          hasil.forEach((data) {
            listStocks.add(LapStockModel.fromJson(data));
          });

          setState(() {
            page++;
            totalDebet = total['debet'] != null ? total['debet'] : 0;
            totalKredit = total['kredit'] != null ? total['kredit'] : 0;
            totalStock = total['totalStock'] != null ? total['totalStock'] : 0;
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

  // REFRESH DATA
  void refreshData() async {
    setState(() {
      listStocks.clear();
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
        title: Text('Detail Stok ${widget.namaBarang}'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            _buildBox(),
            SizedBox(height: 15.0),
            _buildTopHeader(),
            SizedBox(height: 5.0),
            Flexible(
              flex: 1,
              child: loading
                  ? LoadWidget()
                  : listStocks.length == 0
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
                              itemCount: listStocks.length,
                              separatorBuilder: (_, i) => SizedBox(height: 10),
                              itemBuilder: (ctx, i) {
                                LapStockModel item = listStocks[i];
                                return _buildItem(item);
                              })),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(LapStockModel item) {
    return Container(
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
                  '${item.keterangan} ',
                  textScaleFactor: 0.9,
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 5.0),
                Text(
                  formatDate(item.created_at, 'd MMMM yyyy'),
                  textScaleFactor: 0.8,
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              '${item.debet}',
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
              '${item.kredit}',
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
              'Masuk',
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
              'Keluar',
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

  // WIDGET BOX TOP
  Widget _buildBox() {
    return Container(
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(.1),
            blurRadius: 10.0,
            offset: Offset(5, 10))
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$totalDebet',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$totalKredit',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      'Keluar',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(),
          Container(
            padding: EdgeInsets.all(10.0),
            child: RichText(
              text: TextSpan(
                text: 'Total Stok ',
                style: TextStyle(
                  color: totalStock > 0 ? Colors.green : Colors.red,
                  fontSize: 12.0,
                ),
                children: [
                  TextSpan(
                    text: '$totalStock',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: totalStock > 0 ? Colors.green : Colors.red,
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

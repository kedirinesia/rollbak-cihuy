// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// model
import 'package:mobile/models/kasir/detailTrx.dart';

// component

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/modules.dart';

// page screen
import 'package:mobile/screen/kasir/penjualan/detailPayment.dart';

class LapDetailJual extends StatefulWidget {
  String idTrx;

  LapDetailJual(this.idTrx);
  @override
  createState() => LapDetailJualState();
}

class LapDetailJualState extends State<LapDetailJual> {
  List<DetailTrxModel> detailTrxs = [];
  int totalTrx = 0;
  bool loading = true;

  @override
  initState() {
    getData();

    super.initState();
  }

  void getData() async {
    try {
      http.Response response = await http.get(
          Uri.parse(
              '$apiUrlKasir/laporan/penjualan/detail?idTrx=${widget.idTrx}'),
          headers: {
            'authorization': bloc.token.valueWrapper?.value,
          });

      var responseData = json.decode(response.body);
      String message = responseData['message'] ??
          'Terjadi kesalahan saat mengambil data dari server';
      if (response.statusCode == 200) {
        int status = responseData['status'];
        Map datas = responseData['data'];

        if (status == 200) {
          var nominal = datas['nominal'];
          var trx = datas['trx'];
          var kasirPrint = datas['kasirPrint'];

          print(kasirPrint);
          trx.forEach((data) {
            detailTrxs.add(DetailTrxModel.fromJson(data));
          });

          setState(() {
            totalTrx = nominal;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: <Widget>[
          SliverAppBar(
            iconTheme: IconThemeData(color: Colors.white),
            expandedHeight: 200.0,
            backgroundColor: Theme.of(context).primaryColor,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Total Transaksi', textAlign: TextAlign.center),
                    SizedBox(height: 10.0),
                    Text('${formatNominal(totalTrx)}',
                        textAlign: TextAlign.center),
                  ],
                ),
                centerTitle: true),
          ),
          SliverPadding(
            padding: EdgeInsets.all(0),
            sliver: loading
                ? SliverList(
                    delegate: SliverChildListDelegate([
                      SizedBox(height: 50.0),
                      Container(
                        child: loadingWidget(),
                      ),
                    ]),
                  )
                : detailTrxs.length > 0
                    ? SliverList(
                        delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          DetailTrxModel detail = detailTrxs[index];
                          return _buildItem(context, detail);
                        },
                        childCount: detailTrxs.length,
                      ))
                    : SliverList(
                        delegate: SliverChildListDelegate([
                          SizedBox(height: 50.0),
                          Container(
                            child: buildEmpty(),
                          ),
                        ]),
                      ),
          )
        ]),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.print),
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () async {
              dynamic response =
                  await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DetailPayment(
                  widget.idTrx,
                ),
              ));
            }));
  }

  Widget _buildItem(BuildContext context, DetailTrxModel item) {
    int totalPrice = item.qty * item.hargaJual;
    return Container(
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.1),
            blurRadius: 10.0,
            offset: Offset(5, 10),
          )
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          foregroundColor: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(.1),
          child: Text(
            '${item.namaBarang.split('')[0]}',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
        title: Text(item.namaBarang,
            style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5.0),
            Text('Supplier : ${item.supplierModel.nama}',
                style: TextStyle(fontSize: 13.0, color: Colors.grey.shade700)),
            SizedBox(height: 5.0),
            Text(
                '${item.qty} x ${formatNominal(item.hargaJual)} = ${formatNominal(totalPrice)}',
                style: TextStyle(fontSize: 13.0, color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }

  Widget buildEmpty() {
    return Center(
      child: SvgPicture.asset('assets/img/empty.svg',
          width: MediaQuery.of(context).size.width * .45),
    );
  }

  Widget loadingWidget() {
    return Center(
      child:
          SpinKitThreeBounce(color: Theme.of(context).primaryColor, size: 35),
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}

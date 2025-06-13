// @dart=2.9
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/postpaid.dart';
import 'package:mobile/models/trx.dart';
import 'package:mobile/modules.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/transaksi/print.dart';

class DetailPostpaid extends StatefulWidget {
  final PostpaidPurchaseModel data;
  DetailPostpaid(this.data);
  @override
  _DetailPostpaidState createState() => _DetailPostpaidState();
}

class _DetailPostpaidState extends State<DetailPostpaid> {
  Future<TrxModel> getData() async {
    http.Response response = await http.get(
      Uri.parse('$apiUrl/trx/${widget.data.id}/print'),
      headers: {
        'Authorization': bloc.token.valueWrapper?.value,
      },
    );

    if (response.statusCode == 200) {
      return TrxModel.fromJson(json.decode(response.body)['data']);
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    analitycs.pageView('/postpaid/detail/' + widget.data.id, {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Detail Postpaid',
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Transaksi'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: packageName == 'com.lariz.mobile'
            ? Theme.of(context).secondaryHeaderColor
            : Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.home_rounded),
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) =>
                      configAppBloc.layoutApp?.valueWrapper?.value['home'] ??
                      templateConfig[
                          configAppBloc.templateCode.valueWrapper?.value],
                ),
                (route) => false),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 5,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      packageName == 'com.lariz.mobile'
                          ? Theme.of(context).secondaryHeaderColor
                          : Theme.of(context).primaryColor,
                      Theme.of(context).canvasColor
                    ],
                    begin: AlignmentDirectional.topCenter,
                    end: AlignmentDirectional.bottomCenter),
              ),
              child: Center(
                  child:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Text(
                  formatRupiah(widget.data.total),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(widget.data.produk,
                    style: TextStyle(
                        color: packageName == 'com.lariz.mobile'
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold))
              ])),
            ),
            Flexible(
              flex: 1,
              child: ListView(
                padding: EdgeInsets.all(15),
                children: <Widget>[
                  SizedBox(height: 20.0),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(.1),
                              offset: Offset(5, 10.0),
                              blurRadius: 20)
                        ]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Informasi Transaksi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: packageName == 'com.lariz.mobile'
                                    ? Theme.of(context).secondaryHeaderColor
                                    : Theme.of(context).primaryColor,
                              ),
                            ),
                            Icon(
                              Icons.info,
                              color: packageName == 'com.lariz.mobile'
                                  ? Theme.of(context).secondaryHeaderColor
                                  : Theme.of(context).primaryColor,
                            )
                          ],
                        ),
                        Divider(),
                        SizedBox(height: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Status',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              widget.data.status.statusText.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: widget.data.status.color,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Nomor Pelanggan',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              widget.data.noPelanggan,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Nama',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              widget.data.nama,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Tagihan',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              formatRupiah(widget.data.tagihan),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Biaya Admin',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              formatRupiah(widget.data.admin),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: widget.data.params.length == 0 ? 0 : 20.0),
                  widget.data.params.length != 0
                      ? Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.1),
                                offset: Offset(5, 10.0),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Informasi Tagihan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: packageName == 'com.lariz.mobile'
                                          ? Theme.of(context)
                                              .secondaryHeaderColor
                                          : Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  Icon(
                                    Icons.receipt,
                                    color: packageName == 'com.lariz.mobile'
                                        ? Theme.of(context).secondaryHeaderColor
                                        : Theme.of(context).primaryColor,
                                  )
                                ],
                              ),
                              Divider(),
                              SizedBox(height: 15),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: widget.data.params.length,
                                separatorBuilder: (_, i) =>
                                    SizedBox(height: 10),
                                itemBuilder: (ctx, i) {
                                  Map<String, dynamic> item =
                                      widget.data.params[i];

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        item['label'],
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        item['value'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        )
                      : SizedBox(),
                  SizedBox(height: 20.0),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(.1),
                            offset: Offset(5, 10.0),
                            blurRadius: 20)
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Informasi Saldo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: packageName == 'com.lariz.mobile'
                                    ? Theme.of(context).secondaryHeaderColor
                                    : Theme.of(context).primaryColor,
                              ),
                            ),
                            Icon(
                              Icons.attach_money,
                              color: packageName == 'com.lariz.mobile'
                                  ? Theme.of(context).secondaryHeaderColor
                                  : Theme.of(context).primaryColor,
                            )
                          ],
                        ),
                        Divider(),
                        SizedBox(height: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Saldo Awal',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              formatRupiah(widget.data.saldoAwal),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Saldo Terpotong',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              formatRupiah(widget.data.saldoTerpotong),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Saldo Akhir',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              formatRupiah(widget.data.saldoAkhir),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
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
          ],
        ),
      ),
      floatingActionButton: widget.data.status.status != 2
          ? null
          : FloatingActionButton(
              child: Icon(Icons.print),
              backgroundColor: packageName == 'com.lariz.mobile'
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).primaryColor,
              onPressed: () {
                getData().then((value) {
                  print("Value in detail_postpaid: $value");
                  print("IsPostpaid in detail_postpaid: true");
                  print("SAMPAI SINI!");
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          PrintPreview(trx: value, isPostpaid: true),
                    ),
                  );
                });
              },
            ),
    );
  }
}

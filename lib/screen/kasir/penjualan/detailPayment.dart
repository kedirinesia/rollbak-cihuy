// @dart=2.9

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';

// model
// import 'package:mobile/models/kasir/listProduct.dart';
import 'package:mobile/models/kasir/kasirPrint.dart';

// component
import 'package:mobile/component/loader.dart';

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';

// page screen
import 'package:mobile/screen/kasir/print/selectPrint.dart';
import 'package:mobile/screen/kasir/print/selectPrintIos.dart';

class DetailPayment extends StatefulWidget {
  // [trx] -> dari halaman transaksi,
  // [history] -> dari halaman history
  String idTrx;
  // List<ListProductModel> listItem;

  DetailPayment(
      // this.listItem,
      this.idTrx);

  @override
  createState() => DetailPaymentState();
}

class DetailPaymentState extends State<DetailPayment> {
  KasirPrintModel printTrx;

  bool loading = true;
  @override
  void initState() {
    getDetailTrx();
    super.initState();
    analitycs.pageView('/detailPayment/kasir', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Detail Payment Kasir',
    });
  }

  void getDetailTrx() async {
    try {
      Map<String, dynamic> dataToSend = {'idTrx': widget.idTrx};

      http.Response response =
          await http.post(Uri.parse('$apiUrlKasir/transaksi/penjualan/print'),
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
          var datas = responseData['data'];
          setState(() {
            printTrx = KasirPrintModel.fromJson(datas);
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
      appBar: AppBar(
        title: Text('Detail Pembayaran'),
        centerTitle: true,
        actions: [
          InkWell(
              onTap: () {
                // Navigator.of(context).popUntil(ModalRoute.withName('/kasir'));
                int count = 0;
                Navigator.popUntil(context, (route) {
                  return count++ == 4;
                });
              },
              child: SvgPicture.asset(
                'assets/img/storefront.svg',
                width: 29.0,
                color: Colors.white,
              )),
        ],
      ),
      body: loading
          ? LoadWidget()
          : Container(
              margin: EdgeInsets.all(15),
              child: Column(
                children: [
                  Flexible(
                    flex: 1,
                    child: ListView(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(.1),
                                    offset: Offset(5, 10),
                                    blurRadius: 20)
                              ]),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20.0),
                              Align(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  bloc.user.valueWrapper?.value.namaToko == ''
                                      ? bloc.username.valueWrapper?.value
                                      : bloc.user.valueWrapper?.value.namaToko,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                              SizedBox(height: 5),
                              Align(
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    bloc.user.valueWrapper?.value.alamatToko ==
                                            ''
                                        ? bloc.user.valueWrapper?.value.alamat
                                        : bloc.user.valueWrapper?.value
                                            .alamatToko,
                                    style: TextStyle(fontSize: 12),
                                  )),
                              SizedBox(height: 20.0),
                              Text(
                                  'TGL : ${formatDate(printTrx.created_at, 'd MMMM yyyy HH:mm:ss')}',
                                  style: TextStyle(fontSize: 12)),
                              SizedBox(height: 5),
                              Text('NO : ${printTrx.id.toUpperCase()}',
                                  style: TextStyle(fontSize: 12)),
                              SizedBox(height: 5),
                              Text('KASIR : ${printTrx.userID['nama']}',
                                  style: TextStyle(fontSize: 12)),
                              SizedBox(height: 20),
                              ListView.separated(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: printTrx.detailTrx.length,
                                  separatorBuilder: (ctx, i) =>
                                      SizedBox(height: 10),
                                  itemBuilder: (ctx, i) {
                                    var detail = printTrx.detailTrx[i];
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          detail['nama_barang'].toUpperCase(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5.0),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${detail['qty']} x ${formatNominal(detail['harga_jual'])}',
                                            ),
                                            Text(
                                              formatNominal(
                                                  detail['total_harga']),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  }),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'PERMBAYARAN',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${printTrx.termin.toUpperCase()}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'TOTAL HARGA',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    formatNominal(printTrx.totalJual),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'UANG BAYAR',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    formatNominal(printTrx.terbayar),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.0),
                              printTrx.termin.toUpperCase() == 'CASH'
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'KEMBALIAN',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${formatNominal(printTrx.terbayar - printTrx.totalJual)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'JUMLAH HUTANG',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${formatNominal(printTrx.totalJual - printTrx.terbayar)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                              SizedBox(height: 25),
                              Align(
                                alignment: Alignment.topCenter,
                                child: Text('TERIMA KASIH ATAS KUNJUNGAN ANDA',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ),
                              SizedBox(height: 30.0)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.print),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () async {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => Platform.isIOS
                    ? SelectPrintIOS(printTrx)
                    : SelectPrint(printTrx)));
          }),
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}

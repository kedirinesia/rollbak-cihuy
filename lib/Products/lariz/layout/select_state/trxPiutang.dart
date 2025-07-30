// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/modules.dart';

// model
import 'package:mobile/models/kasir/kasirPrint.dart';
import 'package:mobile/provider/analitycs.dart';

class SelectTrxPiutang extends StatefulWidget {
  String id_piutang;
  SelectTrxPiutang(this.id_piutang);

  @override
  createState() => SelectTrxPiutangState();
}

class SelectTrxPiutangState extends State<SelectTrxPiutang> {
  List<KasirPrintModel> printTrxs = [];
  List<KasirPrintModel> filtered = [];
  bool isLoading = true;

  @override
  initState() {
    getList();
    void initState() {
      super.initState();
      analitycs.pageView('/trx/piutang/', {
        'userId': bloc.userId.valueWrapper?.value,
        'title': 'Transaksi Piutang Kasir',
      });
    }
  }

  void getList() async {
    setState(() {
      printTrxs.clear();
      filtered.clear();
    });
    try {
      http.Response response = await http.get(
          Uri.parse(
              '$apiUrlKasir/transaksi/piutang/listTrxDebt?id_piutang=${widget.id_piutang}'),
          headers: {
            'authorization': bloc.token.valueWrapper?.value,
          });

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        var datas = responseData['data'];

        datas.forEach((data) {
          printTrxs.add(KasirPrintModel.fromJson(data));
          filtered.add(KasirPrintModel.fromJson(data));
        });
      } else {
        String message = json.decode(response.body)['message'];
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (err) {
      String message =
          'Terjadi kesalahan saat mengambil data dari server, ${err.toString()}';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Transaksi Belum Lunas'),
          centerTitle: true,
          elevation: 0),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Flexible(
              flex: 1,
              child: isLoading
                  ? Container(
                      width: double.infinity,
                      height: double.infinity,
                      padding: EdgeInsets.all(15),
                      child: Center(
                        child: SpinKitThreeBounce(
                            color: Theme.of(context).primaryColor, size: 35),
                      ),
                    )
                  : printTrxs.length == 0
                      ? Container(
                          width: double.infinity,
                          height: double.infinity,
                          padding: EdgeInsets.all(15),
                          child: Center(
                            child: Text(
                              'TIDAK ADA DATA',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: printTrxs.length,
                          padding: EdgeInsets.all(10.0),
                          separatorBuilder: (_, i) => SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            KasirPrintModel printTrx = printTrxs[i];

                            return InkWell(
                              onTap: () {
                                Navigator.of(context).pop(printTrx);
                              },
                              child: Container(
                                padding: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(.1),
                                          offset: Offset(5, 10.0),
                                          blurRadius: 20)
                                    ]),
                                child: ListTile(
                                  dense: true,
                                  title: Text(
                                      'Total Harga : ${formatNominal(printTrx.totalJual)}',
                                      style: TextStyle(
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade700)),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 5.0),
                                      Text(
                                          'Pelanggan : ${printTrx.customerModel != null ? printTrx.customerModel.nama : '-'}',
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.grey.shade700)),
                                      SizedBox(height: 3.0),
                                      Text('Total Item : ${printTrx.totalQty}',
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.grey.shade700)),
                                      SizedBox(height: 3.0),
                                      Text(
                                          'Terbayar : ${formatNominal(printTrx.terbayar)}',
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.grey.shade700)),
                                      SizedBox(height: 3.0),
                                      Text(
                                          'Sisa Bayar : ${formatNominal(printTrx.totalJual - printTrx.terbayar)}',
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.grey.shade700)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
            ),
          ],
        ),
      ),
    );
  }
}

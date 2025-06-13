// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/transfer.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';

class DetailTransfer extends StatefulWidget {
  final TransferModel trf;
  final String tujuan;
  final String nama;
  final String namaToko;
  final int nominal;
  DetailTransfer(this.nama, this.namaToko, this.tujuan, this.nominal, this.trf);
  @override
  _DetailTransferState createState() => _DetailTransferState();
}

class _DetailTransferState extends State<DetailTransfer> {
  @override
  void initState() {
    super.initState();
    analitycs.pageView('/detail/transfer/', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Detail Transfer',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Transfer Berhasil',
                style: TextStyle(color: Theme.of(context).primaryColor)),
            iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
            backgroundColor: Colors.transparent,
            centerTitle: true,
            elevation: 0),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: ListView(padding: EdgeInsets.all(15), children: <Widget>[
            Icon(Icons.check_circle,
                color: Colors.green,
                size: MediaQuery.of(context).size.height * .20),
            // SizedBox(height: 10),
            Text(
              formatRupiah(widget.nominal),
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 40,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
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
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Detail Transfer',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor)),
                        Icon(
                          Icons.receipt,
                          color: Theme.of(context).primaryColor,
                        )
                      ],
                    ),
                    Divider(),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('ID Transfer',
                            style: TextStyle(color: Colors.grey, fontSize: 11)),
                        Text(widget.trf.id.toUpperCase(),
                            style: TextStyle(fontWeight: FontWeight.bold))
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Waktu',
                            style: TextStyle(color: Colors.grey, fontSize: 11)),
                        Text(
                            formatDate(
                                widget.trf.createdAt, 'd MMMM yyyy HH:mm:ss'),
                            style: TextStyle(fontWeight: FontWeight.bold))
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Nomor Tujuan',
                            style: TextStyle(color: Colors.grey, fontSize: 11)),
                        Text(widget.tujuan,
                            style: TextStyle(fontWeight: FontWeight.bold))
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Nama Penerima',
                            style: TextStyle(color: Colors.grey, fontSize: 11)),
                        Text(widget.nama,
                            style: TextStyle(fontWeight: FontWeight.bold))
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Nama Toko',
                            style: TextStyle(color: Colors.grey, fontSize: 11)),
                        Text(widget.namaToko,
                            style: TextStyle(fontWeight: FontWeight.bold))
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Saldo Awal',
                            style: TextStyle(color: Colors.grey, fontSize: 11)),
                        Text(formatRupiah(widget.trf.saldoAwal),
                            style: TextStyle(fontWeight: FontWeight.bold))
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Saldo Akhir',
                            style: TextStyle(color: Colors.grey, fontSize: 11)),
                        Text(formatRupiah(widget.trf.saldoAkhir),
                            style: TextStyle(fontWeight: FontWeight.bold))
                      ],
                    ),
                  ]),
            )
          ]),
        ),
        floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.navigate_before),
            label: Text('Kembali'),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/');
            }));
  }
}

// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/trx.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/transaksi/print.dart';

class DetailTransaksi extends StatefulWidget {
  final TrxModel trx;

  DetailTransaksi(this.trx);
  @override
  _DetailTransaksiState createState() => _DetailTransaksiState();
}

class _DetailTransaksiState extends DetailTransaksiController {
  @override
  void initState() {
    super.initState();
    analitycs.pageView('/transaksi/detail/' + widget.trx.id, {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Detail Transaksi',
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Detail Transaksi'),
          centerTitle: true,
          backgroundColor: packageName == 'com.lariz.mobile'
              ? Theme.of(context).secondaryHeaderColor
              : Theme.of(context).primaryColor,
          elevation: 0),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                    packageName == 'com.lariz.mobile'
                        ? Theme.of(context).secondaryHeaderColor
                        : Theme.of(context).primaryColor,
                    packageName == 'com.lariz.mobile'
                        ? Theme.of(context).secondaryHeaderColor.withOpacity(.2)
                        : Theme.of(context).primaryColor.withOpacity(.2),
                  ],
                      begin: AlignmentDirectional.topCenter,
                      end: AlignmentDirectional.bottomCenter)),
            ),
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 10,
                  left: 0,
                  right: 0),
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0)),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Hero(
                      tag: 'image-' + widget.trx.id,
                      child: CachedNetworkImage(
                          imageUrl: widget.trx.statusModel.icon,
                          width: MediaQuery.of(context).size.width * .20),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Center(
                    child: Text(widget.trx.statusModel.statusText,
                        style: TextStyle(
                            fontSize: 20.0,
                            color: widget.trx.statusModel.color)),
                  ),
                  SizedBox(height: 10.0),
                  Center(
                    child: Hero(
                      tag: 'tujuan-' + widget.trx.id,
                      child: Text(widget.trx.tujuan,
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: packageName == 'com.lariz.mobile'
                                ? Theme.of(context).secondaryHeaderColor
                                : Theme.of(context).primaryColor,
                          )),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  ListTile(
                    title: Text('No. Transaksi'),
                    subtitle: Text(widget.trx.id),
                    dense: true,
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Produk'),
                    subtitle: Text(widget.trx.produk['nama']),
                    dense: true,
                  ),
                  Divider(),
                  ListTile(
                    dense: true,
                    title: Text('SN / Token', style: TextStyle(fontSize: 12.0)),
                    subtitle:
                        Text(widget.trx.sn, style: TextStyle(fontSize: 15.0)),
                    trailing: InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: widget.trx.sn))
                            .then((value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Berhasil Di Copy')));
                        });
                      },
                      child: Icon(Icons.content_copy),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Harga', style: TextStyle(fontSize: 12.0)),
                    subtitle: Text(formatRupiah(widget.trx.harga_jual),
                        style: TextStyle(fontSize: 15.0)),
                    dense: true,
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Tanggal', style: TextStyle(fontSize: 12.0)),
                    subtitle: Text(
                        DateFormat('EEEE, dd MMMM yyyy HH:mm:ss', 'id_ID')
                            .format(DateTime.parse(widget.trx.created_at)),
                        style: TextStyle(fontSize: 15.0)),
                    dense: true,
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Tanggal Status',
                        style: TextStyle(fontSize: 12.0)),
                    subtitle: Text(
                        DateFormat('EEEE, dd MMMM yyyy HH:mm:ss', 'id_ID')
                            .format(DateTime.parse(widget.trx.updated_at)),
                        style: TextStyle(fontSize: 15.0)),
                    dense: true,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: widget.trx.status != 2
          ? null
          : FloatingActionButton(
              child: Icon(Icons.print),
              backgroundColor: packageName == 'com.lariz.mobile'
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).primaryColor,
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PrintPreview(
                        trx: widget.trx,
                        isPostpaid: false,
                      )))),
    );
  }
}

abstract class DetailTransaksiController extends State<DetailTransaksi>
    with TickerProviderStateMixin {}

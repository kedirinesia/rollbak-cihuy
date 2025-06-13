// @dart=2.9

import 'package:flutter/material.dart';

// install package
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/provider/analitycs.dart';

// SCREEN PAGE
import 'package:mobile/screen/kasir/laporan/jual/lapJual.dart';
import 'package:mobile/screen/kasir/laporan/beli/lapBeli.dart';
import 'package:mobile/screen/kasir/laporan/lapPersediaan.dart';
import 'package:mobile/screen/kasir/laporan/stock/lapStock.dart';
import 'package:mobile/screen/kasir/laporan/labaRugi.dart';

import 'package:mobile/screen/kasir/hutang-piutang/index.dart';

class IndexLap extends StatefulWidget {
  @override
  createState() => IndexLapState();
}

class IndexLapState extends State<IndexLap> {
  @override
  void initState() {
    super.initState();
    analitycs.pageView('/halamanLaporan/Kasir', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Halaman Laporan Kasir',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan'),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Container(
        margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: ListView(
          children: [
            _buildItem('Laporan Pembelian', 'Lihat History Transaksi Pembelian',
                'assets/img/kasir/lap-beli.png', () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => LapBeli()));
            }),
            SizedBox(height: 10.0),
            _buildItem('Laporan Penjualan', 'Lihat History Transaksi Penjualan',
                'assets/img/kasir/lap-jual.png', () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => LapJual()));
            }),
            SizedBox(height: 10.0),
            _buildItem('Laporan Stok', 'Lihat History Stok',
                'assets/img/kasir/lap-stock.png', () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => LapStock()));
            }),
            SizedBox(height: 10.0),
            _buildItem('Laporan Asset Persediaan', 'Asset Persediaan Barang',
                'assets/img/kasir/lap-asset.png', () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => LapPersediaan()));
            }),
            SizedBox(height: 10.0),
            _buildItem('Laporan Hutang Piutang', 'Hutang Piutang',
                'assets/img/kasir/debt.png', () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => HutangPiutang()));
            }),
            SizedBox(height: 10.0),
            _buildItem('Laporan Laba Rugi', 'Laba Rugi',
                'assets/img/kasir/laba-rugi.png', () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => LabaRugi()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
      String title, String subtitle, String icon, VoidCallback onTap) {
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(.5),
              offset: Offset(3, 3),
              blurRadius: 15)
        ]),
        child: ListTile(
          leading: CircleAvatar(
            foregroundColor: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(.1),
            child: Image.asset(
              icon,
              width: 30.0,
              height: 30.0,
            ),
          ),
          title: Text(title),
          subtitle: Text(subtitle),
        ),
      ),
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}

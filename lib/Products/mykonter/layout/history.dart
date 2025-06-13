// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/screen/history/order.dart';
import 'package:mobile/screen/history/deposit/deposit.dart';
import 'package:mobile/screen/history/mutasi/mutasi.dart';
import 'package:mobile/screen/history/transaksi.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Riwayat'),
          centerTitle: true,
          backgroundColor: Theme.of(context).appBarTheme.color,
          bottom: TabBar(
              indicatorColor: Theme.of(context).appBarTheme.iconTheme.color,
              labelColor: Theme.of(context).appBarTheme.iconTheme.color,
              unselectedLabelColor:
                  Theme.of(context).appBarTheme.iconTheme.color.withOpacity(.7),
              tabs: [
                Tab(
                  child: Text(
                    'Deposit',
                    style: TextStyle(fontSize: 11),
                  ),
                  icon: Icon(Icons.tab),
                ),
                Tab(
                  child: Text(
                    'Transaksi',
                    style: TextStyle(fontSize: 11),
                  ),
                  icon: Icon(Icons.sort),
                ),
                Tab(
                  child: Text(
                    'Mutasi',
                    style: TextStyle(fontSize: 11),
                  ),
                  icon: Icon(Icons.line_style),
                ),
                Tab(
                  child: Text(
                    'Order',
                    style: TextStyle(fontSize: 11),
                  ),
                  icon: Icon(Icons.local_shipping_rounded),
                ),
              ]),
        ),
        body: TabBarView(physics: ScrollPhysics(), children: [
          DepositPage(),
          HistoryTransaksi(),
          MutasiPage(),
          HistoryOrderPage(),
        ]),
      ),
    );
  }
}

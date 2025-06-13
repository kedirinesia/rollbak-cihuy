// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/screen/history/deposit/deposit.dart';
import 'package:mobile/screen/history/mutasi/mutasi.dart';
import 'package:mobile/screen/history/transaksi.dart';
import 'package:mobile/screen/history/order.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: configAppBloc.isMarketplace.valueWrapper?.value ? 4 : 3,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          bottom: TabBar(
              indicatorColor: Theme.of(context).appBarTheme.iconTheme.color,
              labelColor: Theme.of(context).appBarTheme.iconTheme.color,
              unselectedLabelColor:
                  Theme.of(context).appBarTheme.iconTheme.color.withOpacity(.7),
              tabs: configAppBloc.isMarketplace.valueWrapper?.value
                  ? [
                      Tab(
                        icon: Icon(Icons.account_balance_wallet),
                      ),
                      Tab(
                        icon: Icon(Icons.view_list),
                      ),
                      Tab(
                        icon: Icon(Icons.local_shipping_rounded),
                      ),
                      Tab(
                        icon: Icon(Icons.receipt_long),
                      )
                    ]
                  : [
                      Tab(
                        icon: Icon(Icons.account_balance_wallet),
                      ),
                      Tab(
                        icon: Icon(Icons.view_list),
                      ),
                      Tab(
                        icon: Icon(Icons.receipt_long),
                      )
                    ]),
        ),
        body: TabBarView(
            physics: ScrollPhysics(),
            children: configAppBloc.isMarketplace.valueWrapper?.value
                ? [
                    DepositPage(),
                    HistoryTransaksi(),
                    HistoryOrderPage(),
                    MutasiPage()
                  ]
                : [DepositPage(), HistoryTransaksi(), MutasiPage()]),
      ),
    );
  }
}

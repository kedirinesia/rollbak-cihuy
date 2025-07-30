// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/screen/history/deposit/deposit.dart';
import 'package:mobile/screen/history/mutasi/mutasi.dart';
import 'package:mobile/screen/history/transaksi.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  Future<bool> _onBackPressed() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            configAppBloc.layoutApp?.valueWrapper?.value['home'] ??
            templateConfig[configAppBloc.templateCode.valueWrapper?.value],
      ),
    );
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          bottom: TabBar(
              indicatorColor: Theme.of(context).appBarTheme.iconTheme.color,
              labelColor: Theme.of(context).appBarTheme.iconTheme.color,
              unselectedLabelColor:
                  Theme.of(context).appBarTheme.iconTheme.color.withOpacity(.7),
              tabs: [
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
        body: WillPopScope(
          onWillPop: _onBackPressed,
          child: TabBarView(
              physics: ScrollPhysics(),
              children: [DepositPage(), HistoryTransaksi(), MutasiPage()]),
        ),
      ),
    );
  }
}

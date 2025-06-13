// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/marketplace/voucher/voucherGlobal.dart';
import 'package:mobile/screen/marketplace/voucher/voucherReseller.dart';

// BLOC
import 'package:mobile/bloc/ConfigApp.dart';

class VoucherMarketPage extends StatefulWidget {
  @override
  createState() => VoucherMarketPageState();
}

class VoucherMarketPageState extends State<VoucherMarketPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    analitycs.pageView('/voucher/', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Voucher',
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
                    child: Text(
                        'Voucher ${configAppBloc.namaApp.valueWrapper?.value}')),
                Tab(child: Text('Voucher Untuk Kamu')),
              ]),
        ),
        body: TabBarView(
            physics: ScrollPhysics(),
            children: [VoucherGlobal(), VoucherReseller()]),
      ),
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}

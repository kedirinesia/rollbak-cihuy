// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/Products/outlet/layout/notifikasi/notifikasi_controller.dart';
import 'package:mobile/Products/outlet/layout/card_info.dart';

class Notifikasi extends StatefulWidget {
  @override
  _NotifikasiState createState() => _NotifikasiState();
}

class _NotifikasiState extends NotifikasiController {
  // with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text('Notifikasi'),
    //     centerTitle: true,
    //     leading: GestureDetector(
    //         onTap: () => Navigator.of(context).pushAndRemoveUntil(
    //             MaterialPageRoute(
    //               builder: (_) =>
    //                   configAppBloc.layoutApp?.valueWrapper?.value['home'] ??
    //                   templateConfig[
    //                       configAppBloc.templateCode.valueWrapper?.value],
    //             ),
    //             (route) => false),
    //         child: Icon(Icons.arrow_back_outlined)),
    //   ),
    //   body: loading ? loadingWidget() : listWidget(),
    // );
    return DefaultTabController(
      length: 2,
      // initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          bottom: TabBar(
              indicatorColor: Theme.of(context).appBarTheme.iconTheme.color,
              labelColor: Theme.of(context).appBarTheme.iconTheme.color,
              unselectedLabelColor:
                  Theme.of(context).appBarTheme.iconTheme.color.withOpacity(.7),
              tabs: [
                Tab(text: "Notifikasi"),
                Tab(text: "Informasi"),
              ]),
        ),
        // body: loading ? loadingWidget() : listWidget(),
        body: TabBarView(
          physics: ScrollPhysics(),
          children: [loading ? loadingWidget() : listWidget(), CardInfo()],
        ),
      ),
    );
  }
}

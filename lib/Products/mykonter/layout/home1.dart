import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/Products/mykonter/layout/components/banner.dart';
import 'package:mobile/Products/mykonter/layout/components/menu.dart';
import 'package:mobile/Products/mykonter/layout/components/panel_saldo.dart';
import 'package:mobile/Products/mykonter/layout/components/produk.dart';
import 'package:mobile/Products/mykonter/layout/components/search_form.dart';
import 'package:mobile/Products/mykonter/layout/components/panel.dart';

class GrabHome extends StatefulWidget {
  @override
  _GrabHomeState createState() => _GrabHomeState();
}

class _GrabHomeState extends State<GrabHome> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Container(
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.only(bottom: 15),
        children: [
          SearchForm(),
          PanelSaldo(),
          Center(child: Panel()),
          SizedBox(height: 10),
          MenuComponent(),
          Divider(
            thickness: 2,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 10),
          BannerComponent(),
          SizedBox(height: 15),
          ProdukMarketplace(),
        ],
      ),
    );
  }
}

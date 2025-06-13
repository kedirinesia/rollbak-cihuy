// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/models/menu.dart';

import 'package:mobile/Products/eralink/layout/components/menudepan.dart';
import 'package:mobile/Products/eralink/layout/components/more_model.dart';

class MorePage extends StatefulWidget {
  final List<MenuModel> menus;
  bool isKotak;

  MorePage(this.menus, {this.isKotak});
  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends MorePageModel {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Product Lainnya'),
              centerTitle: true,
            ),
            expandedHeight: 200.0,
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            MenuDepan(grid: 5, gradient: widget.isKotak, menus: widget.menus)
          ]))
        ],
      ),
    );
  }
}

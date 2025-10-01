import 'package:flutter/material.dart';
import 'package:mobile/Products/cuanplus/layout/components/menudepan.dart';
import 'package:mobile/models/menu.dart';

class MoreMenu extends StatefulWidget {
  final List<MenuModel> menus;
  const MoreMenu(this.menus, {key}) : super(key: key);

  @override
  _MoreMenuState createState() => _MoreMenuState();
}

class _MoreMenuState extends State<MoreMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Produk Lainnya'),
              centerTitle: true,
            ),
            expandedHeight: 200.0,
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            MenuDepan(
              grid: 5,
              menus: widget.menus,
              radius: 10,
            )
          ]))
        ],
      ),
    );
  }
}

// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/Products/seepays/layout/MenuDepan.dart';
import 'package:mobile/models/menu.dart';

import '../../../screen/home/more/more_model.dart';

 
 

class MorePage extends StatefulWidget {
  final List<MenuModel> menus;
  final bool isKotak; // final, tidak diubah-ubah

  MorePage(this.menus, {this.isKotak = false}); // default false

  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  
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
            MenuDepan(
              grid: 4,
              gradient: widget.isKotak,
              menus: widget.menus,
            )
          ]))
        ],
      ),
    );
  }
}

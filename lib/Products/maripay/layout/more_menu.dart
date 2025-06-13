import 'package:flutter/material.dart';
import 'package:mobile/Products/maripay/layout/menudepan.dart';
import 'package:mobile/models/menu.dart';

class MoreMenuPage extends StatefulWidget {
  final List<MenuModel> menus;
  final bool isKotak;

  const MoreMenuPage(this.menus, { key, this.isKotak = false }) : super(key: key);

  @override
  _MoreMenuPageState createState() => _MoreMenuPageState();
}

class _MoreMenuPageState extends State<MoreMenuPage> {
  bool isSearching = false;
  TextEditingController q = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  klikSearch() {
    setState(() {
      isSearching = true;
    });
  }
  
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
          SliverList(delegate: SliverChildListDelegate([
            MenuDepan(
              grid: 4,
              gradient: widget.isKotak,
              menus: widget.menus
            )
          ]))
        ],
      ),
    );
  }
}
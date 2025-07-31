// @dart=2.9

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/models/menu.dart';

class MorePage extends StatefulWidget {
  final List<MenuModel> menus;
  final bool isKotak;

  MorePage(this.menus, {this.isKotak = false});

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
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  primary: false,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.menus.length,
                  itemBuilder: (_, int index) {
                    MenuModel menu = widget.menus[index];
                    return Container(
                      child: InkWell(
                        onTap: () => _onTapMenu(menu),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Color(0xFFA259FF).withOpacity(0.06),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFA259FF).withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: CachedNetworkImage(
                                imageUrl: menu.icon,
                                width: 45,
                                height: 45,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(height: 12.0),
                            Flexible(
                              child: Text(
                                menu.name,
                                style: TextStyle(
                                    fontSize: 12.0,
                                    color: Color(0xFFA259FF),
                                    fontWeight: FontWeight.bold),
                                softWrap: true,
                                textAlign: TextAlign.center,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 2,
                      childAspectRatio: 0.95,
                      mainAxisSpacing: 4.0),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void _onTapMenu(MenuModel menu) {
    print('📌 MorePage Menu diklik: ${menu.name}');
    // Handle menu tap here - you can add navigation logic if needed
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Menu ${menu.name} diklik'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

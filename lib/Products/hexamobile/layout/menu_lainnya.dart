// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/ayoba/layout/list_grid_menu.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/screen/detail-denom-postpaid/detail-postpaid.dart';
import 'package:mobile/screen/detail-denom/detail-denom.dart';
import 'package:mobile/screen/dynamic-prepaid/dynamic-denom.dart';
import 'package:mobile/screen/list-sub-menu/list-sub-menu.dart';
import 'package:mobile/screen/pulsa/pulsa.dart';
import 'package:mobile/screen/transaksi/voucher_bulk.dart';

class MoreMenuPage extends StatefulWidget {
  List<MenuModel> allMenu;

  MoreMenuPage(this.allMenu);

  @override
  _MoreMenuScreenState createState() => _MoreMenuScreenState();
}

class _MoreMenuScreenState extends State<MoreMenuPage>
    with TickerProviderStateMixin {
  List<MenuModel> _prepaidMenus = [];
  List<MenuModel> _postpaidMenus = [];

  @override
  void initState() {
    super.initState();
    _prepaidMenus = widget.allMenu
        .where((menu) => menu.type == 1 || menu.type == 3)
        .toList(); // Anggap type 0 adalah Prabayar
    _postpaidMenus = widget.allMenu
        .where((menu) => menu.type == 2)
        .toList(); // Anggap type 1 adalah Pascabayar

    print(_prepaidMenus);
    print(_postpaidMenus);
  }

  onTapMenu(MenuModel menu, BuildContext context) {
    if (menu.jenis == 1) {
      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => Pulsa(menu),
        ),
      );
    } else if (menu.jenis == 2) {
      if (menu.category_id.isNotEmpty && menu.type == 1) {
        return Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailDenom(menu),
          ),
        );
        /*
        LANGSUNG KE DETAIL DENOM
        */
      } else if (menu.kodeProduk.isNotEmpty && menu.type == 2) {
        return Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailDenomPostpaid(menu),
          ),
        );
        /*
        LANGSUNG KE DETAIL DENOM POSTPAID
        */
      } else if (menu.category_id.isEmpty) {
        if (menu.type == 3) {
          return Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => DynamicPrepaidDenom(menu)));
        } else {
          return Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => ListSubMenu(menu)));
        }
      }
    } else if (menu.jenis == 4) {
      print('REDIRECT KE HALAMAN LIST GRID');
      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ListGridMenu(menu),
        ),
      );
    } else if (menu.jenis == 5) {
      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VoucherBulkPage(menu),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Semua Produk',
            style: TextStyle(color: Colors.black, fontSize: 18)),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ColoredBox(
              color: Colors.grey.shade200,
              child: SizedBox(
                width: double.infinity,
                height: 10,
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                'Prabayar',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                    fontSize: 14),
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: 20),
            _buildMenuGrid(_prepaidMenus),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                'Pascabayar',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                    fontSize: 14),
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: 20),
            _buildMenuGrid(_postpaidMenus)
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid(List<MenuModel> menus) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: GridView.builder(
        shrinkWrap: true,
        primary: false,
        physics: BouncingScrollPhysics(),
        itemCount: menus.length,
        itemBuilder: (context, index) {
          MenuModel menu = menus[index];
          return Container(
            // color: Colors.red.withOpacity(.1),
            child: InkWell(
              onTap: () => onTapMenu(menu, context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: LinearGradient(
                          begin: AlignmentDirectional.topCenter,
                          end: AlignmentDirectional.bottomEnd,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(.1),
                            Theme.of(context).primaryColor.withOpacity(.1),
                            Theme.of(context).primaryColor.withOpacity(.1)
                          ]),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: CachedNetworkImage(
                        imageUrl: menu.icon, width: 50.0, fit: BoxFit.cover),
                  ),
                  SizedBox(height: 8),
                  Flexible(
                    child: Text(
                      menu.name,
                      style: TextStyle(
                          fontSize: 10.0,
                          color: Colors.grey.shade500,
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
            crossAxisCount: 5,
            crossAxisSpacing: 5,
            mainAxisSpacing: 30,
            childAspectRatio: .95),
      ),
    );
    // return GridView.builder(
    //   shrinkWrap: true,
    //   physics: NeverScrollableScrollPhysics(),
    //   padding: EdgeInsets.all(0),
    //   itemCount: menus.length,
    //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //     crossAxisCount: 5,
    //     crossAxisSpacing: 5,
    //     childAspectRatio: .95,
    //   ),
    //   itemBuilder: (context, index) {
    //     MenuModel menu = menus[index];
    //     return AnimatedOpacity(
    //       opacity: 1.0,
    //       duration: const Duration(milliseconds: 500),
    //       child: Container(
    //         child: InkWell(
    //           onTap: () => onTapMenu(menu, context),
    //           child: Column(
    //             mainAxisAlignment: MainAxisAlignment.start,
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //             mainAxisSize: MainAxisSize.min,
    //             children: <Widget>[
    //               Container(
    //                 padding: EdgeInsets.symmetric(vertical: 8),
    //                 child: CachedNetworkImage(
    //                   imageUrl: menu.icon,
    //                   width: 40.0,
    //                   fit: BoxFit.cover
    //                 ),
    //               ),
    //               SizedBox(height: 2),
    //               Flexible(
    //                 child: Text(
    //                   menu.name,
    //                   maxLines: 2,
    //                   overflow: TextOverflow.ellipsis,
    //                   style: TextStyle(
    //                     fontSize: 10,
    //                     color: Colors.grey.shade500
    //                   ),
    //                   softWrap: true,
    //                   textAlign: TextAlign.center
    //                 ),
    //               )
    //             ],
    //           ),
    //         ),
    //       ),
    //     );
    //   },
    // );
  }
}

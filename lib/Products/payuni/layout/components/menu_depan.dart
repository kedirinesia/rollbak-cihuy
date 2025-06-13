import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/ayoba/layout/more_menu.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/provider/api.dart';
import 'package:mobile/screen/detail-denom-postpaid/detail-postpaid.dart';
import 'package:mobile/screen/detail-denom/detail-denom.dart';
import 'package:mobile/screen/dynamic-prepaid/dynamic-denom.dart';
import 'package:mobile/screen/list-sub-menu/list-sub-menu.dart';
import 'package:mobile/screen/pulsa/pulsa.dart';
import 'package:mobile/Products/ayoba/layout/list_grid_menu.dart';
import 'package:mobile/screen/transaksi/bulk.dart';
import 'package:mobile/screen/transaksi/voucher_bulk.dart';
import 'package:shimmer/shimmer.dart';

class MenuComponent extends StatefulWidget {
  @override
  _MenuComponentState createState() => _MenuComponentState();
}

class _MenuComponentState extends State<MenuComponent> {
  List<MenuModel> _menu = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    menus();
  }

  Future menus() async {
    try {
      List<dynamic> datas = await api.get('/menu/1', cache: true);

      _menu.addAll(
          datas.sublist(0, 9).map((e) => MenuModel.fromJson(e)).toList());
      _menu.add(
        MenuModel(
          jenis: 99,
          icon: 'https://ayoba.co.id/dokumen/icon/lainnya.png',
          name: 'Lainnya',
          type: 99,
        ),
      );

      setState(() {
        loading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  handleTapMenu(MenuModel menu) {
    if (menu.jenis == 1) {
      return Navigator.of(context).push(MaterialPageRoute(builder: (_) {
        return Pulsa(menu);
      }));
    } else if (menu.jenis == 2) {
      if (menu.category_id.isNotEmpty && menu.type == 1) {
        return Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => DetailDenom(menu)));
        /*
        LANGSUNG KE DETAIL DENOM
        */
      } else if (menu.kodeProduk.isNotEmpty && menu.type == 2) {
        return Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => DetailDenomPostpaid(menu)));
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
      if (menu.category_id.isEmpty) {
        return Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ListSubMenu(menu),
          ),
        );
      } else {
        return Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BulkPage(menu),
          ),
        );
      }
    } else if (menu.jenis == 99) {
      // Navigator.of(context)
      //     .push(MaterialPageRoute(builder: (_) => MoreMenuScreen(showModalBottomSheet)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return loadingMenuDepan();

    return Container(
      padding: EdgeInsets.only(top: 60),
      decoration: BoxDecoration(color: Colors.white),
      child: Container(
        margin: EdgeInsets.only(
          left: 10.0,
          right: 10.0,
          bottom: 5.0,
        ),
        child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(0),
          itemCount: _menu.length,
          itemBuilder: (_, int index) {
            MenuModel menu = _menu[index];
            return Container(
              child: InkWell(
                onTap: () => handleTapMenu(menu),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(8),
                      child: CachedNetworkImage(
                        imageUrl: menu.icon,
                        width: 26.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 2),
                    Flexible(
                      child: Text(
                        menu.name,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade800,
                        ),
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
            childAspectRatio: .95,
          ),
        ),
      ),
    );
  }

  Widget loadingMenuDepan() {
    return Container(
      padding: EdgeInsets.only(top: 60),
      decoration: BoxDecoration(color: Colors.white),
      child: Container(
        margin: EdgeInsets.only(
          left: 10.0,
          right: 10.0,
          bottom: 5.0,
        ),
        child: GridView.count(
          crossAxisCount: 5,
          crossAxisSpacing: 5,
          mainAxisSpacing: 10.0,
          shrinkWrap: true,
          children: List.generate(5 * 2, (i) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 32.0,
                    height: 32.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                    ),
                    child: Container(),
                  ),
                ),
                SizedBox(height: 10.0),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 32.0,
                    height: 10.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Colors.white,
                    ),
                    child: Container(),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

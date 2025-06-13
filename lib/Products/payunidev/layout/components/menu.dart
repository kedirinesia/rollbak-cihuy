// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:mobile/component/menudepan-loading.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/provider/api.dart';
import 'package:mobile/screen/detail-denom-postpaid/detail-postpaid.dart';
import 'package:mobile/screen/detail-denom/detail-denom.dart';
import 'package:mobile/screen/home/more/more.dart';
import 'package:mobile/screen/list-sub-menu/list-sub-menu.dart';
import 'package:mobile/screen/pulsa/pulsa.dart';

class MenuComponent extends StatefulWidget {
  @override
  _MenuComponentState createState() => _MenuComponentState();
}

class _MenuComponentState extends State<MenuComponent> {
  List<MenuModel> _menuMore = [];

  Future<List<MenuModel>> menus() async {
    List<MenuModel> items = [];
    List<dynamic> datas = await api.get('/menu/1', cache: true);

    items.add(
      MenuModel(
        jenis: 99,
        icon: 'https://www.payuni.co.id/img/icon/menu_icon.png',
        name: 'Lainnya',
        type: 99,
      ),
    );
    items
        .addAll(datas.sublist(0, 9).map((e) => MenuModel.fromJson(e)).toList());
    _menuMore = datas
        .sublist(9, datas.length)
        .map((e) => MenuModel.fromJson(e))
        .toList();

    return items;
  }

  onTapMenu(MenuModel menu) {
    if (menu.jenis == 1) {
      return Navigator.of(context).push(MaterialPageRoute(builder: (_) {
        return Pulsa(menu);
      }));
    } else if (menu.jenis == 2) {
      if (menu.category_id.isNotEmpty && menu.type == 1) {
        return Navigator.of(context).push(PageTransition(
            child: DetailDenom(menu), type: PageTransitionType.rippleRightUp));
        /*
        LANGSUNG KE DETAIL DENOM
        */
      } else if (menu.kodeProduk.isNotEmpty && menu.type == 2) {
        return Navigator.of(context).push(PageTransition(
            child: DetailDenomPostpaid(menu),
            type: PageTransitionType.rippleRightUp));
        /*
        LANGSUNG KE DETAIL DENOM POSTPAID
        */
      } else if (menu.category_id.isEmpty) {
        return Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => ListSubMenu(menu)));
      }
    } else if (menu.jenis == 99) {
      Navigator.of(context).push(PageTransition(
          child: MorePage(_menuMore, isKotak: false),
          type: PageTransitionType.slideInUp));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MenuModel>>(
      future: menus(),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) return LoadingMenuDepan(5, baris: 1);

        return Container(
          height: 65,
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 15),
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) => SizedBox(width: 15),
            itemCount: snapshot.data.length,
            itemBuilder: (_, index) {
              MenuModel menu = snapshot.data[index];
              return Container(
                child: InkWell(
                  onTap: () => onTapMenu(menu),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                              begin: AlignmentDirectional.topCenter,
                              end: AlignmentDirectional.bottomEnd,
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(.1),
                                Theme.of(context).primaryColor.withOpacity(.0),
                                Theme.of(context).primaryColor.withOpacity(.1)
                              ]),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: CachedNetworkImage(
                          imageUrl: menu.icon,
                          fit: BoxFit.fitHeight,
                        ),
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
          ),
        );
      },
    );
  }
}

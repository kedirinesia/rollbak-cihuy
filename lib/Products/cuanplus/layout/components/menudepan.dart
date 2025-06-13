// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:mobile/Products/cuanplus/layout/components/more_menu.dart';
import 'package:mobile/component/menudepan-loading.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/provider/api.dart';
import 'package:mobile/screen/detail-denom-postpaid/detail-postpaid.dart';
import 'package:mobile/screen/detail-denom/detail-denom.dart';
import 'package:mobile/screen/dynamic-prepaid/dynamic-denom.dart';
import 'package:mobile/screen/list-sub-menu/list-sub-menu.dart';
import 'package:mobile/screen/list-grid-menu/list-grid-menu.dart';
import 'package:mobile/screen/pulsa/pulsa.dart';

class MenuDepan extends StatefulWidget {
  final int grid;
  final List<MenuModel> menus;
  final int baris;
  final gradient;
  final double radius;

  MenuDepan(
      {@required this.grid,
      this.menus,
      this.gradient,
      this.baris,
      this.radius});
  @override
  _MenuDepanState createState() => _MenuDepanState();
}

class _MenuDepanState extends State<MenuDepan> {
  bool loading = true;
  bool failed = false;
  List<MenuModel> _listMenu = [];
  List<MenuModel> _menuMore = [];

  @override
  void initState() {
    super.initState();
    if (widget.menus == null) {
      print("GET MENU BY API");
      getMenu();
    } else {
      print("LOAD MENU BY DATA");
      setState(() {
        loading = false;
        _listMenu = widget.menus;
      });
    }
  }

  getMenu() async {
    try {
      List<dynamic> datas = await api.get('/menu/1', cache: true);
      List<MenuModel> listMenu =
          datas.map((item) => MenuModel.fromJson(item)).toList();
      failed = false;
      int totalBaris = widget.baris ?? 3;

      if (listMenu.length > (widget.grid * totalBaris)) {
        int startMore = (widget.grid) * totalBaris;
        int endMore = listMenu.length;
        MenuModel buttonMore = MenuModel(
            jenis: 99,
            icon:
                'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Ffilm-reel.png?alt=media&token=50b3ebae-ec61-4583-aa6d-e3ecae41dcbd',
            name: 'Lainnya',
            type: 99);

        List<MenuModel> moreMenu =
            listMenu.sublist(startMore - 1, endMore).toList();

        _menuMore = moreMenu;
        _listMenu = listMenu.sublist(0, startMore - 1).toList();
        _listMenu.add(buttonMore);
      } else {
        _listMenu = listMenu;
      }
    } catch (e) {
      _listMenu = [];
    } finally {
      setState(() {
        loading = false;
      });
    }
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
    } else if (menu.jenis == 99) {
      Navigator.of(context).push(
        PageTransition(
          child: MoreMenu(_menuMore),
          type: PageTransitionType.slideInUp,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? LoadingMenuDepan(widget.grid, baris: widget.baris ?? 3)
        : Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
            child: GridView.builder(
              shrinkWrap: true,
              primary: false,
              physics: BouncingScrollPhysics(),
              itemCount: _listMenu.length,
              itemBuilder: (_, int index) {
                MenuModel menu = _listMenu[index];
                return Container(
                  child: InkWell(
                    onTap: () => onTapMenu(menu),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                widget.radius != null ? widget.radius : 100),
                            gradient: LinearGradient(
                              begin: AlignmentDirectional.topCenter,
                              end: AlignmentDirectional.bottomEnd,
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(.7),
                                Theme.of(context).primaryColor.withOpacity(.9),
                              ],
                            ),
                          ),
                          padding: EdgeInsets.all(3),
                          child: CachedNetworkImage(
                            imageUrl: menu.icon,
                            width: 40.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Spacer(),
                        Text(
                          menu.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                );
              },
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.grid,
                  crossAxisSpacing: 5,
                  childAspectRatio: 0.8,
                  mainAxisSpacing: 10.0),
            ),
          );
  }
}

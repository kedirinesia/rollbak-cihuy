// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:mobile/Products/hexapay/layout/menu_lainnya.dart';
import 'package:mobile/component/menudepan-loading.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/provider/api.dart';
import 'package:mobile/screen/detail-denom-postpaid/detail-postpaid.dart';
import 'package:mobile/screen/detail-denom/detail-denom.dart';
import 'package:mobile/screen/home/more/more.dart';
import 'package:mobile/screen/list-sub-menu/list-sub-menu.dart';
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
      int menuYangDitampilkan = widget.grid * totalBaris;

      List<MenuModel> menuDepan;
      List<MenuModel> menuLainnya;

      if (listMenu.length > (menuYangDitampilkan)) {
        // Menu yang ditampilkan di depan
        menuDepan = listMenu.sublist(0, menuYangDitampilkan - 1);

        // Menu "Lainnya" berisi sisa menu
        menuLainnya = listMenu;

        MenuModel buttonMore = MenuModel(
            jenis: 99,
            icon:
                'https://dokumen.payuni.co.id/logo/hexapay/iconlainya.png',
            name: 'Lainnya',
            type: 99);
        menuDepan.add(buttonMore);
      } else {
        // Jika semua menu muat di halaman depan
        menuDepan = List<MenuModel>.from(listMenu);
        menuLainnya = [];
      }
      setState(() {
        _listMenu = menuDepan;
        _menuMore = menuLainnya; // Simpan sisa menu untuk "Lainnya"
        loading = false;
      });
    } catch (e) {
      _listMenu = [];
      _menuMore = [];
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
        return Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => ListSubMenu(menu)));
      }
    } else if (menu.jenis == 99) {
      return Navigator.of(context).push(PageTransition(
            child: MoreMenuPage(_menuMore),
            type: PageTransitionType.rippleRightUp));
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? LoadingMenuDepan(widget.grid, baris: widget.baris ?? 3)
        : Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: GridView.builder(
              shrinkWrap: true,
              primary: false,
              physics: BouncingScrollPhysics(),
              itemCount: _listMenu.length,
              itemBuilder: (_, int index) {
                MenuModel menu = _listMenu[index];
                return Container(
                  // color: Colors.red.withOpacity(.1),
                  child: InkWell(
                    onTap: () => onTapMenu(menu),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                widget.radius != null ? widget.radius : 100),
                            gradient: LinearGradient(
                                begin: AlignmentDirectional.topCenter,
                                end: AlignmentDirectional.bottomEnd,
                                colors: [
                                  Theme.of(context)
                                      .primaryColor
                                      .withOpacity(widget.gradient != null
                                          ? widget.gradient
                                              ? 0.0
                                              : .1
                                          : .1),
                                  Theme.of(context)
                                      .primaryColor
                                      .withOpacity(widget.gradient != null
                                          ? widget.gradient
                                              ? 0.0
                                              : .1
                                          : .0),
                                  Theme.of(context)
                                      .primaryColor
                                      .withOpacity(widget.gradient != null
                                          ? widget.gradient
                                              ? 0.0
                                              : .1
                                          : .1)
                                ]),
                          ),
                          padding: EdgeInsets.all(widget.gradient != null
                              ? widget.gradient
                                  ? 0.0
                                  : 8.0
                              : 8.0),
                          child: menu.icon != null
                            ? CachedNetworkImage(
                                imageUrl: menu.icon,
                                width: 40.0,
                                fit: BoxFit.cover)
                            : Container(),
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
                  crossAxisCount: widget.grid,
                  crossAxisSpacing: 5,
                  childAspectRatio: .95),
            ),
          );
  }
}

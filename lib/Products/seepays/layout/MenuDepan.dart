// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
 
import 'package:mobile/config.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/provider/api.dart';
import 'package:mobile/screen/detail-denom-postpaid/detail-postpaid.dart';
import 'package:mobile/screen/detail-denom/detail-denom.dart';
import 'package:mobile/screen/dynamic-prepaid/dynamic-denom.dart';

import 'package:mobile/screen/list-sub-menu/list-sub-menu.dart';
import 'package:mobile/screen/list-grid-menu/list-grid-menu.dart';
import 'package:mobile/screen/pulsa/pulsa.dart';
import 'package:mobile/screen/transaksi/voucher_bulk.dart';

import '../../../component/menudepan-loading.dart';
import '../../seepays/layout/morepage.dart';
 


class MenuDepan extends StatefulWidget {
  final int grid;
  final List<MenuModel> menus;
  final int baris;
  final gradient;
  final double radius;

  MenuDepan({
    @required this.grid,
    this.menus,
    this.gradient,
    this.baris,
    this.radius,
  });

  @override
  _MenuDepanState createState() => _MenuDepanState();
}

class _MenuDepanState extends State<MenuDepan> {
  bool loading = true;
  bool failed = false;
  List<MenuModel> _listMenu = [];

  @override
  void initState() {
    super.initState();
    if (widget.menus == null) {
      getMenu();
    } else {
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

      int maxShow = 15;
      List<MenuModel> showMenu;
      if (listMenu.length > maxShow - 1) {
        showMenu = listMenu.sublist(0, maxShow - 1);
      } else {
        showMenu = List<MenuModel>.from(listMenu);
      }

      MenuModel buttonMore = MenuModel(
        jenis: 99,
        icon: 'https://dokumen.payuni.co.id/logo/Seepays/seepaysmenulainya.png',
        name: 'Menu Lainnya',
        type: 99,
      );
      _listMenu = List<MenuModel>.from(showMenu)..add(buttonMore);
    } catch (e) {
      _listMenu = [];
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  List<String> pkgName = [
    'com.mkrdigital.mobile',
    'id.outletpay.mobile',
    'id.payku.app',
    'com.eralink.mobileapk',
    'mobile.payuni.id',
    'com.esaldoku.mobileserpul',
    'com.talentapay.android',
    'mypay.co.id',
    'com.santrenpay.mobile',
    'com.seepaysbiller.app'
  ];

 onTapMenu(MenuModel menu) {
  print('📌 Menu diklik: ${menu.name} | jenis: ${menu.jenis}, type: ${menu.type}, category_id: ${menu.category_id}, kodeProduk: ${menu.kodeProduk}');

  if (menu.jenis == 1) {
    print('➡️ Menu menuju ke: Pulsa');
    return Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return Pulsa(menu);
    }));
  } else if (menu.jenis == 2) {
    if (menu.category_id != null && menu.category_id.isNotEmpty && menu.type == 1) {
      print('➡️ Menu menuju ke: DetailDenom');
      return Navigator.of(context).push(PageTransition(
          child: DetailDenom(menu), type: PageTransitionType.rippleRightUp));
    } else if (menu.kodeProduk != null && menu.kodeProduk.isNotEmpty && menu.type == 2) {
      print('➡️ Menu menuju ke: DetailDenomPostpaid');
      return Navigator.of(context).push(PageTransition(
          child: DetailDenomPostpaid(menu),
          type: PageTransitionType.rippleRightUp));
    } else {
      if (menu.type == 3) {
        print('➡️ Menu menuju ke: DynamicPrepaidDenom');
        return Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => DynamicPrepaidDenom(menu)));
      } else {
        print('➡️ Menu menuju ke: ListSubMenu (category_id kosong/null)');
        return Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => ListSubMenu(menu)));
      }
    }
  } else if (menu.jenis == 4) {
    print('➡️ Menu menuju ke: ListGridMenu');
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListGridMenu(menu),
      ),
    );
  } else if (menu.jenis == 5 || menu.jenis == 6) {
    if (menu.category_id == null || menu.category_id.isEmpty) {
      print('➡️ Menu menuju ke: ListSubMenu');
      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ListSubMenu(menu),
        ),
      );
    } else if (pkgName.contains(packageName)) {
      print('➡️ Menu menuju ke: VoucherBulkPage');
      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VoucherBulkPage(menu),
        ),
      );
    } else {
      print('❌ Tidak ada navigasi untuk kondisi jenis ${menu.jenis}');
      return;
    }
  } else if (menu.jenis == 99) {
    print('➡️ Menu menuju ke: MorePage (Menu Lainnya)');
    List<MenuModel> allMenus =
        (widget.menus ?? _listMenu).where((m) => m.jenis != 99).toList();
    return Navigator.of(context).push(PageTransition(
      child: MorePage(
        allMenus,
        isKotak: widget.gradient != null ? widget.gradient : false,
      ),
      type: PageTransitionType.slideInUp,
    ));
  } else {
    print('❌ Tidak ada navigasi untuk jenis ${menu.jenis}');
  }
}



  @override
  Widget build(BuildContext context) {
    return loading
        ? LoadingMenuDepan(widget.grid, baris: widget.baris ?? 3)
        : Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
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
                          width: 54,
                          height: 54,
                         decoration: BoxDecoration(
                               color: Color(0xFFA259FF).withOpacity(0.06),
                                shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: CachedNetworkImage(
                            imageUrl: menu.icon,
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 10.0),
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
                  crossAxisSpacing: 2,
                  childAspectRatio: 0.95,
                  mainAxisSpacing: 4.0),
            ),
          );
  }
}

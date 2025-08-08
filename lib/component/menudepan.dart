// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:mobile/component/menudepan-loading.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/provider/api.dart';
import 'package:mobile/screen/detail-denom-postpaid/detail-postpaid.dart';
import 'package:mobile/screen/detail-denom/detail-denom.dart';
import 'package:mobile/screen/dynamic-prepaid/dynamic-denom.dart';
import 'package:mobile/screen/home/more/more.dart';
import 'package:mobile/screen/list-sub-menu/list-sub-menu.dart';
import 'package:mobile/screen/list-grid-menu/list-grid-menu.dart';
import 'package:mobile/screen/pulsa/pulsa.dart';
import 'package:mobile/screen/transaksi/voucher_bulk.dart';

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
    // Set system UI overlay style to handle system navigation bar
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
    
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

      // Print menu information for debugging
      print('=== DEBUG: Menu Information ===');
      print('Total menu received: ${listMenu.length}');
      for (int i = 0; i < listMenu.length; i++) {
        MenuModel menu = listMenu[i];
        print('Menu $i: ${menu.name} - Jenis: ${menu.jenis} - Type: ${menu.type}');
        if (menu.name.toLowerCase().contains('inject') || 
            menu.name.toLowerCase().contains('voucher') ||
            menu.jenis == 5 || menu.jenis == 6) {
          print('  *** INJECT/VOUCHER MENU DETECTED ***');
          print('  Name: ${menu.name}');
          print('  Jenis: ${menu.jenis}');
          print('  Type: ${menu.type}');
          print('  Category ID: ${menu.category_id}');
          print('  Kode Produk: ${menu.kodeProduk}');
        }
      }
      print('=== END DEBUG ===');

      // Filter out bulk voucher menu for akupay
      if (packageName == 'com.akupay.androidmobileapps') {
        print('=== AKUPAY DETECTED - Filtering inject menus ===');
        int beforeCount = listMenu.length;
        listMenu = listMenu.where((menu) {
          // Filter out inject voucher and inject perdana menus
          bool isInjectMenu = menu.name.toLowerCase().contains('inject');
          bool isVoucherMenu = menu.name.toLowerCase().contains('voucher') && menu.jenis == 2;
          bool isBulkVoucher = menu.jenis == 5 || menu.jenis == 6;
          
          if (isInjectMenu || isVoucherMenu || isBulkVoucher) {
            print('Filtering out menu: ${menu.name} (Jenis: ${menu.jenis})');
            return false;
          }
          return true;
        }).toList();
        int afterCount = listMenu.length;
        print('Filtered out ${beforeCount - afterCount} inject/voucher menus');
        print('Remaining menus: $afterCount');
      }

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

  List<String> pkgName = [
    'com.mkrdigital.mobile',
    'id.outletpay.mobile',
    'id.payku.app',
    'com.eralink.mobileapk',
    'mobile.payuni.id',
    'com.esaldoku.mobileserpul',
    'com.talentapay.android',
    'mypay.co.id',
    'com.santrenpay.mobile'
  ];

  onTapMenu(MenuModel menu) {
    // Debug print for menu access
    print('=== DEBUG: Menu Access Attempt ===');
    print('Menu Name: ${menu.name}');
    print('Menu Jenis: ${menu.jenis}');
    print('Menu Type: ${menu.type}');
    print('Package Name: $packageName');
    print('Is Akupay: ${packageName == 'com.akupay.androidmobileapps'}');
    
    // Prevent akupay from accessing bulk voucher menu
    if (packageName == 'com.akupay.androidmobileapps' && 
        (menu.jenis == 5 || menu.jenis == 6 || 
         menu.name.toLowerCase().contains('inject') ||
         (menu.name.toLowerCase().contains('voucher') && menu.jenis == 2))) {
      print('*** BLOCKED: Akupay trying to access inject/voucher menu ***');
      print('Menu: ${menu.name} (Jenis: ${menu.jenis})');
      return; // Do nothing for akupay
    }
    
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
    } else if (menu.jenis == 5 || menu.jenis == 6) {
      print('*** ACCESSING BULK VOUCHER MENU ***');
      print('Menu: ${menu.name} (Jenis: ${menu.jenis})');
      if (menu.category_id.isEmpty) {
        return Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ListSubMenu(menu),
          ),
        );
      } else if (pkgName.contains(packageName)) {
        return Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VoucherBulkPage(menu),
          ),
        );
      } else {
        return;
      }
    } else if (menu.jenis == 99) {
      Navigator.of(context).push(PageTransition(
          child: MorePage(_menuMore,
              isKotak: widget.gradient != null ? widget.gradient : false),
          type: PageTransitionType.slideInUp));
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
                  // color: Colors.red.withOpacity(.1),
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
                          child: CachedNetworkImage(
                              imageUrl: menu.icon,
                              width: 40.0,
                              fit: BoxFit.cover),
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
                  crossAxisSpacing: 5,
                  childAspectRatio: 0.8,
                  mainAxisSpacing: 10.0),
            ),
          );
  }
}

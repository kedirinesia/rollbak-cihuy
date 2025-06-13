// @dart=2.9

import 'dart:convert';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/lariz/config.dart';
import 'package:mobile/Products/lariz/layout/components/more_menu.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/models/menu.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screen/detail-denom-postpaid/detail-postpaid.dart';
import 'package:mobile/screen/detail-denom/detail-denom.dart';
import 'package:mobile/screen/dynamic-prepaid/dynamic-denom.dart';
import 'package:mobile/screen/list-sub-menu/list-sub-menu.dart';
import 'package:mobile/screen/pulsa/pulsa.dart';
import 'package:mobile/Products/lariz/layout/components/list_grid_menu.dart';
import 'package:shimmer/shimmer.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as SlideDialog;
import 'dart:math' as math;

class MenuComponent extends StatefulWidget {
  @override
  _MenuComponentState createState() => _MenuComponentState();
}

class _MenuComponentState extends State<MenuComponent> {
  List<MenuModel> _prepaidDenomMenu = [];
  List<MenuModel> _postpaidDenomMenu = [];

  List<MenuModel> _prepaidDenomMenuDepan = [];
  List<MenuModel> _postpaidDenomMenuDepan = [];

  int _menuIndex = 0;
  bool _menuPrepaidDenomVisible = true;
  bool _menuPostpaidDenomVisible = false;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    menus();
  }

  Future menus() async {
    try {
      String url = '$apiUrl/menu/1';

      http.Response response = await http.get(Uri.parse(url), headers: {
        'Authorization': bloc.token.valueWrapper?.value,
      });

      if (response.statusCode == 200) {
        List<dynamic> datas = json.decode(response.body)['data'];
        List<MenuModel> datasC =
            datas.map((e) => MenuModel.fromJson(e)).toList();

        _prepaidDenomMenu.addAll(datasC.where((element) {
          if (element.type == 1) return true;
          if (element.type == 3) return true;

          return false;
        }));

        _prepaidDenomMenuDepan =
            _prepaidDenomMenu.sublist(0, math.min(9, _prepaidDenomMenu.length));
        // if (_prepaidDenomMenu.length >= 10) {
        //   _prepaidDenomMenuDepan = _prepaidDenomMenu.sublist(0, 9);
        // }

        _postpaidDenomMenu.addAll(datasC.where((element) {
          if (element.type == 2) return true;

          return false;
        }));

        _postpaidDenomMenuDepan = _postpaidDenomMenu.sublist(
            0, math.min(9, _postpaidDenomMenu.length));
        // if (_postpaidDenomMenu.length >= 10) {
        //   _postpaidDenomMenuDepan = _postpaidDenomMenu.sublist(0, 9);
        // }

        _prepaidDenomMenuDepan.add(
          MenuModel(
            jenis: 88,
            icon: 'https://dokumen.payuni.co.id/logo/mba/menulainyamba.png',
            name: 'Lainnya',
            type: 88,
          ),
        );

        _postpaidDenomMenuDepan.add(
          MenuModel(
            jenis: 99,
            icon: 'https://dokumen.payuni.co.id/logo/mba/menulainyamba.png',
            name: 'Lainnya',
            type: 99,
          ),
        );

        setState(() {
          loading = false;
        });
      } else {
        String message = json.decode(response.body)['message'] ??
            'Terjadi kesalahan pada server';
        final snackBar = Alert(message, isError: true);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
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
    } else if (menu.jenis == 88) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => MoreMenuScreen(_prepaidDenomMenu, 1)));
    } else if (menu.jenis == 99) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => MoreMenuScreen(_postpaidDenomMenu, 2)));
    }
  }

  void showMoreMenu(List<MenuModel> items) {
    SlideDialog.showSlideDialog(
      context: context,
      child: Expanded(
        child: Column(
          children: [
            Text(
              'Menu Lainnya',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Divider(),
            Flexible(
              child: Container(
                margin: EdgeInsets.all(10),
                child: GridView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(0),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    MenuModel menu = items.elementAt(i);
                    return Container(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          handleTapMenu(menu);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                gradient: LinearGradient(
                                    begin: AlignmentDirectional.topCenter,
                                    end: AlignmentDirectional.bottomEnd,
                                    colors: [
                                      Theme.of(context)
                                          .secondaryHeaderColor
                                          .withOpacity(.1),
                                      Theme.of(context)
                                          .secondaryHeaderColor
                                          .withOpacity(.0),
                                      Theme.of(context)
                                          .secondaryHeaderColor
                                          .withOpacity(.1)
                                    ]),
                              ),
                              padding: EdgeInsets.all(8),
                              child: CachedNetworkImage(
                                imageUrl: menu.icon,
                                width: 40.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 8),
                            Flexible(
                              child: Text(
                                menu.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.center,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                    // );
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 5,
                    childAspectRatio: .95,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return loadingMenuDepan();

    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Container(
        margin: EdgeInsets.only(
          left: 15.0,
          right: 15.0,
          bottom: 15.0,
        ),
        child: Column(
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () => setState(() {
                    _menuIndex = 0;
                    _menuPrepaidDenomVisible = true;
                    _menuPostpaidDenomVisible = false;
                  }),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    decoration: BoxDecoration(
                      color: _menuIndex == 0
                          ? Colors.grey.shade200
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'Prabayar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _menuIndex == 0
                            ? Theme.of(context).secondaryHeaderColor
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
                // SizedBox(width: 10),
                InkWell(
                  onTap: () => setState(() {
                    _menuIndex = 1;
                    _menuPrepaidDenomVisible = false;
                    _menuPostpaidDenomVisible = true;
                  }),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    decoration: BoxDecoration(
                      color: _menuIndex == 1
                          ? Colors.grey.shade200
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'Pascabayar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _menuIndex == 1
                            ? Theme.of(context).secondaryHeaderColor
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            IndexedStack(
              index: _menuIndex,
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(0),
                  itemCount: _prepaidDenomMenuDepan.length,
                  itemBuilder: (_, int index) {
                    MenuModel prepaidDenomMenuDepan =
                        _prepaidDenomMenuDepan[index];
                    return AnimatedOpacity(
                      opacity: _menuPrepaidDenomVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        child: InkWell(
                          onTap: () => handleTapMenu(prepaidDenomMenuDepan),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: CachedNetworkImage(
                                  imageUrl: prepaidDenomMenuDepan.icon,
                                  width: 26.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 2),
                              FittedBox(
                                child: Text(
                                  prepaidDenomMenuDepan.name,
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
                      ),
                    );
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 5,
                    childAspectRatio: .95,
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(0),
                  itemCount: _postpaidDenomMenuDepan.length,
                  itemBuilder: (_, int index) {
                    MenuModel postpaidDenomMenuDepan =
                        _postpaidDenomMenuDepan[index];
                    return AnimatedOpacity(
                      opacity: _menuPostpaidDenomVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        child: InkWell(
                          onTap: () => handleTapMenu(postpaidDenomMenuDepan),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: CachedNetworkImage(
                                  imageUrl: postpaidDenomMenuDepan.icon,
                                  width: 26.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                postpaidDenomMenuDepan.name,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade800,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
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
              ],
            ),
          ],
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
          left: 15.0,
          right: 15.0,
          bottom: 13.0,
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 1, top: 8, bottom: 15),
              child: Row(
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade200,
                    child: Container(
                      width: 65.0,
                      height: 35.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.white,
                      ),
                      child: Container(),
                    ),
                  ),
                  SizedBox(width: 10),
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade200,
                    child: Container(
                      width: 65.0,
                      height: 35.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.white,
                      ),
                      child: Container(),
                    ),
                  ),
                ],
              ),
            ),
            GridView.count(
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
          ],
        ),
      ),
    );
  }
}

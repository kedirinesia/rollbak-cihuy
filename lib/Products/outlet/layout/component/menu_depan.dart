// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/outlet/config.dart';
import 'package:mobile/Products/outlet/layout/more_menu.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/models/menu.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screen/detail-denom-postpaid/detail-postpaid.dart';
import 'package:mobile/screen/detail-denom/detail-denom.dart';
import 'package:mobile/screen/dynamic-prepaid/dynamic-denom.dart';
import 'package:mobile/screen/list-sub-menu/list-sub-menu.dart';
import 'package:mobile/screen/pulsa/pulsa.dart';
import 'package:mobile/Products/outlet/layout/list_grid_menu.dart';
import 'package:mobile/screen/transaksi/voucher_bulk.dart';
import 'package:shimmer/shimmer.dart';

class MenuComponent extends StatefulWidget {
  @override
  _MenuComponentState createState() => _MenuComponentState();
}

class _MenuComponentState extends State<MenuComponent> {
  List<MenuModel> _prepaidDenomMenu = [];
  // List<MenuModel> _postpaidDenomMenu = [];

  List<MenuModel> _prepaidDenomMenuDepan = [];
  // List<MenuModel> _postpaidDenomMenuDepan = [];

  int _menuIndex = 0;
  // bool _menuPrepaidDenomVisible = true;
  // bool _menuPostpaidDenomVisible = false;

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
        print(datasC.length);
        _prepaidDenomMenu.addAll(datasC.where((element) {
          if (element.type == 1) return true;
          if (element.type == 3) return true;
          if (element.type == 2) return true;

          return false;
        }));

        _prepaidDenomMenuDepan = _prepaidDenomMenu.sublist(0, 19);
        print(_prepaidDenomMenu.length);
        // _postpaidDenomMenu.addAll(datasC.where((element) {

        //   return false;
        // }));

        // _postpaidDenomMenuDepan = _postpaidDenomMenu.sublist(0, 9);

        _prepaidDenomMenuDepan.add(
          MenuModel(
            jenis: 99,
            icon: 'https://ayoba.co.id/dokumen/icon/lainnya.png',
            name: 'Semua',
            type: 99,
          ),
        );

        // _postpaidDenomMenuDepan.add(
        //   MenuModel(
        //     jenis: 99,
        //     icon: 'https://ayoba.co.id/dokumen/icon/lainnya.png',
        //     name: 'Lainnya',
        //     type: 99,
        //   ),
        // );

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
            builder: (_) => VoucherBulkPage(menu),
          ),
        );
      }
    } else if (menu.jenis == 99) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => MoreMenuScreen(_prepaidDenomMenu, 1)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return loadingMenuDepan();

    return Container(
      padding: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(color: Colors.white),
      child: Container(
        margin: EdgeInsets.only(
          left: 15.0,
          right: 15.0,
          bottom: 15.0,
        ),
        child: Column(
          children: [
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
                    double size = MediaQuery.of(context).size.width * .075;
                    return AnimatedOpacity(
                      opacity: 1.0,
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
                                  width: size * 1.35,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: 2),
                              Spacer(),
                              Text(
                                prepaidDenomMenuDepan.name,
                                style: TextStyle(
                                  fontSize: size * .35,
                                  color: Colors.grey.shade800,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.center,
                              ),
                              Spacer(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                    childAspectRatio: 1.20,
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
            // Container(
            //   padding: EdgeInsets.only(left: 1, top: 8, bottom: 15),
            //   child: Row(
            //     children: [
            //       Shimmer.fromColors(
            //         baseColor: Colors.grey.shade300,
            //         highlightColor: Colors.grey.shade200,
            //         child: Container(
            //           width: 65.0,
            //           height: 35.0,
            //           decoration: BoxDecoration(
            //             borderRadius: BorderRadius.circular(100),
            //             color: Colors.white,
            //           ),
            //           child: Container(),
            //         ),
            //       ),
            //       SizedBox(width: 10),
            //       Shimmer.fromColors(
            //         baseColor: Colors.grey.shade300,
            //         highlightColor: Colors.grey.shade200,
            //         child: Container(
            //           width: 65.0,
            //           height: 35.0,
            //           decoration: BoxDecoration(
            //             borderRadius: BorderRadius.circular(100),
            //             color: Colors.white,
            //           ),
            //           child: Container(),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            GridView.count(
              crossAxisCount: 5,
              crossAxisSpacing: 5,
              mainAxisSpacing: 10.0,
              shrinkWrap: true,
              children: List.generate(5 * 4, (i) {
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

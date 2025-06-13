// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/pgkreload/layout/more_menu.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/provider/api.dart';
import 'package:mobile/screen/detail-denom-postpaid/detail-postpaid.dart';
import 'package:mobile/screen/detail-denom/detail-denom.dart';
import 'package:mobile/screen/dynamic-prepaid/dynamic-denom.dart';
import 'package:mobile/Products/pgkreload/layout/components/list-sub-menu.dart';
import 'package:mobile/screen/pulsa/pulsa.dart';
import 'package:mobile/Products/pgkreload/layout/list_grid_menu.dart';
import 'package:shimmer/shimmer.dart';

class MenuComponent extends StatefulWidget {
  @override
  _MenuComponentState createState() => _MenuComponentState();
}

class _MenuComponentState extends State<MenuComponent> {
  List<MenuModel> _menu = [];
  List<MenuModel> _moreMenu = [];
  List<MenuModel> _gridMoreSubmenu = [];

  String _moreSubmenuTitle;

  bool loading = true;
  Set active = {0};

  @override
  void initState() {
    super.initState();
    menus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future menus() async {
    try {
      List<dynamic> datas = await api.get('/menu/1', cache: true);

      const gridMenu = 9;

      _menu.addAll(datas
          .sublist(0, gridMenu)
          .map((e) => MenuModel.fromJson(e))
          .toList());
      _moreMenu.addAll(datas
          .sublist(gridMenu, datas.length)
          .map((e) => MenuModel.fromJson(e))
          .toList());
      _menu.add(
        MenuModel(
          jenis: 99,
          icon: 'https://ayoba.co.id/dokumen/icon/lainnya.png',
          name: 'Lainnya',
          type: 99,
        ),
      );

      getMoreSubmenu(_moreMenu[0], setState);

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
    } else if (menu.jenis == 99) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => MoreMenuScreen()));
      // showModalBottomSheet(
      //   context: context,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.only(
      //       topLeft: Radius.circular(20.0),
      //       topRight: Radius.circular(20.0),
      //     ),
      //   ),
      //   isScrollControlled: true,
      //   builder: (context) => StatefulBuilder(
      //     builder: (context, setState) {
      //       return Container(
      //         height: MediaQuery.of(context).size.height * 0.65,
      //         decoration: BoxDecoration(
      //           color: Colors.grey[200],
      //           borderRadius: BorderRadius.all(
      //             Radius.circular(20),
      //           ),
      //         ),
      //         child: Column(
      //           children: [
      //             Container(
      //               margin: EdgeInsets.symmetric(vertical: 20),
      //               child: Text(
      //                 _moreSubmenuTitle,
      //                 style: TextStyle(fontWeight: FontWeight.bold),
      //               ),
      //             ),
      //             Expanded(
      //               child: Row(
      //                 children: [
      //                   Expanded(
      //                     flex: 1,
      //                     child: Container(
      //                       decoration: BoxDecoration(
      //                         color: Colors.white,
      //                         borderRadius: BorderRadius.only(
      //                           topLeft: Radius.circular(20),
      //                         ),
      //                       ),
      //                       child: Container(
      //                         padding:
      //                             const EdgeInsets.symmetric(horizontal: 8.0),
      //                         margin:
      //                             const EdgeInsets.symmetric(vertical: 10.0),
      //                         child: ListView.separated(
      //                             itemBuilder: (BuildContext context, index) {
      //                               MenuModel moreMenu = _moreMenu[index];
      //                               return InkWell(
      //                                 onTap: () {
      //                                   getMoreSubmenu(moreMenu, setState);
      //                                   setState(() {
      //                                     active.clear();
      //                                     active.add(index);
      //                                   });
      //                                 },
      //                                 child: Container(
      //                                   padding: EdgeInsets.all(10),
      //                                   child: Column(
      //                                     mainAxisAlignment:
      //                                         MainAxisAlignment.center,
      //                                     children: [
      //                                       active.contains(index)
      //                                           ? Container(
      //                                               child: CachedNetworkImage(
      //                                                 imageUrl: moreMenu.icon,
      //                                                 width: 40.0,
      //                                                 fit: BoxFit.cover,
      //                                               ),
      //                                             )
      //                                           : Container(
      //                                               foregroundDecoration:
      //                                                   BoxDecoration(
      //                                                 color: Colors.grey,
      //                                                 backgroundBlendMode:
      //                                                     BlendMode.saturation,
      //                                               ),
      //                                               child: CachedNetworkImage(
      //                                                 imageUrl: moreMenu.icon,
      //                                                 width: 40.0,
      //                                                 fit: BoxFit.cover,
      //                                               ),
      //                                             ),
      //                                       SizedBox(height: 8),
      //                                       Text(
      //                                         moreMenu.name,
      //                                         style: TextStyle(
      //                                           fontSize: 10,
      //                                           color: active.contains(index)
      //                                               ? Colors.grey.shade800
      //                                               : Colors.grey.shade600,
      //                                           fontWeight: FontWeight.bold,
      //                                         ),
      //                                         softWrap: true,
      //                                         textAlign: TextAlign.center,
      //                                       ),
      //                                     ],
      //                                   ),
      //                                 ),
      //                               );
      //                             },
      //                             separatorBuilder: (BuildContext context, _) =>
      //                                 SizedBox(),
      //                             itemCount: _moreMenu.length),
      //                       ),
      //                     ),
      //                   ),
      //                   SizedBox(width: 2),
      //                   Expanded(
      //                     flex: 3,
      //                     child: Container(
      //                         height: double.infinity,
      //                         color: Colors.white,
      //                         child: ListView(
      //                           children: [
      //                             GridView.builder(
      //                               shrinkWrap: true,
      //                               physics: NeverScrollableScrollPhysics(),
      //                               padding: EdgeInsets.symmetric(
      //                                   horizontal: 5, vertical: 13),
      //                               itemCount: _gridMoreSubmenu.length,
      //                               itemBuilder: (_, int index) {
      //                                 if (_gridMoreSubmenu.length == 0)
      //                                   return SizedBox();
      //                                 MenuModel gridMoreSubmenu =
      //                                     _gridMoreSubmenu[index];
      //                                 return Container(
      //                                   padding: EdgeInsets.all(5),
      //                                   child: InkWell(
      //                                     onTap: () =>
      //                                         handleTapMenu(gridMoreSubmenu),
      //                                     child: Column(
      //                                       mainAxisAlignment:
      //                                           MainAxisAlignment.start,
      //                                       crossAxisAlignment:
      //                                           CrossAxisAlignment.center,
      //                                       children: <Widget>[
      //                                         CircleAvatar(
      //                                           foregroundColor: Theme.of(context).primaryColor,
      //                                           backgroundColor: Theme.of(context)
      //                                               .primaryColor
      //                                               .withOpacity(.1),
      //                                           child: Padding(
      //                                             padding: const EdgeInsets.all(2),
      //                                             child: CachedNetworkImage(
      //                                               imageUrl:
      //                                                   gridMoreSubmenu.icon,
      //                                               width: double.infinity,
      //                                               fit: BoxFit.cover,
      //                                             ),
      //                                           ),
      //                                         ),
      //                                         SizedBox(height: 10),
      //                                         Flexible(
      //                                           child: Text(
      //                                             gridMoreSubmenu.name,
      //                                             style: TextStyle(
      //                                               fontSize: 9,
      //                                               color: Colors.grey.shade800,
      //                                             ),
      //                                             softWrap: true,
      //                                             textAlign: TextAlign.center,
      //                                           ),
      //                                         ),
      //                                       ],
      //                                     ),
      //                                   ),
      //                                 );
      //                               },
      //                               gridDelegate:
      //                                   SliverGridDelegateWithFixedCrossAxisCount(
      //                                 crossAxisCount: 4,
      //                                 childAspectRatio: .80,
      //                               ),
      //                             ),
      //                           ],
      //                         )),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           ],
      //         ),
      //       );
      //     },
      //   ),
      // );
    }
  }

  void getMoreSubmenu(
      MenuModel currentMenu, void Function(void Function()) setState) async {
    setState(() {
      loading = true;
      _moreSubmenuTitle = currentMenu.name;
    });

    List<dynamic> datas =
        await api.get('/menu/${currentMenu.id}/child', cache: true);

    _gridMoreSubmenu = datas.map((e) => MenuModel.fromJson(e)).toList();

    setState(() {
      loading = false;
    });
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

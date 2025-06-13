// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:mobile/Products/payuniblibli/layout/transaksi/postpaid.dart';
import 'package:mobile/Products/payuniblibli/layout/transaksi/prepaid.dart';
import 'package:mobile/component/menudepan-loading.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/provider/api.dart';
import 'package:mobile/screen/home/more/more.dart';
import 'package:mobile/screen/list-grid-menu/list-grid-menu.dart';
import 'package:mobile/Products/payuniblibli/layout/list_sub_menu.dart';
import 'package:mobile/Products/payuniblibli/layout/transaksi/pulsa.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as SlideDialog;

class MenuComponent extends StatefulWidget {
  @override
  _MenuComponentState createState() => _MenuComponentState();
}

class _MenuComponentState extends State<MenuComponent> {
  ScrollController _scrollController = ScrollController();
  List<MenuModel> _menuMore = [];
  double _scrollPercentage = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollPercentage = (_scrollController.offset /
                _scrollController.position.maxScrollExtent) *
            100;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<MenuModel>> menus() async {
    List<MenuModel> items = [];
    List<dynamic> datas = await api.get('/menu/1', cache: true);

    items.add(
      MenuModel(
        jenis: 99,
        icon: 'https://pdpay.id/images/refisi/more.png',
        name: 'Lainnya',
        type: 99,
      ),
    );
    items.addAll(
        datas.sublist(0, 19).map((e) => MenuModel.fromJson(e)).toList());
    _menuMore = datas
        .sublist(19, datas.length)
        .map((e) => MenuModel.fromJson(e))
        .toList();

    return items;
  }

  onTapMenu(MenuModel menu) {
    if (menu.jenis == 1) {
      return Navigator.of(context).push(MaterialPageRoute(builder: (_) {
        return PulsaPage(menu);
      }));
    } else if (menu.jenis == 2) {
      if (menu.category_id.isNotEmpty && menu.type == 1) {
        return Navigator.of(context).push(PageTransition(
            child: PrepaidPage(menu), type: PageTransitionType.rippleRightUp));
        /*
        LANGSUNG KE DETAIL DENOM
        */
      } else if (menu.kodeProduk.isNotEmpty && menu.type == 2) {
        return Navigator.of(context).push(PageTransition(
            child: PostpaidPage(menu), type: PageTransitionType.rippleRightUp));
        /*
        LANGSUNG KE DETAIL DENOM POSTPAID
        */
      } else if (menu.category_id.isEmpty) {
        return Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => ListSubMenu(menu)));
      }
    } else if (menu.jenis == 4) {
      print('REDIRECT KE HALAMAN LIST GRID');
      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ListGridMenu(menu),
        ),
      );
    } else if (menu.jenis == 99) {
      showMoreMenu();
    }
  }

  void showMoreMenu() {
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
                  itemCount: _menuMore.length,
                  itemBuilder: (_, i) {
                    MenuModel menu = _menuMore.elementAt(i);
                    return Container(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          onTapMenu(menu);
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
                                          .primaryColor
                                          .withOpacity(.1),
                                      Theme.of(context)
                                          .primaryColor
                                          .withOpacity(.0),
                                      Theme.of(context)
                                          .primaryColor
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
    return FutureBuilder<List<MenuModel>>(
      future: menus(),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) return LoadingMenuDepan(5, baris: 2);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 150,
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: GridView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                itemCount: snapshot.data.length,
                itemBuilder: (_, int index) {
                  MenuModel menu = snapshot.data[index];
                  return Container(
                    child: InkWell(
                      onTap: () => onTapMenu(menu),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  offset: Offset(0, 0),
                                  blurRadius: 3,
                                ),
                              ],
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
                                fontSize: 10.0,
                                color: Colors.grey.shade500,
                                // fontWeight: FontWeight.bold,
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
                  crossAxisCount: 2,
                  crossAxisSpacing: 5,
                  childAspectRatio: .95,
                ),
              ),
            ),
            Container(
              width: 50,
              height: 5,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.5),
              ),
              child: Container(
                width: 20,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(2.5),
                ),
                transform: Matrix4.translationValues(
                    (_scrollPercentage / 100) * 30, 0, 0),
              ),
            ),
          ],
        );
      },
    );
  }
}

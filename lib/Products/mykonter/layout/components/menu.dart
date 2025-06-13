import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/mykonter/layout/menu/pdam.dart';
import 'package:mobile/Products/mykonter/layout/menu/prepaid.dart';
import 'package:mobile/Products/mykonter/layout/menu/pulsa_menu.dart';
import 'package:mobile/Products/mykonter/layout/menu/postpaid_detail.dart';
import 'package:mobile/Products/mykonter/layout/menu/submenu_prepaid.dart';
import 'package:mobile/component/menudepan-loading.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/provider/api.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as SlideDialog;

class MenuComponent extends StatefulWidget {
  @override
  _MenuComponentState createState() => _MenuComponentState();
}

class _MenuComponentState extends State<MenuComponent> {
  bool _loading = true;
  List<MenuModel> _menu = [];
  List<MenuModel> _menuMore = [];

  @override
  void initState() {
    super.initState();
    getMenu();
  }

  Future<void> getMenu() async {
    List<dynamic> datas = await api.get('/menu/1', cache: true);

    _menu = datas.sublist(0, 7).map((e) => MenuModel.fromJson(e)).toList();
    _menu.add(
      MenuModel(
        jenis: 99,
        icon: 'https://mykonter.id/images/icon/lainnya.png',
        name: 'Lainnya',
        type: 99,
      ),
    );
    _menuMore = datas
        .sublist(7, datas.length)
        .map((e) => MenuModel.fromJson(e))
        .toList();

    setState(() {
      _loading = false;
    });
  }

  onTapMenu(MenuModel menu) {
    if (menu.name.toLowerCase().contains('pdam')) {
      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PdamPage(menu),
        ),
      );
    }

    if (menu.jenis == 1) {
      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PulsaMenu(),
        ),
      );
    } else if (menu.jenis == 2) {
      if (menu.category_id.isNotEmpty && menu.type == 1) {
        return Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PrepaidPage(menu),
          ),
        );
      } else if (menu.kodeProduk.isNotEmpty && menu.type == 2) {
        return Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PostpaidDetailPage(menu),
          ),
        );
      } else if (menu.category_id.isEmpty) {
        return Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SubmenuPrepaid(menu),
          ),
        );
      }
    } else if (menu.jenis == 99) {
      showMoreMenu(_menuMore);
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
    return _loading
        ? LoadingMenuDepan(4, baris: 2)
        : Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(0),
              itemCount: _menu.length,
              itemBuilder: (_, int index) {
                MenuModel menu = _menu.elementAt(index);

                return Container(
                  child: InkWell(
                    onTap: () => onTapMenu(menu),
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
                                  Theme.of(context).primaryColor.withOpacity(.1)
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
          );
  }
}

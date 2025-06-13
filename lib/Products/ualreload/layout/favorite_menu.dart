// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/models/menu.dart';

class FavoriteMenu extends StatefulWidget {
  final favoriteMenu;
  final int type;

  const FavoriteMenu(this.favoriteMenu, this.type, {Key key}) : super(key: key);

  @override
  State<FavoriteMenu> createState() => _FavoriteMenuState();
}

class _FavoriteMenuState extends State<FavoriteMenu> {
  String hiveBox = '';

  @override
  void initState() {
    switch (widget.type) {
      case 1:
        hiveBox = 'favorite-menu-choice';
        break;
      case 2:
        hiveBox = 'favorite-menu-postpaid';
        break;
      default:
        hiveBox = 'favorite-menu-choice';
    }

    super.initState();
  }

  void addFavoriteMenu(MenuModel menu) {
    bool isExists = false;

    Hive.box(hiveBox).values.forEach((el) {
      MenuModel favoriteMenu = MenuModel.parse(el);

      if (favoriteMenu.id == menu.id) {
        isExists = true;
        String message = '${favoriteMenu.name} sudah pernah ditambahkan';
        final snackBar = SnackBar(content: Text(message));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      }
    });

    if (!isExists) {
      Hive.box(hiveBox).add(MenuModel.create(menu: menu).toMap()).then((value) {
        String message = '${menu.name} berhasil ditambahkan';
        final snackBar = SnackBar(content: Text(message));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }).catchError((err) {
        String message = 'Gagal menambahkan ${menu.name}';
        final snackBar = SnackBar(content: Text(message));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        print('ADD FAVORITE MENU ERROR: ${err.toString()}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Tambah Menu Favorit', style: TextStyle(fontSize: 18)),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              splashRadius: 20.0,
              icon: SvgPicture.asset(
                "assets/img/payuni2/home2.svg",
                color: Colors.white,
                height: 25.0,
                width: 25.0,
              ),
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) =>
                        configAppBloc.layoutApp?.valueWrapper?.value['home'] ??
                        templateConfig[
                            configAppBloc.templateCode.valueWrapper?.value],
                  ),
                  (route) => false),
            ),
          ),
        ],
      ),
      body: widget.favoriteMenu.length == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/img/no_data.svg',
                      width: MediaQuery.of(context).size.width * .5),
                  SizedBox(height: 30),
                  Text('Data Menu Tidak Ditemukan')
                ],
              ),
            )
          : Container(
              padding: EdgeInsets.symmetric(vertical: 25, horizontal: 5),
              child: GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.all(0),
                itemCount: widget.favoriteMenu.length,
                itemBuilder: (ctx, i) {
                  MenuModel menu = widget.favoriteMenu[i];
                  return Container(
                    child: InkWell(
                      onTap: () => addFavoriteMenu(menu),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
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
                                fit: BoxFit.cover),
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
                  crossAxisCount: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: .95,
                ),
              ),
            ),
    );
  }
}

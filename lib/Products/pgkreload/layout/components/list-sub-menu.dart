// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/provider/analitycs.dart';

import 'package:mobile/Products/pgkreload/layout/components/list-sub-menu-controller.dart';

class ListSubMenu extends StatefulWidget {
  final MenuModel menuModel;

  ListSubMenu(this.menuModel);

  @override
  _ListSubMenuState createState() => _ListSubMenuState();
}

class _ListSubMenuState extends ListSubMenuController {
  @override
  void initState() {
    super.initState();
    analitycs.pageView('/list/submenu', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'List Sub Menu',
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> pkgName = [
      'com.funmo.id',
    ];

    pkgName.forEach((element) {
      if (element == packageName) {
        setState(() {
          isProductIconMenu = true;
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(currentMenu.name),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.home_rounded),
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) =>
                      configAppBloc.layoutApp?.valueWrapper?.value['home'] ??
                      templateConfig[
                          configAppBloc.templateCode.valueWrapper?.value],
                ),
                (route) => false),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * .2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).canvasColor
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: packageName == 'com.eazyin.mobile'
                  ? Center(
                      child: CachedNetworkImage(
                        imageUrl: configAppBloc
                            .iconApp.valueWrapper?.value['logoLogin'],
                        width: MediaQuery.of(context).size.width * .4,
                      ),
                    )
                  : null,
            ),
            currentMenu.type == 2
                ? Container(
                    padding: EdgeInsets.all(20),
                    child: TextFormField(
                      controller: query,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Cari disini...',
                          isDense: true,
                          suffixIcon: InkWell(
                              child: Icon(Icons.search),
                              onTap: () {
                                List<MenuModel> list = tempMenu
                                    .where((menu) => menu.name
                                        .toLowerCase()
                                        .contains(query.text))
                                    .toList();
                                setState(() {
                                  listMenu = list;
                                });
                              })),
                      onEditingComplete: () {
                        List<MenuModel> list = tempMenu
                            .where((menu) =>
                                menu.name.toLowerCase().contains(query.text))
                            .toList();
                        setState(() {
                          listMenu = list;
                        });
                      },
                      onChanged: (value) {
                        if (value.isEmpty) {
                          setState(() {
                            listMenu = tempMenu;
                          });
                        }
                      },
                    ))
                : Container(),
            Flexible(
              flex: 1,
              child: loading
                  ? Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Center(
                        child: SpinKitThreeBounce(
                          color: Theme.of(context).primaryColor,
                          size: 35,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.all(20),
                      itemCount: listMenu.length,
                      separatorBuilder: (_, i) => SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        MenuModel menu = listMenu[i];
                        return InkWell(
                          onTap: () => onTapMenu(menu),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(.1),
                                      offset: Offset(5, 10.0),
                                      blurRadius: 20)
                                ]),
                            child: ListTile(
                              leading: CircleAvatar(
                                foregroundColor: Theme.of(context).primaryColor,
                                backgroundColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(.1),
                                child: menu.icon != ''
                                        ? Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            padding: EdgeInsets.all(2),
                                            child: CachedNetworkImage(
                                              imageUrl: menu.icon,
                                            ),
                                          )
                                        : Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        padding: EdgeInsets.all(2),
                                        child: CachedNetworkImage(
                                          imageUrl: currentMenu.icon,
                                        ),
                                      ),
                              ),
                              title: Text(
                                menu.name,
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              subtitle: Text(
                                menu.description ?? ' ',
                                style: TextStyle(
                                  fontSize: 10.0,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}

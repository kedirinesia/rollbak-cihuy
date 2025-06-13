// @dart=2.9

import 'package:flutter/material.dart';

// INSTALL PACKAGE
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/config.dart';

// MODEL
import 'package:mobile/models/menu.dart';
import 'package:mobile/provider/analitycs.dart';

// CONTROLLER
import 'list-grid-menu-controller.dart';

class ListGridMenu extends StatefulWidget {
  final MenuModel menuModel;

  ListGridMenu(this.menuModel);

  @override
  _ListGridMenuState createState() => _ListGridMenuState();
}

class _ListGridMenuState extends ListGridMenuController {
  @override
  void initState() {
    super.initState();
    analitycs.pageView('/list-grid/menu', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'List Grid Menu',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        title: Text(currentMenu.name),
        centerTitle: true,
        elevation: 0,
        backgroundColor: packageName == 'com.lariz.mobile'
            ? Theme.of(context).secondaryHeaderColor
            : Theme.of(context).primaryColor,
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
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              packageName == 'com.lariz.mobile'
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).primaryColor,
              packageName == 'com.lariz.mobile'
                  ? Theme.of(context).secondaryHeaderColor.withOpacity(.1)
                  : Theme.of(context).primaryColor.withOpacity(.1),
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
          loading
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: SpinKitThreeBounce(
                        color: packageName == 'com.lariz.mobile'
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).primaryColor,
                        size: 35),
                  ),
                )
              : Container(
                  margin: EdgeInsets.only(top: 15.0),
                  padding: EdgeInsets.all(20.0),
                  child: GridView.builder(
                      shrinkWrap: true,
                      primary: false,
                      physics: BouncingScrollPhysics(),
                      itemCount: listMenu.length,
                      itemBuilder: (_, int index) {
                        MenuModel menu = listMenu[index];
                        return _buildBox(menu);
                      },
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.8,
                          mainAxisSpacing: 10.0)),
                ),
        ],
      ),
    );
  }

  Widget _buildBox(MenuModel menu) {
    return Container(
      child: InkWell(
        onTap: () => onTapMenu(menu),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Hero(
                tag: 'image-icon-' + menu.id,
                child:
                    CachedNetworkImage(imageUrl: menu.icon, fit: BoxFit.cover),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: EdgeInsets.all(16.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: Text(
                  menu.name,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

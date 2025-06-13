// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/detail-denom-postpaid/detail-postpaid.dart';
import 'package:mobile/screen/detail-denom/detail-denom-grid.dart';
import 'package:mobile/screen/transaksi/voucher_bulk.dart';

class ListGridMenu extends StatefulWidget {
  final MenuModel menuModel;

  const ListGridMenu(this.menuModel);

  @override
  _ListGridMenuState createState() => _ListGridMenuState();
}

class _ListGridMenuState extends State<ListGridMenu>
    with TickerProviderStateMixin {
  bool loading = true;
  MenuModel currentMenu;
  List<MenuModel> listMenu = [];
  List<MenuModel> tempMenu = [];
  TextEditingController query = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentMenu = widget.menuModel;
    analitycs.pageView('/list-grid/menu', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'List Grid Menu',
    });
    analitycs.pageView('/menu/' + currentMenu.id, {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Buka Menu ' + currentMenu.name
    });
    getData();
  }

  getData() async {
    setState(() {
      loading = true;
    });

    http.Response response = await http.get(
        Uri.parse('$apiUrl/menu/${currentMenu.id}/child'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<MenuModel> lm = (jsonDecode(response.body)['data'] as List)
          .map((m) => MenuModel.fromJson(m))
          .toList();
      tempMenu = lm;
      listMenu = lm;
    } else {
      listMenu = [];
    }

    setState(() {
      loading = false;
    });
  }

  onTapMenu(MenuModel menu) async {
    if (menu.category_id.isNotEmpty && menu.type == 1) {
      if (menu.jenis == 5 || menu.jenis == 6) {
        return Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VoucherBulkPage(menu),
          ),
        );
      } else {
        return Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailDenomGrid(menu),
          ),
        );
      }
    } else if (menu.kodeProduk.isNotEmpty && menu.type == 2) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => DetailDenomPostpaid(menu)));
    } else if (menu.category_id.isEmpty) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => ListGridMenu(menu)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        title: Text(currentMenu.name),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          splashRadius: 20.0,
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            // color: Theme.of(context).primaryColor,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.4)
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
          loading
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: SpinKitThreeBounce(color: Colors.white, size: 35),
                  ),
                )
              : Container(
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
                        mainAxisSpacing: 10.0),
                  ),
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
                  maxLines: 2,
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

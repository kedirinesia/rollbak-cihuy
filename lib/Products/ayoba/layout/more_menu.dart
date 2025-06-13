// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:mobile/Products/ayoba/layout/list_grid_menu.dart';
import 'package:mobile/Products/ayoba/layout/favorite_menu.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/provider/api.dart';
import 'package:mobile/screen/detail-denom-postpaid/detail-postpaid.dart';
import 'package:mobile/screen/detail-denom/detail-denom.dart';
import 'package:mobile/screen/dynamic-prepaid/dynamic-denom.dart';
import 'package:mobile/Products/ayoba/layout/components/list-sub-menu.dart';
import 'package:mobile/screen/pulsa/pulsa.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile/screen/transaksi/voucher_bulk.dart';

class MoreMenuScreen extends StatefulWidget {
  List<MenuModel> _moreMenu;
  int type;

  MoreMenuScreen(this._moreMenu, this.type);

  @override
  _MoreMenuScreenState createState() => _MoreMenuScreenState();
}

class _MoreMenuScreenState extends State<MoreMenuScreen>
    with TickerProviderStateMixin {
  // List<MenuModel> _moreMenu = [];

  bool loading = false;

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // getMenus();
  }

  // Future getMenus() async {
  //   setState(() {
  //     loading = true;
  //   });

  //   List<dynamic> datas = await api.get('/menu/1', cache: true);

  //   _moreMenu = datas.map((e) => MenuModel.fromJson(e)).toList();

  //   await Future.delayed(Duration(milliseconds: 500));

  //   setState(() {
  //     loading = false;
  //   });
  // }

  onTapMenu(MenuModel menu) {
    if (menu.jenis == 1) {
      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => Pulsa(menu),
        ),
      );
    } else if (menu.jenis == 2) {
      if (menu.category_id.isNotEmpty && menu.type == 1) {
        return Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailDenom(menu),
          ),
        );
        /*
        LANGSUNG KE DETAIL DENOM
        */
      } else if (menu.kodeProduk.isNotEmpty && menu.type == 2) {
        return Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailDenomPostpaid(menu),
          ),
        );
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
      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VoucherBulkPage(menu),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String hiveBox = '';

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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Lainnya',
            style: TextStyle(color: Colors.black, fontSize: 18)),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: [
            Container(
              child: Tab(
                text: 'Kategori',
              ),
            ),
            Container(
              child: Tab(
                text: 'Favorit',
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
            onRefresh: () async {
              // getMenus();
              setState(() {});
            },
            child: loading
                ? Container(
                    child: Center(
                      child: SpinKitRing(
                        color: Theme.of(context).primaryColor,
                        size: 40,
                        lineWidth: 4.0,
                      ),
                    ),
                  )
                : widget._moreMenu.length == 0
                    ? Center(
                        child: Text(
                          'Data tidak ditemukan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        shrinkWrap: true,
                        primary: false,
                        physics: BouncingScrollPhysics(),
                        itemCount: widget._moreMenu.length,
                        itemBuilder: (BuildContext context, int index) {
                          MenuModel moreMenu = widget._moreMenu[index];
                          return InkWell(
                            onTap: () => onTapMenu(moreMenu),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 9),
                              child: Row(
                                children: [
                                  Container(
                                    width: 43,
                                    height: 43,
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
                                        ],
                                      ),
                                    ),
                                    padding: EdgeInsets.all(8.0),
                                    child: CachedNetworkImage(
                                        imageUrl: moreMenu.icon,
                                        width: 40.0,
                                        fit: BoxFit.cover),
                                  ),
                                  SizedBox(width: 18),
                                  Expanded(
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 20.5),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            width: 1.0,
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            moreMenu.name,
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 6.0),
                                            child: Icon(
                                              Icons.keyboard_arrow_right,
                                              size: 25.0,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Scaffold(
            body: ValueListenableBuilder(
              valueListenable: Hive.box(hiveBox).listenable(),
              builder: (BuildContext context, dynamic value, Widget child) {
                if (value.length == 0) return Container();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  itemCount: value.length,
                  itemBuilder: (BuildContext context, int i) {
                    MenuModel favoriteMenu = MenuModel.parse(value.getAt(i));
                    return Dismissible(
                      key: UniqueKey(),
                      background: Container(
                        decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(.1)),
                      ),
                      confirmDismiss: (direction) async {
                        bool status = await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) => AlertDialog(
                                    title: Text('Hapus Menu Favorit',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .primaryColor)),
                                    content: Text(
                                        'Anda yakin ingin menghapus ${favoriteMenu.name} ?',
                                        textAlign: TextAlign.justify),
                                    actions: [
                                      TextButton(
                                          child: Text(
                                            'BATAL',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(false)),
                                      TextButton(
                                          child: Text(
                                            'HAPUS',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(true)),
                                    ]));
                        return status ?? false;
                      },
                      onDismissed: (direction) async {
                        await Hive.box('favorite-menu').deleteAt(i);
                      },
                      child: InkWell(
                        onTap: () => onTapMenu(favoriteMenu),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 9),
                          child: Row(
                            children: [
                              Container(
                                width: 43,
                                height: 43,
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
                                    ],
                                  ),
                                ),
                                padding: EdgeInsets.all(8.0),
                                child: CachedNetworkImage(
                                    imageUrl: favoriteMenu.icon,
                                    width: 40.0,
                                    fit: BoxFit.cover),
                              ),
                              SizedBox(width: 18),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 20.5),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 1.0,
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        favoriteMenu.name,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 6.0),
                                        child: Icon(
                                          Icons.keyboard_arrow_right,
                                          size: 25.0,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.of(context).push(PageTransition(
                    child: FavoriteMenu(widget._moreMenu, widget.type),
                    type: PageTransitionType.rippleRightUp));
              },
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

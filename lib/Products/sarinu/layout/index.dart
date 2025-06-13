// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/Products/sarinu/layout/home.dart';
import 'package:mobile/Products/sarinu/layout/profile.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/component/webview.dart';
import 'package:mobile/screen/history/history.dart';
import 'package:mobile/screen/marketplace/index.dart';
import 'package:mobile/screen/profile/downline/downline.dart';

class SarinuHome extends StatefulWidget {
  @override
  _SarinuHomeState createState() => _SarinuHomeState();
}

class _SarinuHomeState extends State<SarinuHome>
    with SingleTickerProviderStateMixin {
  Color mainColor = Colors.white;
  Color mainTextColor = Colors.blue;

  List<Widget> halaman = [
    Home1App(),
    HistoryPage(),
    Downline(),
    ProfileSarinu()
  ];
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    changePrimaryColor();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void changePrimaryColor() {
    if (mounted) {
      setState(() {
        mainTextColor = Colors.purple;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(Icons.shopping_cart_rounded),
          elevation: 0.0,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MarketPage(),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.color,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(configAppBloc.namaApp.valueWrapper?.value),
              Text(configAppBloc.labelPoint.valueWrapper?.value +
                  ' ' +
                  NumberFormat.decimalPattern('id')
                      .format(bloc.poin.valueWrapper?.value))
            ],
          ),
          elevation: 0,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.chat, color: Colors.white),
                onPressed: () {
                  if (configAppBloc.liveChat.valueWrapper?.value != '') {
                    return Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Webview('Live Chat Support',
                            configAppBloc.liveChat.valueWrapper?.value)));
                  } else {
                    return null;
                  }
                }),
            IconButton(
                icon: Icon(Icons.notifications_active, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pushNamed('/notifikasi');
                }),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          notchMargin: 5.0,
          color: Colors.white,
          shape: CircularNotchedRectangle(),
          child: Container(
            height: 50.0,
            padding: EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        pageIndex = 0;
                      });
                    },
                    child: Column(
                      children: <Widget>[
                        CachedNetworkImage(
                            imageUrl:
                                'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2FPakeAja%2Fdashboard.png?alt=media&token=0794cc0a-16ef-48f8-8625-17d450c61680',
                            color: pageIndex == 0
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                            width: 20.0),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text('Home', style: TextStyle(fontSize: 10.0))
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 20.0),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        pageIndex = 1;
                      });
                    },
                    child: Column(
                      children: <Widget>[
                        CachedNetworkImage(
                            imageUrl:
                                'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2FPakeAja%2Fhistory.png?alt=media&token=6047695d-e0d8-4fdf-b59d-ba7c21c70ab0',
                            color: pageIndex == 1
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                            width: 20.0),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text('History', style: TextStyle(fontSize: 10.0))
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 80.0),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        pageIndex = 2;
                      });
                    },
                    child: Column(
                      children: <Widget>[
                        CachedNetworkImage(
                            imageUrl:
                                'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2FPakeAja%2Ffriendship.png?alt=media&token=f8d24fd1-7e7b-4cbd-8dbf-5b382fc2a825',
                            color: pageIndex == 2
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                            width: 20.0),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text('Keagenan', style: TextStyle(fontSize: 10.0))
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 20.0),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        pageIndex = 3;
                      });
                    },
                    child: Column(
                      children: <Widget>[
                        CachedNetworkImage(
                            imageUrl:
                                'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2FPakeAja%2Fyoung.png?alt=media&token=1c94548d-8480-4530-add4-58b90522e4a8',
                            color: pageIndex == 3
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                            width: 20.0),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text('Profile', style: TextStyle(fontSize: 10.0))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // bottomNavigationBar: FancyBottomNavigation(
        //     tabs: [
        //       TabData(iconData: Icons.apps, title: 'Home'),
        //       TabData(iconData: Icons.sort, title: 'History'),
        //       TabData(iconData: Icons.verified_user, title: 'Profile')
        //     ],
        //     onTabChangedListener: (position) {
        //       setState(() {
        //         pageIndex = position;
        //       });
        //     }),
        body: halaman[pageIndex]);
  }
}

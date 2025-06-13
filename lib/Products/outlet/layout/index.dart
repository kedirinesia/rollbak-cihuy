// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/eazyin/layout/index.dart';
import 'package:mobile/Products/outlet/layout/home.dart';
import 'package:mobile/Products/outlet/layout/history.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/Products/outlet/layout/notifikasi/notifikasi.dart';
import 'package:mobile/Products/outlet/layout/profile.dart';
import 'package:mobile/screen/cs.dart';

class EpulsaHome extends StatefulWidget {
  @override
  _EpulsaHomeState createState() => _EpulsaHomeState();
}

class _EpulsaHomeState extends State<EpulsaHome> with TickerProviderStateMixin {
  Color mainColor = Colors.white;
  Color mainTextColor = Colors.blue;
  AnimationController _animationController;

  List<Widget> halaman = [
    Home4App(),
    HistoryPage(),
    Notifikasi(),
    ProfilePage()
  ];
  int pageIndex = 0;

  @override
  void initState() {
    _animationController =
        AnimationController(duration: Duration(seconds: 3), vsync: this);
    super.initState();

    bloc.mainColor
      ..listen((Color color) {
        setState(() {
          mainColor = color;
        });
      });
    bloc.mainTextColor
      ..listen((Color color) {
        setState(() {
          mainTextColor = color;
        });
      });

    changePrimaryColor();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
        child: Icon(Icons.group_rounded),
        elevation: 0.0,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DownlinePage(),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        title: Text(
          bloc.user.valueWrapper?.value.namaToko,
          style: TextStyle(
              fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // title: configAppBloc.iconApp.valueWrapper?.value != null
        //     ? Image.asset(
        //         'assets/img/outletpay/outletpay_logo.png',
        //         height: 25,
        //       )
        //     : Text(configAppBloc.namaApp.valueWrapper?.value),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.0,
        actions: [
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CS1(),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Hubungi',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Kami',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 7),
                  Icon(Icons.support_agent_rounded),
                ],
              ),
            ),
          ),
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
                              'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fepulsa%2Fhistory_inactive.png?alt=media&token=2b5c6539-d5e2-41d1-8915-a010e012b94a',
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
                              'https://dokumen.payuni.co.id/logo/outlet/notifikasi.png',
                          color: pageIndex == 2
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                          width: 20.0),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text('Info', style: TextStyle(fontSize: 10.0))
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
      body: halaman[pageIndex],
    );
  }
}

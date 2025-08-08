// @dart=2.9

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/Products/violeta/layout/profile.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/component/webview.dart';
import 'package:mobile/screen/history/history.dart';
import 'package:mobile/screen/profile/profile.dart';

import './home3.dart';

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  Color mainColor = Colors.white;
  Color mainTextColor = Colors.blue;

  List<Widget> halaman =
      configAppBloc.packagename.valueWrapper.value == 'id.violetapedia.mobile'
          ? [Home3App(), HistoryPage(), ProfilePageVioleta()]
          : [Home3App(), HistoryPage(), ProfilePage()];
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();

    // Set system UI overlay style untuk Android SDK 35
    // Menggunakan addPostFrameCallback untuk memastikan context tersedia
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Theme.of(context).primaryColor,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarDividerColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
        );
      }
    });

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
    // Hitung padding yang diperlukan untuk system navigation
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final systemNavHeight = bottomPadding > 0 ? bottomPadding : 0.0;
    
    return Scaffold(
        backgroundColor: Colors.white,
        extendBody: true, // Extend body behind bottom navigation
        appBar: AppBar(
          title: Text(configAppBloc.namaApp.valueWrapper?.value,
              style: TextStyle(color: Colors.white)),
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0.0,
          actions: <Widget>[
            configAppBloc.liveChat.valueWrapper?.value != ''
                ? IconButton(
                    icon: Icon(Icons.chat, color: Colors.white),
                    onPressed: () {
                      if (configAppBloc.liveChat.valueWrapper?.value != '') {
                        return Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Webview('Live Chat Support',
                                configAppBloc.liveChat.valueWrapper?.value)));
                      } else {
                        return null;
                      }
                    })
                : Container(),
            IconButton(
              color: Colors.white,
              icon: Icon(Icons.notifications),
              onPressed: () {
                Navigator.of(context).pushNamed('/notifikasi');
              },
            )
          ],
        ),
        bottomNavigationBar: Container(
          // Tambahkan padding yang cukup untuk menghindari system navigation
          padding: EdgeInsets.only(
            bottom: systemNavHeight + 8.0, // Extra 8px untuk safety
          ),
          child: CurvedNavigationBar(
            color: Theme.of(context).primaryColor,
            backgroundColor: Colors.white.withOpacity(.1),
            animationCurve: Curves.fastOutSlowIn,
            buttonBackgroundColor: Theme.of(context).primaryColor,
            height: 60.0, // Fixed height untuk konsistensi
            items: <Widget>[
              Icon(Icons.apps, size: 30, color: Colors.white),
              Icon(Icons.list, size: 30, color: Colors.white),
              Icon(Icons.person, size: 30, color: Colors.white),
            ],
            onTap: (index) {
              //Handle button tap
              setState(() {
                pageIndex = index;
              });
            },
          ),
        ),
        body: SafeArea(
          bottom: false, // Tidak perlu SafeArea untuk bottom karena sudah ditangani
          child: Container(
            // Tambahkan padding bottom untuk memastikan konten tidak tertutup
            padding: EdgeInsets.only(
              bottom: systemNavHeight > 0 ? systemNavHeight + 80.0 : 80.0, // Extra space untuk bottom nav + safety
            ),
            child: halaman[pageIndex],
          ),
        ));
  }
}

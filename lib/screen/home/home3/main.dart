// @dart=2.9

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
        backgroundColor: Colors.white,
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
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // CurvedNavigationBar yang asli (tidak diubah)
            CurvedNavigationBar(
              color: Theme.of(context).primaryColor,
              backgroundColor: Colors.white.withOpacity(.1),
              animationCurve: Curves.fastOutSlowIn,
              buttonBackgroundColor: Theme.of(context).primaryColor,
              items: <Widget>[
                Icon(Icons.apps, size: configAppBloc.packagename.valueWrapper?.value == 'com.flobamora.app' ? 35 : 30, color: Colors.white),
                Icon(Icons.list, size: configAppBloc.packagename.valueWrapper?.value == 'com.flobamora.app' ? 35 : 30, color: Colors.white),
                Icon(Icons.person, size: configAppBloc.packagename.valueWrapper?.value == 'com.flobamora.app' ? 35 : 30, color: Colors.white),
              ],
              onTap: (index) {
                //Handle button tap
                setState(() {
                  pageIndex = index;
                });
              },
            ),
                         // Shape tambahan di bawah bottom navigation bar (hanya untuk Flobamora)
             if (configAppBloc.packagename.valueWrapper?.value == 'com.flobamora.app')
               Container(
                 height: 50.0, // Tinggi tambahan
                 width: double.infinity, // Full layar dari kiri ke kanan
                 decoration: BoxDecoration(
                   color: Theme.of(context).primaryColor, // Warna hijau yang sama
                  //  borderRadius: BorderRadius.only(
                  //    topLeft: Radius.circular(20),
                  //    topRight: Radius.circular(20),
                  //  ),
                 ),
               ),
          ],
        ),
        body: Container(
          padding: EdgeInsets.only(
            bottom: configAppBloc.packagename.valueWrapper?.value == 'com.flobamora.app' ? 20.0 : 0.0, // Padding khusus Flobamora
          ),
          child: halaman[pageIndex],
        ));
  }
}
// @dart=2.9

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/funfast/layout/profile.dart';
import 'package:mobile/Products/funfast/layout/home1.dart';
// import 'package:mobile/Products/funmo/layout/history.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/component/webview.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:mobile/screen/history/history.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';
import '../../../component/fonts/funmo/my_flutter_app_icons.dart';
import '../../../overrides/bubble_bottom_bar/lib/bubble_bottom_bar.dart';

class HomeFunmo extends StatefulWidget {
  @override
  _HomeFunmoState createState() => _HomeFunmoState();
}

class _HomeFunmoState extends State<HomeFunmo>
    with SingleTickerProviderStateMixin {
  Color mainColor = Colors.white;
  Color mainTextColor = Colors.blue;

  List<Widget> halaman = [Home1App(), HistoryPage(), ProfilePage()];
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
              color: Colors.white,
              icon: Icon(Icons.notifications),
              onPressed: () {
                Navigator.of(context).pushNamed('/notifikasi');
              },
            )
          ],
        ),
        // bottomNavigationBar: CurvedNavigationBar(
        //   color: Theme.of(context).primaryColor,
        //   backgroundColor: Colors.white.withOpacity(.1),
        //   animationCurve: Curves.fastOutSlowIn,
        //   buttonBackgroundColor: Theme.of(context).primaryColor,
        //   items: <Widget>[
        //     Icon(Icons.apps, size: 30, color: Colors.white),
        //     Icon(Icons.list, size: 30, color: Colors.white),
        //     Icon(Icons.person, size: 30, color: Colors.white),
        //   ],
        //   onTap: (index) {
        //     //Handle button tap
        //     setState(() {
        //       pageIndex = index;
        //     });
        //   },
        // ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var barcode = await BarcodeScanner.scan();
            print(barcode);
            if (barcode.rawContent.isNotEmpty) {
              return Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => TransferByQR(barcode.rawContent)));
            }
          },
          elevation: 30.0,
          shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(.5),
                  width: 2.0),
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          child:
              Icon(MyFlutterApp.funmo, color: Theme.of(context).primaryColor),
          backgroundColor: Colors.grey.shade100,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BubbleBottomBar(
          currentIndex: pageIndex,
          iconSize: 24.0,
          backgroundColor: Theme.of(context).primaryColor,
          onTap: (index) {
            setState(() {
              pageIndex = index;
            });
          },
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          elevation: 20,
          fabLocation: BubbleBottomBarFabLocation.center, //new
          hasNotch: true, //new
          inkColor: Colors.white,
          hasInk: true,
          opacity: 1,
          items: [
            BubbleBottomBarItem(
                backgroundColor: Theme.of(context).secondaryHeaderColor,
                icon: Icon(Icons.dashboard,
                    color: Theme.of(context).secondaryHeaderColor),
                activeIcon: Icon(Icons.dashboard,
                    color: Theme.of(context).primaryColor),
                title: Text("Home",
                    style: TextStyle(color: Theme.of(context).primaryColor))),
            BubbleBottomBarItem(
                backgroundColor: Theme.of(context).secondaryHeaderColor,
                icon: Icon(Icons.list, color: Colors.white),
                activeIcon:
                    Icon(Icons.list, color: Theme.of(context).primaryColor),
                title: Text("History",
                    style: TextStyle(color: Theme.of(context).primaryColor))),
            BubbleBottomBarItem(
                backgroundColor: Theme.of(context).secondaryHeaderColor,
                icon: Icon(Icons.person_pin_circle, color: Colors.white),
                activeIcon: Icon(Icons.person_pin_circle,
                    color: Theme.of(context).primaryColor),
                title: Text("Profil",
                    style: TextStyle(color: Theme.of(context).primaryColor))),
          ],
        ),
        body: halaman[pageIndex]);
  }
}

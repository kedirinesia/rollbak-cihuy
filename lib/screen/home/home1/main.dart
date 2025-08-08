// ignore_for_file: deprecated_member_use
// ignore_for_file: undefined_getter

// @dart=2.9

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/component/webview.dart';
import 'package:mobile/screen/history/history.dart';
import 'package:mobile/screen/home/home1/home1.dart';
import 'package:mobile/screen/profile/downline/downline.dart';
import 'package:mobile/screen/profile/profile.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';


class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  Color mainColor = Colors.white;
  Color mainTextColor = Colors.blue;

  List<Widget> halaman = [Home1App(), HistoryPage(), Downline(), ProfilePage()];
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          child: CachedNetworkImage(
              imageUrl:
                  'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fsarinu%2Fqr-code%20(1).png?alt=media&token=def5bcd4-1f6d-4532-a1b1-9e7bf06f2c48',
              width: 32.0,
              color: Colors.white),
          elevation: 0.0,
          onPressed: () async {
            var barcode = await BarcodeScanner.scan();
            print(barcode);
            // if (barcode.isNotEmpty) {
            return Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => TransferByQR(barcode.rawContent)));
            // }
          },
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
        bottomNavigationBar: Container(
          // Tambahkan padding yang cukup untuk menghindari system navigation
          padding: EdgeInsets.only(
            bottom: systemNavHeight + 8.0, // Extra 8px untuk safety
          ),
          child: BottomAppBar(
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

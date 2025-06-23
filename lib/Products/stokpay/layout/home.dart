// @dart=2.9

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/Products/stokpay/layout/home1.dart';
import 'package:mobile/Products/stokpay/layout/profile.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/component/half_circle.dart';
import 'package:mobile/component/webview.dart';
import 'package:mobile/Products/stokpay/layout/history.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';

import '../../../overrides/bubble_bottom_bar/lib/bubble_bottom_bar.dart';

class HomeStokpay extends StatefulWidget {
  @override
  _HomeStokpayState createState() => _HomeStokpayState();
}

class _HomeStokpayState extends State<HomeStokpay> {
  Color mainColor = Colors.white;
  Color mainTextColor = Colors.blue;

  List<Widget> halaman = [
    Home2App(),
    HistoryPage(),
    ProfilePopay(),
  ];
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );
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
          // IconButton(
          //   icon: Icon(Icons.chat, color: Colors.white),
          //   onPressed: () {
          //     if (configAppBloc.liveChat.valueWrapper?.value != '') {
          //       return Navigator.of(context).push(
          //         MaterialPageRoute(
          //           builder: (context) => Webview(
          //             'Live Chat Support',
          //             configAppBloc.liveChat.valueWrapper?.value,
          //           ),
          //         ),
          //       );
          //     } else {
          //       return null;
          //     }
          //   },
          // ),
          IconButton(
            icon: Icon(Icons.storefront_rounded, color: Colors.white),
            onPressed: () {
              if (configAppBloc.isKasir.valueWrapper.value) {
                return Navigator.of(context).pushNamed('/kasir');
              } else {
                return null;
              }
            },
          ),
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).pushNamed('/notifikasi');
            },
          )
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).secondaryHeaderColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: halaman[pageIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.0,
        child: CachedNetworkImage(
          imageUrl: 'https://dokumen.payuni.co.id/logo/stokpay/scan.png',
          width: 32.0,
        ),
        onPressed: () async {
          var barcode = await BarcodeScanner.scan();
          if (barcode.rawContent.isEmpty) return null;
          return Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TransferByQR(barcode.rawContent),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Stack(
        fit: StackFit.loose,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).secondaryHeaderColor,
                ],
              ),
            ),
          ),
          Positioned(
            top: -33,
            child: HalfCircle(diameter: 65),
          ),
          BubbleBottomBar(
            currentIndex: pageIndex,
            iconSize: 24.0,
            backgroundColor: Colors.transparent,
            onTap: (index) {
              setState(() {
                pageIndex = index;
              });
            },
            elevation: 20,
            fabLocation: BubbleBottomBarFabLocation.center, //new
            hasNotch: true, //new
            inkColor: Colors.green,
            hasInk: true,
            opacity: 1,
            items: [
              BubbleBottomBarItem(
                backgroundColor: Colors.white,
                icon: Icon(
                  Icons.dashboard,
                  color: Colors.white,
                ),
                activeIcon: Icon(
                  Icons.dashboard,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(
                  "Home",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              BubbleBottomBarItem(
                backgroundColor: Colors.white,
                icon: Icon(
                  Icons.list,
                  color: Colors.white,
                ),
                activeIcon: Icon(
                  Icons.list,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(
                  "Riwayat",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              BubbleBottomBarItem(
                backgroundColor: Colors.white,
                icon: Icon(
                  Icons.account_circle,
                  color: Colors.white,
                ),
                activeIcon: Icon(
                  Icons.account_circle,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(
                  "Profil",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

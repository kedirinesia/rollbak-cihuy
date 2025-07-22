// @dart=2.9

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/Products/mykonterr/layout/cs.dart';
import 'package:mobile/Products/mykonterr/layout/home1.dart';
import 'package:mobile/Products/mykonterr/layout/profile.dart';
import 'package:mobile/Products/mykonterr/layout/history.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/screen/kasir/main.dart';
import 'package:mobile/screen/profile/downline/downline.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';

class HomeBlibli extends StatefulWidget {
  @override
  _HomeBlibliState createState() => _HomeBlibliState();
}

class _HomeBlibliState extends State<HomeBlibli> {
  Color mainColor = Colors.white;
  Color mainTextColor = Colors.blue;
  int pageIndex = 0;
  List<Widget> halaman = [PayuniHome(), HistoryPage(), Downline(), ProfilePopay()];
  
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          child: CachedNetworkImage(
                  imageUrl:
                      'https://dokumen.payuni.co.id/logo/payku/qris.png', color: Colors.white, width: 40.0, height: 40.0),
          elevation: 0.0,
          // onPressed: () => Navigator.of(context).push(
          //   MaterialPageRoute(
          //     builder: (_) => CS1(),
          //   ),
          // ),
          onPressed: () async {
            var barcode = await BarcodeScanner.scan();
            if (barcode.rawContent.isNotEmpty) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => TransferByQR(barcode.rawContent)
              ));
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.light,
          ),
          backgroundColor: Theme.of(context).primaryColor,
          toolbarHeight: 0.0,
          elevation: 0,
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
                                'https://dokumen.payuni.co.id/logo/paymobileku/home.png',
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
                                'https://dokumen.payuni.co.id/logo/paymobileku/histori.png',
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
                                'https://dokumen.payuni.co.id/logo/paymobileku/keagenan.png',
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
                                'https://dokumen.payuni.co.id/logo/paymobileku/profile.png',
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
        body: halaman[pageIndex]);
  }
}


import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:mobile/Products/paymobileku/layout/home.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/component/webview.dart';
import 'package:mobile/Products/paymobileku/layout/history.dart';
import 'package:mobile/Products/paymobileku/layout/downline/downline.dart';
import 'package:mobile/Products/paymobileku/layout/profile.dart';
import 'package:mobile/screen/marketplace/belanja.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';

class PakaiAjaHome extends StatefulWidget {
  @override
  _PakaiAjaHomeState createState() => _PakaiAjaHomeState();
}

class _PakaiAjaHomeState extends State<PakaiAjaHome> {
  Color mainColor = Colors.white;
  Color mainTextColor = Colors.blue;

  List<Widget> halaman = [
    PakeAjaHome(),
    HistoryPage(),
    Downline(),
    ProfilePage()
  ];
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          child: configAppBloc.isMarketplace.valueWrapper!.value
              // ? SvgPicture.asset(
              //     'assets/img/payuni2/shopping-cart.svg',
              //     height: 35,
              //     color: Colors.white,
              //   )
              ? Icon(
                  Icons.shopping_cart_rounded,
                  color: Colors.white,
                  size: 35,
                )
              : CachedNetworkImage(
                  imageUrl:
                      'https://dokumen.payuni.co.id/logo/paymobileku/SCAN.png'),
          elevation: 6.0,
          onPressed: () async {
            if (configAppBloc.isMarketplace.valueWrapper!.value) {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => BelanjaPage()));
            } else {
              var barcode = await BarcodeScanner.scan();
              if (barcode.rawContent.isNotEmpty) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => TransferByQR(barcode.rawContent)));
              }
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        appBar: AppBar(
          title: Image.asset(
            'assets/img/paymobileku/logo.png',
            height: 40,
          ),
          backgroundColor: Color(0XFFDDFFBC),
          elevation: 0.0,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.chat_rounded),
                color: Colors.amber.shade800,
                onPressed: () {
                  if (configAppBloc.liveChat.valueWrapper?.value != '') {
                     Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Webview(
                          'Live Chat Support',
                          configAppBloc.liveChat.valueWrapper!.value,
                        ),
                      ),
                    );
                  } else {
                    return null;
                  }
                }),
            IconButton(
              icon: Icon(Icons.notifications_rounded),
              color: Colors.amber.shade800,
              onPressed: () {
                Navigator.of(context).pushNamed('/notifikasi');
              },
            ),
          ],
        ),
        bottomNavigationBar: AnimatedBottomNavigationBar.builder(
          activeIndex: pageIndex,
          gapLocation: GapLocation.center,
          notchSmoothness: NotchSmoothness.verySmoothEdge,
          backgroundColor: Colors.white,
          itemCount: 4,
          tabBuilder: (i, isActive) {
            Color color = isActive ? Theme.of(context).primaryColor : Colors.grey;
            IconData icon;
            String label;

            if (i == 0) {
              icon = Icons.home_rounded;
              label = 'Home';
            } else if (i == 1) {
              icon = Icons.history_rounded;
              label = 'History';
            } else if (i == 2) {
              icon = Icons.group_rounded;
              label = 'Keagenan';
            } else {
              icon = Icons.person_rounded;
              label = 'Profile';
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 22),
                SizedBox(height: 2),
                Text(label, style: TextStyle(fontSize: 10, color: color)),
              ],
            );
          },
          onTap: (index) {
            setState(() {
              pageIndex = index;
            });
          },
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

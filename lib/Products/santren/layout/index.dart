// @dart=2.9

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/Products/santren/layout/home.dart';
import 'package:mobile/Products/santren/layout/history.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/component/webview.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/kasir/main.dart';
import 'package:mobile/Products/santren/layout/profile.dart';
import 'package:mobile/screen/profile/reward/list_reward.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';

class EpulsaHome extends StatefulWidget {
  @override
  _EpulsaHomeState createState() => _EpulsaHomeState();
}

class _EpulsaHomeState extends State<EpulsaHome> {
  Color mainColor = Colors.white;
  Color mainTextColor = Colors.blue;

  List<Widget> halaman = [
    Home4App(),
    HistoryPage(),
    MainKasir(),
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
      floatingActionButton: Material(
        elevation: 2.0,
        borderRadius: BorderRadius.circular(8), // Radius untuk sudut membulat
        color: Theme.of(context).primaryColor, // Warna background
        child: InkWell(
          borderRadius: BorderRadius.circular(8), // Radius untuk efek klik
          onTap: () async {
            var barcode = await BarcodeScanner.scan();
            print(barcode);
            if (barcode.rawContent.isNotEmpty) {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => TransferByQR(barcode.rawContent)));
            }
          },
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            child: CachedNetworkImage(
              imageUrl: 'https://dokumen.payuni.co.id/logo/santren/qristengah.png',
              width: 42.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: pageIndex == 0
          ? AppBar(
              title: Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: 'https://dokumen.payuni.co.id/logo/santren/appbar1.png',
                    width: 75.0),
                  SizedBox(width: 25),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SantrenPay Points',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        '${formatNumber(bloc.user.valueWrapper?.value?.poin ?? 0)} Pts',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0XFFF60a809),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 25),
                  InkWell(
                    onTap: () =>
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ListReward())),
                    child: Text(
                      'Redeem',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0XFFF118e33),
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Color(0XFFaff368),
              elevation: 0.0,
              actions: <Widget>[
                configAppBloc.liveChat.valueWrapper?.value != ''
                    ? IconButton(
                        icon: Icon(Icons.chat, color: Colors.white),
                        onPressed: () { 
                          final url = configAppBloc.liveChat.valueWrapper?.value;
                          print("DEBUG | Webview akan menuju ke: $url");
                          if (url != '') {
                            return Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Webview(
                                    'Live Chat Support', url)));
                          } else {
                            return null;
                          }
                        })
                    : Container(),
                IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/notifikasi');
                  },
                )
              ],
            )
          : null,
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
                      SvgPicture.asset('assets/img/storefront.svg',
                          color: pageIndex == 2
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                          width: 20.0),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text('Kasir', style: TextStyle(fontSize: 10.0))
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

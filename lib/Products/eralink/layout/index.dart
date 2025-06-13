// @dart=2.9

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/component/webview.dart';
import 'package:mobile/screen/history/history.dart';
import 'package:mobile/Products/eralink/layout/downline/downline.dart';
import 'package:mobile/Products/eralink/layout/profile.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';

import 'home.dart';

class CentralBayarHome extends StatefulWidget {
  @override
  _CentralBayarHomeState createState() => _CentralBayarHomeState();
}

class _CentralBayarHomeState extends State<CentralBayarHome>
    with SingleTickerProviderStateMixin {
  Color mainColor = Colors.white;
  Color mainTextColor = Colors.blue;

  List<Widget> halaman = [Home4App(), HistoryPage(), DownlinePage(), ProfilePage()];
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
          child: CachedNetworkImage(
              imageUrl:
                  'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fsarinu%2Fqr-code%20(1).png?alt=media&token=def5bcd4-1f6d-4532-a1b1-9e7bf06f2c48',
              width: 32.0,
              color: Theme.of(context).secondaryHeaderColor),
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
          title: configAppBloc.iconApp.valueWrapper?.value['logoLoginHeader'] !=
                  null
              ? CachedNetworkImage(
                  imageUrl: configAppBloc
                      .iconApp.valueWrapper?.value['logoLoginHeader'],
                  width: 150.0)
              : Text(configAppBloc.namaApp.valueWrapper?.value),
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
              icon: Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pushNamed('/notifikasi');
              },
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
                                'https://dokumen.payuni.co.id/logo/centralbayar/new/icon/centralhome.png',
                            color: pageIndex == 0
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).secondaryHeaderColor,
                            width: 22.0),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text('Home', style: TextStyle(fontSize: 10.0, color: Theme.of(context).primaryColor))
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
                                'https://dokumen.payuni.co.id/logo/centralbayar/new/icon/centralhistory.png',
                            color: pageIndex == 1
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).secondaryHeaderColor,
                            width: 25.0),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text('History', style: TextStyle(fontSize: 10.0, color: Theme.of(context).primaryColor))
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
                                'https://dokumen.payuni.co.id/logo/centralbayar/new/icon/centralkeagenan.png',
                            color: pageIndex == 2
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).secondaryHeaderColor,
                            width: 30.0),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text('Keagenan', style: TextStyle(fontSize: 10.0, color: Theme.of(context).primaryColor))
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
                                'https://dokumen.payuni.co.id/logo/centralbayar/new/icon/centralprofile.png',
                            color: pageIndex == 3
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).secondaryHeaderColor,
                            width: 20.0),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text('Profile', style: TextStyle(fontSize: 10.0, color: Theme.of(context).primaryColor))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: halaman[pageIndex]);
  }
}

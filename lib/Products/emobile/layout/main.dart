// @dart=2.9

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mobile/Products/emobile/layout/home.dart';
import 'package:mobile/Products/emobile/layout/profile.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/component/webview.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/history/history.dart';
import 'package:mobile/screen/profile/downline/downline.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePopay extends StatefulWidget {
  @override
  _HomePopayState createState() => _HomePopayState();
}

class _HomePopayState extends State<HomePopay>
    with SingleTickerProviderStateMixin {
  int pageIndex = 0;
  List<Widget> halaman = [
    EmobileHome(),
    HistoryPage(),
    Downline(),
    ProfilePopay(),
  ];
  
  AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: CachedNetworkImage(
            imageUrl:
                'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Fqr-code-scan%20(1).png?alt=media&token=9c6c8655-238f-4c93-9b1e-f5176a7d1dcb'),
        elevation: 0.0,
        onPressed: () async {
          String barcode = (await BarcodeScanner.scan()).toString();
          if (barcode.isNotEmpty) {
            return Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => TransferByQR(barcode)));
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        title:
            configAppBloc.iconApp.valueWrapper?.value['logoLoginHeader'] != null
                ? CachedNetworkImage(
                    imageUrl: configAppBloc
                        .iconApp.valueWrapper?.value['logoLoginHeader'],
                    width: 75.0)
                : Text(configAppBloc.namaApp.valueWrapper?.value),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.0,
        actions: <Widget>[
          RotationTransition(
            turns: _animationController,
            child: IconButton(
              splashRadius: 20,
              color: Colors.white,
              icon: Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: () async {
                _animationController.fling().then((a) {
                  _animationController.value = 0;
                });
                await updateUserInfo();

                DefaultCacheManager().emptyCache().then((value) {
                  final snackBar = SnackBar(
                    content: const Text('Berhasil memperbarui konten'),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }).catchError((err) {
                  final snackBar = SnackBar(
                    content: const Text('Gagal memperbarui konten'),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                });
              },
            ),
          ),
          configAppBloc.liveChat.valueWrapper?.value != ''
              ? IconButton(
                  splashRadius: 20,
                  icon: Icon(Icons.chat, color: Colors.white),
                  onPressed: () {
                    launch("https://api.whatsapp.com/send?phone=6281326558055");
                  })
              : Container(),
          IconButton(
            splashRadius: 20,
            color: Colors.white,
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushNamed('/notifikasi');
            },
          ),
        ],
      ),
      body: halaman[pageIndex],
      bottomNavigationBar: BottomAppBar(
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
                              'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Fcombined_shape.png?alt=media&token=2d78122e-51a2-4a0b-9e6e-ed699b8a5758',
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
                              'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Fhistory_inactive.png?alt=media&token=04704026-de7b-4dca-838f-ab5fdd6802be',
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
              SizedBox(width: 40.0),
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
                              'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Fprofile-home.png?alt=media&token=65f46061-2ae6-48ba-8e61-dfddec73706f',
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
    );
  }
}

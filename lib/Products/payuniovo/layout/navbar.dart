// @dart=2.9


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/Products/payuniovo/layout/cs.dart';
import 'package:mobile/Products/payuniovo/layout/home.dart';
import 'package:mobile/Products/payuniovo/layout/profile.dart';
import 'package:mobile/screen/kasir/main.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';
import 'package:barcode_scan2/platform_wrapper.dart';

class NavbarHome extends StatefulWidget {
  @override
  _NavbarHomeState createState() => _NavbarHomeState();
}

class _NavbarHomeState extends State<NavbarHome> {
  int pageIndex = 0;
  List<Widget> halaman = [HomePayku(), CS1(), MainKasir(), ProfilePopay()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
        ),
        backgroundColor: Colors.transparent,
        toolbarHeight: 0.0,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: CachedNetworkImage(
          imageUrl: 'https://dokumen.payuni.co.id/logo/payku/qris.png',
          color: Colors.white,
          width: 40.0,
          height: 40.0,
        ),
        elevation: 0.0,
        onPressed: () async {
          var barcode = await BarcodeScanner.scan();
          if (barcode.rawContent.isNotEmpty) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => TransferByQR(barcode.rawContent)));
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: halaman[pageIndex],
      bottomNavigationBar: BottomAppBar(
        // color: Colors.white.withOpacity(0.7),
        // notchMargin: 5,
        shape: CircularNotchedRectangle(),
        // clipBehavior: Clip.antiAlias,
        child: Container(
          color: Colors.white.withOpacity(0.3),
          height: 55.0,
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
                  child: Container(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: <Widget>[
                        pageIndex == 0
                            ? SvgPicture.asset(
                                "assets/img/payuni2/home.svg",
                                color: Theme.of(context).primaryColor,
                                height: 25.0,
                                width: 25.0,
                              )
                            : SvgPicture.asset(
                                "assets/img/payuni2/home.svg",
                                color: Colors.grey,
                                height: 25.0,
                                width: 25.0,
                              ),
                        SizedBox(
                          height: 3.0,
                        ),
                        Text('Home', style: TextStyle(fontSize: 10.0))
                      ],
                    ),
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
                  child: Container(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: <Widget>[
                        CachedNetworkImage(
                          imageUrl: 'https://www.payuni.co.id/img/ls.png',
                          color: pageIndex == 1
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                          width: 25.0,
                          height: 25.0,
                        ),
                        SizedBox(
                          height: 3.0,
                        ),
                        Text('CS', style: TextStyle(fontSize: 10.0))
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 60),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      pageIndex = 2;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: <Widget>[
                        pageIndex == 2
                            ? SvgPicture.asset(
                                "assets/img/payuni2/mp.svg",
                                color: Theme.of(context).primaryColor,
                                height: 25.0,
                                width: 25.0,
                              )
                            : SvgPicture.asset(
                                "assets/img/payuni2/mp.svg",
                                color: Colors.grey,
                                height: 25.0,
                                width: 25.0,
                              ),
                        SizedBox(
                          height: 3.0,
                        ),
                        Text('Kasir', style: TextStyle(fontSize: 10.0))
                      ],
                    ),
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
                  child: Container(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: <Widget>[
                        pageIndex == 3
                            ? SvgPicture.asset(
                                "assets/img/payuni2/user.svg",
                                color: Theme.of(context).primaryColor,
                                height: 25.0,
                                width: 25.0,
                              )
                            : SvgPicture.asset(
                                "assets/img/payuni2/user.svg",
                                color: Colors.grey,
                                height: 25.0,
                                width: 25.0,
                              ),
                        SizedBox(
                          height: 3.0,
                        ),
                        Text('Profile', style: TextStyle(fontSize: 10.0))
                      ],
                    ),
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

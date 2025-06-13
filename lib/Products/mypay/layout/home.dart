// @dart=2.9

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/Products/mypay/layout/components/menuTool.dart';
import 'package:mobile/Products/mypay/layout/profile.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/component/card_info.dart';
import 'package:mobile/Products/mypay/layout/components/carousel-depan.dart';
import 'package:mobile/component/menudepan.dart';
import 'package:mobile/component/rewards.dart';
import 'package:mobile/component/webview.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/kasir/main.dart';
import 'package:mobile/screen/marketplace/index.dart';
import 'package:mobile/screen/profile/cs/cs.dart';
import 'package:mobile/screen/profile/invite/invite.dart';
import 'package:mobile/screen/profile/reward/list_reward.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';
import 'package:mobile/Products/mypay/layout/cs.dart';
import 'package:mobile/Products/mypay/layout/history.dart';

class HomePopay extends StatefulWidget {
  @override
  _HomePopayState createState() => _HomePopayState();
}

class _HomePopayState extends State<HomePopay> with TickerProviderStateMixin {
  AnimationController _rotationController;
  int pageIndex = 0;
  List<Widget> halaman = [Container(), HistoryPage(), CS1(), ProfilePopay()];
  
  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  // Widget build(BuildContext context) {
  //   return Scaffold(
  //       //     backgroundColor: Colors.grey[100],
  //     floatingActionButton: FloatingActionButton(
  //       backgroundColor: Theme.of(context).primaryColor,
  //       child: configAppBloc.isKasir.value
  //           ? InkWell(
  //               onTap: () {
  //                 Navigator.of(context).pushNamed('/kasir');
  //               },
  //               child: SvgPicture.asset('assets/img/storefront.svg',
  //                   width: 28.0, color: Colors.white),
  //             )
  //           : CachedNetworkImage(
  //               imageUrl:
  //                   'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Fqr-code-scan%20(1).png?alt=media&token=9c6c8655-238f-4c93-9b1e-f5176a7d1dcb'),
  //       elevation: 0.0,
  //       onPressed: () async {
  //         if (configAppBloc.isKasir.value) {
  //           Navigator.of(context)
  //               .push(MaterialPageRoute(builder: (_) => MainKasir()));
  //         } else {
  //           var barcode = await BarcodeScanner.scan();
  //           if (barcode.rawContent.isNotEmpty) {
  //             Navigator.of(context).push(MaterialPageRoute(
  //                 builder: (_) => TransferByQR(barcode.rawContent)));
  //           }
  //         }
  //       },
  //     ),

  Widget build(BuildContext context) {
    return Scaffold(
            backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: configAppBloc.isMarketplace.valueWrapper?.value
            ? Icon(Icons.shopping_cart_rounded)
            : CachedNetworkImage(
                imageUrl:
                    'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Fqr-code-scan%20(1).png?alt=media&token=9c6c8655-238f-4c93-9b1e-f5176a7d1dcb'),
        elevation: 0.0,
        onPressed: () async {
          if (configAppBloc.isMarketplace.valueWrapper?.value) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => MarketPage()));
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
      body: pageIndex == 0
          ? SingleChildScrollView(
              child: Stack(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: 300.0,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: CachedNetworkImageProvider(
                                'https://dokumen.payuni.co.id/logo/mypay/headerbg.png'),
                            fit: BoxFit.cover)),
                  ),
                  Container(
                    child: ListView(
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 30.0),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: CachedNetworkImage(
                                    imageUrl:
                                        'https://dokumen.payuni.co.id/logo/mypay/icon1.png',
                                    width: 24.0),
                              ),
                              Expanded(
                                child: Row(
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                            'Hello, ${bloc.username.valueWrapper?.value.split(' ')[0]}',
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.grey[50])),
                                        Text(
                                            formatRupiah(bloc.user.valueWrapper
                                                ?.value.saldo),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 15.0))
                                      ],
                                    ),
                                    SizedBox(width: 10.0),
                                    Expanded(
                                        flex: 7,
                                        child: InkWell(
                                          onTap: () {
                                            updateUserInfo();
                                            _rotationController.forward(
                                                from: 0);
                                            showToast(context,
                                                'Berhasil memperbarui saldo');
                                            setState(() {});
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              RotationTransition(
                                                turns: Tween(
                                                        begin: 0.0, end: 1.0)
                                                    .animate(
                                                        _rotationController),
                                                child: Icon(
                                                  Icons.refresh_rounded,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          // child: Icon(Icons.refresh,
                                          //     color: Colors.white),
                                        ))
                                  ],
                                ),
                              ),
                              // InkWell(
                              //   onTap: () {
                              //     if (configAppBloc.liveChat.valueWrapper?.value != '') {
                              //       return Navigator.of(context).push(
                              //           MaterialPageRoute(
                              //               builder: (context) => Webview(
                              //                   'Live Chat Support',
                              //                   configAppBloc.liveChat.valueWrapper?.value)));
                              //     } else {
                              //       return null;
                              //     }
                              //   },
                              //   child: CachedNetworkImage(
                              //       imageUrl:
                              //           'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpayku%2Fchat%20(1)%20(2).png?alt=media&token=1dc9d92b-6ef2-4252-a946-9fcd74922c4e'),
                              // ),
                              SizedBox(width: 10.0),
                              InkWell(
                                onTap: () => Navigator.of(context)
                                    .pushNamed('/notifikasi'),
                                child: Icon(
                                  Icons.notifications_none,
                                  color: Colors.white,
                                  size: 28.0,
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 20.0),
                        MenuToolPopay(),
                        Container(
                          margin: EdgeInsets.only(left: 20.0, right: 20.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(.1),
                                    blurRadius: 10.0,
                                    offset: Offset(5, 10))
                              ]),
                          child: MenuDepan(grid: 4, radius: 10.0),
                        ),
                        SizedBox(height: 20.0),
                        Container(
                          margin: EdgeInsets.only(left: 20.0, right: 20.0),
                          child: ListTile(
                            title: Text('Selalu Ada di MyPay',
                                style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                'Mudah Dapatkan Akses Info Promo Terbaru',
                                style: TextStyle(
                                    fontSize: 11.0, color: Colors.grey[500])),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        CarouselDepan(),
                        SizedBox(height: 20.0),
                        Container(
                          margin: EdgeInsets.only(left: 20.0, right: 20.0),
                          child: ListTile(
                            title: Text('Info Menarik dari MyPay',
                                style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                'Baca Info Supaya Tidak Ketinggalan Kebahagiaan',
                                style: TextStyle(
                                    fontSize: 11.0, color: Colors.grey[500])),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                          child: CardInfo(),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10.0, right: 10.0),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 20.0),
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(.6),
                              image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      'https://dokumen.payuni.co.id/logo/mypay/appbar.png'),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Dapatkan Komisi dari Ajak Teman Kamu',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0)),
                              SizedBox(height: 10.0),
                              Text(
                                  'Mengajak Teman Kamu Untuk Menggunakan MyPay adalah Salah Satu Cara Untuk Mendapatkan Penghasilan Tambahan Buat Kamu',
                                  style: TextStyle(
                                      fontSize: 12.0, color: Colors.grey[200])),
                              SizedBox(height: 10.0),
                              InkWell(
                                  onTap: () {
                                    return Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) => InvitePage()));
                                  },
                                  highlightColor: Colors.black.withOpacity(.4),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 10.0),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.white, width: 1.0)),
                                    child: Text('Undang Teman',
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.white)),
                                  ))
                            ],
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Container(
                          margin: EdgeInsets.only(left: 20.0, right: 20.0),
                          child: ListTile(
                            title: Text('Dapat Hadiah dari MyPay',
                                style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                'Kumpulkan Poin Kamu dan Tukarkan dengan Reward yang Tersedia Dari MyPay',
                                style: TextStyle(
                                    fontSize: 11.0, color: Colors.grey[500])),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        RewardComponent(),
                        SizedBox(height: 50.0)
                      ],
                    ),
                  )
                ],
              ),
            )
          : halaman[pageIndex],
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
              // SizedBox(width: 40.0),
              // Expanded(
              //   child: InkWell(
              //     onTap: () {
              //       setState(() {
              //         pageIndex = 2;
              //       });
              //     },
              //     child: Column(
              //       children: <Widget>[
              //         CachedNetworkImage(
              //             imageUrl:
              //                 'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Flight-mode-home.png?alt=media&token=a42c10b4-8ae6-4c8e-b774-0056a4ca1e84',
              //             color: pageIndex == 2
              //                 ? Theme.of(context).primaryColor
              //                 : Colors.grey,
              //             width: 20.0),
              //         SizedBox(
              //           height: 5.0,
              //         ),
              //         Text('Rewards', style: TextStyle(fontSize: 10.0))
              //       ],
              //     ),
              //   ),
              // ),
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
                          imageUrl: 'https://www.payuni.co.id/img/ls.png',
                          color: pageIndex == 2
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                          width: 20.0),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text('CS', style: TextStyle(fontSize: 10.0))
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

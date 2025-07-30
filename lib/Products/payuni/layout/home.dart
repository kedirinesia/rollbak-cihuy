// @dart=2.9

import 'dart:convert';

import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/Products/payuni/config.dart';
import 'package:mobile/Products/payuni/layout/components/produk_pilihan.dart';
import 'package:mobile/Products/payuni/layout/components/rewards.dart';
import 'package:mobile/Products/payuni/layout/livechat.dart';
import 'package:mobile/Products/payuni/layout/components/sticky_navbar.dart';
import 'package:mobile/Products/payuni/layout/components/carousel_header.dart';
import 'package:mobile/Products/payuni/layout/components/menu_depan.dart';
import 'package:mobile/Products/payuni/layout/components/menu_tools.dart';
import 'package:mobile/Products/payuni/layout/components/carousel_depan.dart';
import 'package:mobile/Products/payuni/layout/profile.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/models/mp_produk.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/kasir/main.dart';
import 'package:mobile/screen/marketplace/belanja.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';

class HomePayuni extends StatefulWidget {
  @override
  _HomePayuniState createState() => _HomePayuniState();
}

class _HomePayuniState extends State<HomePayuni> with TickerProviderStateMixin {
  List<ProdukMarket> _products = [];
  bool loading = true;
  bool isTransparent = true;

  ScrollController _scrollController = ScrollController();
  AnimationController _animationController;

  int pageIndex = 0;
  List<Widget> halaman = [
    Container(),
    BelanjaPage(),
    CustomerServicePage(),
    ProfilePopay()
  ];

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.offset >= 100 && isTransparent) {
        _animationController.forward();
        setState(() {
          isTransparent = false;
        });
      } else if (_scrollController.offset < 100 && !isTransparent) {
        _animationController.reverse();
        setState(() {
          isTransparent = true;
        });
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 0),
    );

    getProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> getProducts() async {
    try {
      http.Response response = await http.get(
          Uri.parse('$apiUrl/market/products'),
          headers: {'Authorization': bloc.token.valueWrapper?.value});

      if (response.statusCode == 200) {
        List<dynamic> datas = json.decode(response.body)['data'];
        _products = datas.map((data) => ProdukMarket.fromJson(data)).toList();

        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SvgPicture.asset(
          "assets/img/payuni2/scan.svg",
          color: Colors.white,
          height: 30.0,
          width: 30.0,
        ),
        elevation: 0.0,
        onPressed: () async {
          if (configAppBloc.isKasir.valueWrapper?.value) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => MainKasir()));
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
          ? RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(Duration(milliseconds: 500));
                await updateUserInfo();
                await getProducts();
                setState(() {});
              },
              child: Container(
                color: Color(0XFFF0F0F0),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      child: Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height / 4.4),
                            child: ListView(
                              shrinkWrap: true,
                              physics: ScrollPhysics(),
                              children: <Widget>[
                                MenuComponent(),
                                SizedBox(height: 10.0),
                                /** 
                                 * Produk Pilihan
                                 */
                                Container(
                                  color: Colors.white,
                                  child: loading
                                      ? LoadingProdukPilihan()
                                      : _products.length == 0
                                          ? Container(
                                              width: double.infinity,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                      top: 15.0,
                                                      left: 18,
                                                      right: 18,
                                                    ),
                                                    child: Flex(
                                                      direction:
                                                          Axis.horizontal,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Pilihan Untukmu',
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                letterSpacing:
                                                                    0.7,
                                                              ),
                                                            ),
                                                            SizedBox(height: 6),
                                                            Text(
                                                              'Produk Spesial Untukmu',
                                                              style: TextStyle(
                                                                fontSize: 11.5,
                                                                letterSpacing:
                                                                    0.7,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            vertical: 50.0),
                                                    child: Center(
                                                      child: Text(
                                                        'Produk Belum Tersedia',
                                                        style: TextStyle(
                                                            color: Colors.grey),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : ProdukPilihan(_products),
                                ),
                                SizedBox(height: 10.0),
                                CarouselDepan(),
                                SizedBox(height: 10.0),

                                /**
                                 * Reward Carousel
                                 */
                                RewardComponent(),
                              ],
                            ),
                          ),

                          /**
                           * Carousel Header
                           */
                          Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.3013,
                            child: CarouselHeader(),
                          ),

                          /**
                           * Menu Tools
                           */
                          Container(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.265,
                              left: 15.0,
                              right: 15.0,
                            ),
                            child: MenuTools(),
                          ),
                        ],
                      ),
                    ),

                    /**
                     * Sticky Navbar
                     */
                    StickyNavBar(isTransparent: isTransparent)
                  ],
                ),
              ),
            )
          : halaman[pageIndex],
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: CircularNotchedRectangle(),
        child: Container(
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
                        pageIndex == 1
                            ? SvgPicture.asset(
                                "assets/img/payuni2/shopping-bag.svg",
                                color: Theme.of(context).primaryColor,
                                height: 25.0,
                                width: 25.0,
                              )
                            : SvgPicture.asset(
                                "assets/img/payuni2/shopping-bag.svg",
                                color: Colors.grey,
                                height: 25.0,
                                width: 25.0,
                              ),
                        SizedBox(
                          height: 3.0,
                        ),
                        Text('Belanja', style: TextStyle(fontSize: 10.0))
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
                                "assets/img/payuni2/message.svg",
                                color: Theme.of(context).primaryColor,
                                height: 25.0,
                                width: 25.0,
                              )
                            : SvgPicture.asset(
                                "assets/img/payuni2/message.svg",
                                color: Colors.grey,
                                height: 25.0,
                                width: 25.0,
                              ),
                        SizedBox(
                          height: 3.0,
                        ),
                        Text('Live Chat', style: TextStyle(fontSize: 10.0))
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

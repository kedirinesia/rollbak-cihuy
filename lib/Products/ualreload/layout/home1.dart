// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:lazy_load_refresh_indicator/lazy_load_refresh_indicator.dart';
import 'package:mobile/Products/ualreload/config.dart';
import 'package:mobile/Products/ualreload/layout/components/rewards.dart';
import 'package:mobile/Products/ualreload/layout/components/sticky_navbar.dart';
import 'package:mobile/Products/ualreload/layout/components/carousel_header.dart';
import 'package:mobile/Products/ualreload/layout/components/menu_depan.dart';
import 'package:mobile/Products/ualreload/layout/components/menu_tools/main.dart';
import 'package:mobile/Products/ualreload/layout/components/information/main.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/models/mp_produk.dart';
import 'package:mobile/modules.dart';

class HomePayuni1 extends StatefulWidget {
  @override
  _HomePayuni1State createState() => _HomePayuni1State();
}

class _HomePayuni1State extends State<HomePayuni1>
    with TickerProviderStateMixin {
  List<ProdukMarket> _products = [];
  bool loading = false;
  bool isTransparent = true;
  int page = 0;
  bool isEdge = false;

  ScrollController _scrollController = ScrollController();
  AnimationController _animationController;

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
    if (isEdge || loading) return;

    loading = true;

    Uri url = Uri.parse('$apiUrl/market/products?page=$page');

    try {
      http.Response response =
          await http.get(Uri.parse('$apiUrl/market/products'), headers: {
        'Authorization': bloc.token.valueWrapper?.value,
      });
      print(url);

      if (response.statusCode == 200) {
        List<dynamic> datas = json.decode(response.body)['data'];
        if (datas.length == 0) isEdge = true;

        _products
            .addAll(datas.map((data) => ProdukMarket.fromJson(data)).toList());
        setState(() {
          page++;
          loading = false;
        });
      } else {
        String message = json.decode(response.body)['message'] ??
            'Terjadi kesalahan pada server';
        final snackBar = Alert(message, isError: true);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print('Error: $e');
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
      body: LazyLoadRefreshIndicator(
        onRefresh: () async {
          try {
            await Future.delayed(Duration(milliseconds: 500));
            await updateUserInfo();
            await getProducts();
            await DefaultCacheManager().emptyCache();
          } catch (e) {
            final snackBar = SnackBar(
              content: const Text('Gagal memperbarui konten'),
            );

            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } finally {
            setState(() {});
          }
        },
        onEndOfPage: getProducts,
        scrollOffset: 200,
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
                          SizedBox(height: 8.0),
                          Information(),
                          SizedBox(height: 8.0),

                          /**
                           * Reward Carousel
                           */
                          RewardComponent(),
                          SizedBox(height: 8.0),

                          /** 
                           * Produk Pilihan
                           */
                          // Container(
                          //   color: Colors.white,
                          //   child: loading
                          //       ? ProductOfChoiceLoading()
                          //       : _products.length == 0
                          //           ? ProductOfChoiceNothing()
                          //           : ProductOfChoice(_products),
                          // ),
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
      ),
    );
  }
}

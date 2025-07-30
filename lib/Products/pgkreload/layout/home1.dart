// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/Products/pgkreload/config.dart';
import 'package:mobile/Products/pgkreload/layout/components/produk_pilihan.dart';
import 'package:mobile/Products/pgkreload/layout/components/rewards.dart';
import 'package:mobile/Products/pgkreload/layout/components/sticky_navbar.dart';
import 'package:mobile/Products/pgkreload/layout/components/carousel_header.dart';
import 'package:mobile/Products/pgkreload/layout/components/menu_depan.dart';
import 'package:mobile/Products/pgkreload/layout/components/menu_tools.dart';
import 'package:mobile/Products/pgkreload/layout/components/carousel_depan.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/mp_kategori.dart';
import 'package:mobile/models/mp_produk.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/marketplace/list_produk.dart';

class HomeAyoba1 extends StatefulWidget {
  @override
  _HomeAyoba1State createState() => _HomeAyoba1State();
}

class _HomeAyoba1State extends State<HomeAyoba1> with TickerProviderStateMixin {
  List<ProdukMarket> _products = [];
  bool loading = true;
  bool isTransparent = true;

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

  Future<List<CategoryModel>> categories() async {
    List<CategoryModel> categories = [];

    http.Response response = await http.get(
        Uri.parse('$apiUrl/market/category'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      datas.forEach((data) {
        if (data['judul'] != null &&
            data['description'] != null &&
            data['thumbnail'] != null) {
          categories.add(CategoryModel.fromJson(data));
        }
      });
    }

    return categories;
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
      body: RefreshIndicator(
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
                          // Container(
                          //   color: Colors.white,
                          //   // child: kategoriWidget(),
                          // ),
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
                                                direction: Axis.horizontal,
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
                                                              FontWeight.bold,
                                                          letterSpacing: 0.7,
                                                        ),
                                                      ),
                                                      SizedBox(height: 6),
                                                      Text(
                                                        'Produk Spesial Untukmu',
                                                        style: TextStyle(
                                                          fontSize: 11.5,
                                                          letterSpacing: 0.7,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.symmetric(
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
      ),
    );
  }

  // Widget kategoriWidget() {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     mainAxisAlignment: MainAxisAlignment.start,
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Container(
  //         padding: EdgeInsets.only(top: 15.0, left: 18, right: 18),
  //         child: Text(
  //           'Kategori Produk',
  //           style: TextStyle(
  //             fontSize: 15,
  //             fontWeight: FontWeight.bold,
  //             letterSpacing: 0.7,
  //           ),
  //         ),
  //         SizedBox(height: 6),
  //         Text(
  //           'Kategori produk yang mungkin anda cari',
  //           style: TextStyle(
  //             fontSize: 11.5,
  //             letterSpacing: 0.7,
  //           ),
  //         ),
  //       ),
  //       FutureBuilder<List<CategoryModel>>(
  //         future: categories(),
  //         builder: (ctx, snapshot) {
  //           if (!snapshot.hasData)
  //             return Container(
  //               margin: EdgeInsets.symmetric(
  //                 vertical: 15.0,
  //                 horizontal: 15.0,
  //               ),
  //               height: ((MediaQuery.of(context).size.width - 60) * .25) * 1.5,
  //               child: ListView.separated(
  //                 physics: BouncingScrollPhysics(),
  //                 scrollDirection: Axis.horizontal,
  //                 itemCount: snapshot.data.length,
  //                 separatorBuilder: (_, i) => SizedBox(width: 10),
  //                 itemBuilder: (ctx, i) {
  //                   return AspectRatio(
  //                     aspectRatio: 1 / 1.44,
  //                     child: Container(
  //                       width: (MediaQuery.of(context).size.width - 60) * .25,
  //                       height: double.infinity,
  //                       child: Shimmer.fromColors(
  //                         baseColor: Colors.grey.shade300,
  //                         highlightColor: Colors.grey.shade100,
  //                         period: Duration(seconds: 2),
  //                         child: Container(
  //                           width: double.infinity,
  //                           margin: EdgeInsets.symmetric(horizontal: 5.0),
  //                           decoration: BoxDecoration(
  //                               color: Colors.grey.shade200,
  //                               borderRadius: BorderRadius.circular(12.5)),
  //                           child: Container(),
  //                         ),
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               ),
  //             );

  //           if (snapshot.data.length == 0)
  //             return Container(
  //               width: double.infinity,
  //               padding: EdgeInsets.all(10),
  //               child: Center(
  //                 child: Text(
  //                   'Belum Ada Kategori',
  //                   style: TextStyle(color: Colors.grey),
  //                 ),
  //               ),
  //             );

  //           return Container(
  //             margin: EdgeInsets.symmetric(
  //               vertical: 15.0,
  //               horizontal: 15.0,
  //             ),
  //             height: ((MediaQuery.of(context).size.width - 60) * .25) * 1.5,
  //             child: ListView.separated(
  //               physics: BouncingScrollPhysics(),
  //               scrollDirection: Axis.horizontal,
  //               itemCount: snapshot.data.length,
  //               separatorBuilder: (_, i) => SizedBox(width: 10),
  //               itemBuilder: (ctx, i) {
  //                 CategoryModel kategori = snapshot.data[i];

  //                 return AspectRatio(
  //                   aspectRatio: 1 / 1.5,
  //                   child: InkWell(
  //                     onTap: () => Navigator.of(context).push(
  //                       MaterialPageRoute(
  //                         builder: (_) => ListProdukMarketplace(
  //                           categoryId: kategori.id,
  //                           categoryName: kategori.judul,
  //                         ),
  //                       ),
  //                     ),
  //                     child: Container(
  //                       width: (MediaQuery.of(context).size.width - 60) * .25,
  //                       height: double.infinity,
  //                       decoration: BoxDecoration(
  //                         color: Colors.grey.withOpacity(.08),
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                       child: Column(
  //                         mainAxisSize: MainAxisSize.min,
  //                         mainAxisAlignment: MainAxisAlignment.start,
  //                         children: [
  //                           AspectRatio(
  //                             aspectRatio: 1,
  //                             child: Padding(
  //                               padding: const EdgeInsets.all(5),
  //                               child: ClipRRect(
  //                                 borderRadius: BorderRadius.circular(5),
  //                                 child: CachedNetworkImage(
  //                                     imageUrl: kategori.thumbnailUrl,
  //                                     fit: BoxFit.cover,
  //                                     width: double.infinity,
  //                                     height: double.infinity),
  //                               ),
  //                             ),
  //                           ),
  //                           Padding(
  //                             padding: const EdgeInsets.symmetric(
  //                                 vertical: 5, horizontal: 10),
  //                             child: Text(
  //                               kategori.judul,
  //                               maxLines: 2,
  //                               overflow: TextOverflow.ellipsis,
  //                               style: TextStyle(
  //                                 fontSize: 11,
  //                                 color: Colors.black87,
  //                               ),
  //                             ),
  //                           )
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 );
  //               },
  //             ),
  //           );
  //         },
  //       ),
  //     ],
  //   );
  // }
  Widget kategoriWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kategori Produk',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Kategori produk yang mungkin anda cari',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        FutureBuilder<List<CategoryModel>>(
          future: categories(),
          builder: (ctx, snapshot) {
            if (!snapshot.hasData)
              return Container(
                width: double.infinity,
                height: ((MediaQuery.of(context).size.width - 60) * .25) * 1.5,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                    valueColor:
                        AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                  ),
                ),
              );

            if (snapshot.data.length == 0)
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                child: Center(
                  child: Text(
                    'Belum Ada Kategori',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );

            return Container(
              height: ((MediaQuery.of(context).size.width - 60) * .25) * 1.5,
              child: ListView.separated(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data.length,
                separatorBuilder: (_, i) => SizedBox(width: 10),
                itemBuilder: (ctx, i) {
                  CategoryModel kategori = snapshot.data[i];

                  return AspectRatio(
                    aspectRatio: 1 / 1.5,
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ListProdukMarketplace(
                            categoryId: kategori.id,
                            categoryName: kategori.judul,
                          ),
                        ),
                      ),
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 60) * .25,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: CachedNetworkImage(
                                      imageUrl: kategori.thumbnailUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Text(
                                kategori.judul,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black87,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

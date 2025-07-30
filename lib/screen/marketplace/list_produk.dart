// @dart=2.9

import 'dart:convert';

import 'package:badges/badges.dart' as BadgeModule;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lazy_load_refresh_indicator/lazy_load_refresh_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/mp_produk.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/marketplace/cart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile/screen/marketplace/detail_produk.dart';

class ListProdukMarketplace extends StatefulWidget {
  final String searchQuery;
  final String categoryId;
  final String categoryName;
  ListProdukMarketplace(
      {this.searchQuery = '', this.categoryId = '', this.categoryName = ''});

  @override
  _ListProdukMarketplaceState createState() => _ListProdukMarketplaceState();
}

class _ListProdukMarketplaceState extends State<ListProdukMarketplace> {
  List<ProdukMarket> products = [];
  int page = 0;
  String pageTitle;
  bool isLoading = true;
  bool isEdge = false;
  TextEditingController query = TextEditingController();
  String searchQuery;
  bool search = false;

  @override
  void initState() {
    searchQuery = widget.searchQuery ?? '';
    getData();
    super.initState();
    analitycs.pageView('/list/produk', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'List Produk Marketplace',
    });
  }

  Future<void> getData() async {
    if (isEdge) return;
    String url;

    if (searchQuery.isNotEmpty) {
      url = Uri.encodeFull(
          '$apiUrl/market/products/search?q=$searchQuery&page=$page');
      pageTitle = 'Pencarian';
    } else if (widget.categoryId.isNotEmpty) {
      url = '$apiUrl/market/${widget.categoryId}/products?page=$page';
      pageTitle = widget.categoryName;
    } else {
      url = '$apiUrl/market/products?page=$page';
      pageTitle = 'Produk';
    }

    http.Response response = await http.get(Uri.parse(url),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      if (datas.length == 0) isEdge = true;
      datas.forEach((data) => products.add(ProdukMarket.fromJson(data)));
      setState(() {
        isLoading = false;
        page++;
      });
    } else {
      print(response.body);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal memuat data')));
    }
  }

  void reset() {
    products.clear();
    search = false;
    page = 0;
    isEdge = false;
    searchQuery = widget.searchQuery ?? '';
    isLoading = true;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: search
          ? AppBar(
              title: TextField(
                controller: query,
                autofocus: true,
                keyboardType: TextInputType.text,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(color: Colors.white),
                onEditingComplete: () {
                  setState(() {
                    products.clear();
                    page = 0;
                    isEdge = false;
                    isLoading = true;
                    searchQuery = query.text;
                  });

                  getData();
                },
                decoration: InputDecoration(
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.close),
                      color: Colors.white,
                      onPressed: () {
                        query.clear();
                        reset();
                        getData();
                      },
                    )),
              ),
            )
          : AppBar(
              title: Text(pageTitle),
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      search = true;
                    });
                  },
                ),
                IconButton(
                    icon: ValueListenableBuilder<Box<dynamic>>(
                        valueListenable: Hive.box('cart').listenable(),
                        builder: (context, value, child) {
                          int itemCount = value.values.length;

                          if (itemCount < 1) return Icon(Icons.shopping_cart);

                          return BadgeModule.Badge(
                              child: Icon(Icons.shopping_cart),
                              badgeContent: Text(itemCount.toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 11)),
                              badgeColor: Colors.red);
                        }),
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => CartMarketPage())))
              ],
            ),
      body: isLoading
          ? Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(20),
              child: Center(
                child: SpinKitThreeBounce(
                  color: Theme.of(context).primaryColor,
                  size: 25,
                ),
              ),
            )
          : products.length == 0
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: EdgeInsets.all(15),
                  child: Center(
                    child: Text(
                      'Tidak ditemukan produk apapun',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              : LazyLoadRefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      products.clear();
                      page = 0;
                      isLoading = true;
                      isEdge = false;
                    });

                    await getData();
                  },
                  onEndOfPage: getData,
                  isLoading: isLoading,
                  scrollOffset: 200,
                  child: GridView.builder(
                    padding: EdgeInsets.all(15),
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1 / 1.55,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (ctx, i) {
                      ProdukMarket product = products[i];

                      return InkWell(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => ProductDetailMarketplace(
                                    product.id, product.title))),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.withOpacity(.3), width: 1),
                              color: Theme.of(context).canvasColor,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(.35),
                                    offset: Offset(5, 5),
                                    blurRadius: 20)
                              ]),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AspectRatio(
                                  aspectRatio: 1,
                                  child: CachedNetworkImage(
                                      imageUrl: product.thumbnail)),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(product.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.clip,
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold)),
                                      Text(formatRupiah(product.price),
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

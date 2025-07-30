// @dart=2.9

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lazy_load_refresh_indicator/lazy_load_refresh_indicator.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/mp_kategori.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/models/mp_produk.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/Products/talentapay/layout/mkp/detail_produk.dart';

class BelanjaPage extends StatefulWidget {
  @override
  _BelanjaPageState createState() => _BelanjaPageState();
}

class _BelanjaPageState extends State<BelanjaPage> {
  CategoryModel category;
  List<CategoryModel> categories = [];
  List<ProdukMarket> products = [];
  TextEditingController searchQuery = TextEditingController();
  int page = 0;
  bool isLoading = true;
  bool firstLoading = true;
  bool isEdge = false;

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  @override
  void dispose() {
    searchQuery.dispose();
    super.dispose();
  }

  Future<void> getCategories() async {
    http.Response response = await http.get(
        Uri.parse('$apiUrl/market/category'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      categories = datas.map((data) => CategoryModel.fromJson(data)).toList();
      await getProducts();
      setState(() {
        firstLoading = false;
      });
    }
  }

  Future<void> getProducts() async {
    if (isEdge) return;
    String url;

    if (searchQuery.text.isNotEmpty) {
      url = Uri.encodeFull(
          '$apiUrl/market/products/search?q=${searchQuery.text}&page=$page');
    } else if (category != null) {
      url = '$apiUrl/market/${category.id}/products?page=$page';
    } else {
      url = '$apiUrl/market/products?page=$page';
    }

    http.Response response = await http.get(Uri.parse(url),
        headers: {'Authorization': bloc.token.valueWrapper?.value});
    print(url);
    print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      if (datas.length == 0) isEdge = true;
      products.addAll(datas.map((e) => ProdukMarket.fromJson(e)).toList());
      page++;
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Marketplace'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: ((MediaQuery.of(context).size.width - 60) * .25),
            decoration: BoxDecoration(
              color: firstLoading
                  ? Colors.grey.withOpacity(.3)
                  : Colors.transparent,
            ),
            child: firstLoading
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
                : ListView.separated(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.all(5),
                    itemCount: categories.length,
                    separatorBuilder: (_, i) => SizedBox(width: 10),
                    itemBuilder: (ctx, i) {
                      CategoryModel cat = categories[i];

                      return AspectRatio(
                        aspectRatio: 1,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              products.clear();
                              searchQuery.clear();
                              isLoading = true;
                              isEdge = false;
                              page = 0;
                              category = cat;
                            });
                            getProducts();
                          },
                          child: Container(
                            width:
                                (MediaQuery.of(context).size.width - 60) * .25,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(.08),
                              borderRadius: BorderRadius.circular(5),
                              border: category == cat
                                  ? Border.all(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(.5),
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Stack(
                              fit: StackFit.loose,
                              alignment: Alignment.bottomCenter,
                              children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: CachedNetworkImage(
                                          imageUrl: cat.thumbnailUrl,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(.85),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(5),
                                      bottomRight: Radius.circular(5),
                                    ),
                                  ),
                                  child: Text(
                                    cat.judul,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          TextFormField(
            controller: searchQuery,
            keyboardType: TextInputType.text,
            onChanged: (val) {
              setState(() {});
            },
            onEditingComplete: () {
              setState(() {
                products.clear();
                category = null;
                isLoading = true;
                isEdge = false;
                page = 0;
              });
              getProducts();
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.grey.withOpacity(.15),
              hintText: 'Pencarian',
              hintStyle: TextStyle(color: Theme.of(context).primaryColor),
              prefixIcon: Icon(Icons.search_rounded),
              suffixIcon: searchQuery.text.isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(Icons.clear_rounded),
                      onPressed: () {
                        searchQuery.clear();
                        getProducts();
                      },
                    ),
            ),
          ),
          Expanded(
            child: isLoading
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
                            isEdge = false;
                          });

                          await getProducts();
                        },
                        onEndOfPage: getProducts,
                        scrollOffset: 200,
                        child: GridView.builder(
                          padding: EdgeInsets.all(5),
                          itemCount: products.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1 / 1.42,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                          ),
                          itemBuilder: (ctx, i) {
                            ProdukMarket product = products[i];

                            return InkWell(
                              onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => ProductDetailMarketplace(
                                          product.id,
                                          product.title,
                                          product.categoryId))),
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey.withOpacity(.3),
                                        width: 1),
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
                                                  fontSize: 8,
                                                )),
                                            Text(formatRupiah(product.price),
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ))
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
          ),
        ],
      ),
    );
  }
}

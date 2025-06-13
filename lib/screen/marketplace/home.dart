// @dart=2.9

import 'dart:convert';
import 'package:badges/badges.dart' as BadgeModule;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/carousel-depan.dart';
import 'package:mobile/models/mp_kategori.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/models/mp_produk.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/marketplace/cart.dart';
import 'package:mobile/screen/marketplace/detail_produk.dart';
import 'package:mobile/screen/marketplace/history.dart';
import 'package:mobile/screen/marketplace/list_produk.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    TextEditingController query = TextEditingController();
  bool search = false;
  @override
  void initState() {
    super.initState();
    analitycs.pageView('/home/marketplace', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Home Marketplace',
    });
  }

  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  Future<List<CategoryModel>> getCategories() async {
    List<CategoryModel> categories = [];

    http.Response response = await http.get(
        Uri.parse('$apiUrl/market/category'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      datas.forEach((data) => categories.add(CategoryModel.fromJson(data)));
    }

    return categories;
  }

  Future<List<ProdukMarket>> getProducts() async {
    try {
      http.Response response = await http.get(
          Uri.parse('$apiUrl/market/products'),
          headers: {'Authorization': bloc.token.valueWrapper?.value});

      if (response.statusCode == 200) {
        List<dynamic> datas = json.decode(response.body)['data'];
        return datas.map((e) => ProdukMarket.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ListProdukMarketplace(
                          searchQuery: query.text,
                        ),
                      ),
                    );
                  },
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.close),
                        color: Colors.white,
                        onPressed: () {
                          query.clear();
                          setState(() {
                            search = false;
                          });
                        },
                      )),
                ),
              )
            : AppBar(
                title: Text('Warung Delivery Kita'),
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
                ],
              ),
        body: ListView(padding: EdgeInsets.all(15), children: [
          CarouselDepan(),
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(.15),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => CartMarketPage())),
                  child: Container(
                    height: double.infinity,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(.15),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        bottomLeft: Radius.circular(5),
                      ),
                    ),
                    child: ValueListenableBuilder<Box<dynamic>>(
                      valueListenable: Hive.box('cart').listenable(),
                      builder: (context, value, child) {
                        int itemCount = value.values.length;

                        if (itemCount < 1)
                          return Icon(
                            Icons.shopping_cart_rounded,
                            color: Theme.of(context).primaryColor,
                          );

                        return BadgeModule.Badge(
                          child: Icon(
                            Icons.shopping_cart_rounded,
                            color: Theme.of(context).primaryColor,
                          ),
                          badgeContent: Text(
                            itemCount.toString(),
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          badgeColor: Colors.white,
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Saldo',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            formatRupiah(bloc.user.valueWrapper?.value.saldo),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                VerticalDivider(
                  width: 1,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => HistoryOrderPage())),
                    child: Container(
                      height: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(5),
                          bottomRight: Radius.circular(5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            color: Theme.of(context).primaryColor,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Riwayat',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          SizedBox(height: 10),
          Text(
            'Kategori Produk',
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 15),
          FutureBuilder<List<CategoryModel>>(
              future: getCategories(),
              builder: (ctx, snapshot) {
                if (!snapshot.hasData)
                  return Container(
                      width: double.infinity,
                      height: 200,
                      child: Center(
                        child: SpinKitThreeBounce(
                            color: Theme.of(context).primaryColor, size: 35),
                      ));

                return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1 / 1.5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (buildContext, i) {
                      CategoryModel cat = snapshot.data[i];

                      return InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ListProdukMarketplace(
                              categoryId: cat.id,
                              categoryName: cat.judul,
                            ),
                          ),
                        ),
                        child: Container(
                            width: double.infinity,
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
                                            imageUrl: cat.thumbnailUrl,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    child: Text(cat.judul,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.black87)),
                                  )
                                ])),
                      );
                    });
              }),
          SizedBox(height: 10),
          Divider(),
          SizedBox(height: 10),
          Text(
            'Produk yang mungkin anda sukai',
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 15),
          FutureBuilder<List<ProdukMarket>>(
            future: getProducts(),
            builder: (ctx, snapshot) {
              if (!snapshot.hasData)
                return Container(
                  width: double.infinity,
                  height: 200,
                  child: Center(
                    child: SpinKitThreeBounce(
                        color: Theme.of(context).primaryColor, size: 35),
                  ),
                );

              return Container(
                height: ((MediaQuery.of(context).size.width - 60) * .25) * 1.5,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data.length,
                  separatorBuilder: (_, i) => SizedBox(width: 10),
                  itemBuilder: (ctx, i) {
                    ProdukMarket produk = snapshot.data[i];

                    return AspectRatio(
                      aspectRatio: 1 / 1.5,
                      child: InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductDetailMarketplace(
                              produk.id,
                              produk.title,
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
                                        imageUrl: produk.thumbnail,
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
                                  produk.title,
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
          )
        ]));
  }
}

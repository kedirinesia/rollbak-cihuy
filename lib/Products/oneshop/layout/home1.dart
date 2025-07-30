// @dart=2.9

import 'dart:convert';

import 'package:badges/badges.dart' as BadgeModule;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile/screen/marketplace/belanja.dart';
import 'package:mobile/Products/oneshop/layout/card_info.dart';
import 'package:mobile/Products/oneshop/layout/components/banner.dart';
import 'package:mobile/Products/oneshop/layout/kirim-saldo.dart';
import 'package:mobile/Products/oneshop/layout/topup.dart';
import 'package:mobile/Products/oneshop/layout/components/menu.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/mp_kategori.dart';
import 'package:mobile/models/mp_produk.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/marketplace/cart.dart';
import 'package:mobile/screen/marketplace/detail_produk.dart';
import 'package:mobile/screen/marketplace/list_produk.dart';
import 'package:mobile/screen/notifikasi/notifikasi.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screen/wd/withdraw.dart';

class PayuniHome extends StatefulWidget {
  @override
  _PayuniHomeState createState() => _PayuniHomeState();
}

class _PayuniHomeState extends State<PayuniHome> with TickerProviderStateMixin {
  AnimationController _rotationController;
  int carouselIndex = 0;
  bool isTransparent = true;
  Animation<Color> _bgColor;
  Animation<Color> _inputColor;
  Animation<Color> _iconColor;
  Animation<Color> _textColor;

  bool isSearch = false;
  TextEditingController searchQuery = TextEditingController();
  ScrollController _scrollController = ScrollController();
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
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
    _bgColor = ColorTween(
      begin: Colors.transparent,
      end: Colors.white,
    ).animate(_animationController);
    _iconColor = ColorTween(
      begin: Colors.white,
      end: Colors.grey,
    ).animate(_animationController);
    _inputColor = ColorTween(
      begin: Colors.white,
      end: Colors.grey.withOpacity(.15),
    ).animate(_animationController);
    _textColor = ColorTween(
      begin: Colors.grey,
      end: Color(0xff4f5beb),
    ).animate(_animationController);
  }

  @override
  void dispose() {
    searchQuery.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Future<List<ProdukMarket>> products() async {
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

  Widget panelSaldo() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 5),
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => TopupPage()),
            ),
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'TopUp',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => WithdrawPage()),
            ),
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tarik',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => KirimSaldo()),
            ),
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Kirim',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 5),
          Expanded(
            flex: 7,
            child: InkWell(
              onTap: () {
                updateUserInfo();
                _rotationController.forward(from: 0);
                showToast(context, 'Berhasil memperbarui saldo');
                setState(() {});
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Saldo',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 3),
                      RotationTransition(
                        turns: Tween(begin: 0.0, end: 1.0)
                            .animate(_rotationController),
                        child: Icon(
                          Icons.refresh_rounded,
                          size: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Theme.of(context).primaryColor,
                        size: 17,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Rp ',
                        style: TextStyle(
                          fontSize: 8,
                        ),
                      ),
                      Text(
                        formatNumber(bloc.user.valueWrapper?.value.saldo),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Poin',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.monetization_on_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 17,
                    ),
                    SizedBox(width: 5),
                    Text(
                      formatNumber(bloc.user.valueWrapper?.value.poin),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget produkWidget() {
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
                    'Produk',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Produk rekomendasi untuk anda',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
              TextButton(
                child: Text('Lihat Semua'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => BelanjaPage()),
                ),
              ),
            ],
          ),
        ),
        FutureBuilder<List<ProdukMarket>>(
          future: products(),
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
                    'Belum Ada Produk',
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
        ),
      ],
    );
  }

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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              updateUserInfo();
              setState(() {});
              showToast(context, 'Berhasil memperbarui data');
            },
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              padding: EdgeInsets.all(0),
              children: [
                BannerComponent(),
                SizedBox(height: 15),
                panelSaldo(),
                SizedBox(height: 10),
                MenuComponent(),
                produkWidget(),
                kategoriWidget(),
                SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Info Terbaru',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Dapatkan info dan promo terbaru dari Kami',
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                CardInfo(),
                SizedBox(height: 35),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            height: (MediaQuery.of(context).padding.top + 56),
            decoration: BoxDecoration(
              color: _bgColor.value,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: TextFormField(
                      controller: searchQuery,
                      keyboardType: TextInputType.text,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: _inputColor.value,
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: isSearch
                            ? IconButton(
                                icon: Icon(Icons.close_rounded),
                                onPressed: () {
                                  setState(() {
                                    searchQuery.clear();
                                    isSearch = false;
                                  });
                                },
                              )
                            : null,
                        hintText: 'Pencarian',
                        hintStyle: TextStyle(color: _textColor.value),
                        contentPadding: EdgeInsets.all(0),
                      ),
                      onEditingComplete: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ListProdukMarketplace(
                              searchQuery: searchQuery.text,
                            ),
                          ),
                        );
                        setState(() {
                          isSearch = (searchQuery.text.length > 0);
                        });
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: ValueListenableBuilder<Box<dynamic>>(
                      valueListenable: Hive.box('cart').listenable(),
                      builder: (context, value, child) {
                        int itemCount = value.values.length;

                        if (itemCount < 1)
                          return Icon(
                            Icons.shopping_cart,
                            color: _iconColor.value,
                          );

                        return BadgeModule.Badge(
                            child: Icon(
                              Icons.shopping_cart,
                              color: _iconColor.value,
                            ),
                            badgeContent: Text(itemCount.toString(),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11)),
                            badgeColor: Colors.red);
                      }),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CartMarketPage()),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.notifications_rounded,
                    color: _iconColor.value,
                  ),
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => Notifikasi())),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

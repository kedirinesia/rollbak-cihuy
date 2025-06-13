// @dart=2.9

import 'dart:async';
import 'dart:convert';

import 'package:badges/badges.dart' as BadgeModule;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile/Products/talentapay/layout/mkp/belanja.dart';
import 'package:mobile/Products/talentapay/layout/card_info.dart';
import 'package:mobile/Products/talentapay/layout/components/banner.dart';
import 'package:mobile/Products/talentapay/layout/kirim-saldo.dart';
import 'package:mobile/Products/talentapay/layout/topup.dart';
import 'package:mobile/Products/talentapay/layout/components/menu.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
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
  int itemCount = 0;

  Timer _timer;

  bool isSearch = false;
  TextEditingController searchQuery = TextEditingController();
  AnimationController _animationController;
  StreamController<int> _streamController = StreamController<int>.broadcast();

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 0),
    );
    getUnreadNotification();

    _timer = Timer.periodic(Duration(seconds: 10), (timer) async {
      await getUnreadNotification();
    });
  }

  @override
  void dispose() {
    searchQuery.dispose();
    _animationController.dispose();
    _rotationController.dispose();
    _streamController.close();
    _timer.cancel();
    super.dispose();
  }

  Future<void> getUnreadNotification() async {
    try {
      http.Response response = await http.get(
          Uri.parse('$apiUrl/outbox/unread/count'),
          headers: {'Authorization': bloc.token.valueWrapper?.value});

      var boxUnreadNotification = Hive.box('unread-notification');

      if (response.statusCode == 200) {
        int unreadNotification = json.decode(response.body)['data'];

        if (boxUnreadNotification.isEmpty) {
          Hive.box('unread-notification').add(unreadNotification);
        } else {
          Hive.box('unread-notification').putAt(0, unreadNotification);
        }

        if (!_streamController.isClosed) {
          _streamController.sink.add(unreadNotification);
          _streamController.close();
        }
      } else {
        if (boxUnreadNotification.isNotEmpty) {
          Hive.box('unread-notification').putAt(0, 0);
        }
      }
    } catch (e) {
      print('Error: $e');
    }
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
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (BuildContext context, Widget child) {
                        return AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) => RotationTransition(
                            turns: _animationController,
                            child: GestureDetector(
                                onTap: () async {
                                  try {
                                    _animationController.fling().then((a) {
                                      _animationController.value = 0;
                                    });

                                    await updateUserInfo();

                                    showToast(
                                        context, 'Berhasil memperbarui saldo');

                                    setState(() {});
                                  } catch (e) {
                                    showToast(
                                        context, 'Gagal memperbarui saldo');
                                  }
                                },
                                child: Icon(
                                  Icons.refresh,
                                  size: 14,
                                  color: Colors.grey,
                                )),
                          ),
                        );
                      },
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
              await updateUserInfo();
              setState(() {});
              showToast(context, 'Berhasil memperbarui data');
            },
            child: ListView(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top +
                      56), // add padding on top to make room for the Row
              // padding: EdgeInsets.all(0),
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
          Positioned(
            // Positioned widget to position the Row on top
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top, right: 6),
              height: (MediaQuery.of(context).padding.top + 56),
              decoration: BoxDecoration(
                color: Colors.white,
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
                          fillColor: Colors.grey.withOpacity(.25),
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
                          hintStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
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
                  configAppBloc.isKasir.valueWrapper?.value
                      ? IconButton(
                          icon: Icon(
                            Icons.storefront_rounded,
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed('/kasir');
                          })
                      : SizedBox(width: 0.0),
                  IconButton(
                    icon: ValueListenableBuilder<Box<dynamic>>(
                        valueListenable: Hive.box('cart').listenable(),
                        builder: (context, value, child) {
                          int itemCount = value.values.length;

                          if (itemCount < 1)
                            return Icon(
                              Icons.shopping_cart,
                              color: Theme.of(context).primaryColor,
                            );

                          return BadgeModule.Badge(
                              child: Icon(
                                Icons.shopping_cart,
                                color: Theme.of(context).primaryColor,
                              ),
                              badgeContent: Text(
                                itemCount.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                              badgeColor: Colors.red);
                        }),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => CartMarketPage()),
                    ),
                  ),
                  StreamBuilder(
                    stream: _streamController.stream,
                    builder: (context, snapshot) {
                      var unreadNotification =
                          Hive.box('unread-notification').values;

                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return unreadNotification.isEmpty ||
                                  unreadNotification.first == 0
                              ? IconButton(
                                  icon: Icon(
                                    Icons.notifications_rounded,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => Notifikasi(),
                                    ),
                                  ),
                                )
                              : IconButton(
                                  icon: BadgeModule.Badge(
                                    badgeContent: Text(
                                      '${unreadNotification.first}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                    badgeColor: Colors.red,
                                    toAnimate: false,
                                    child: Icon(
                                      Icons.notifications_rounded,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => Notifikasi(),
                                    ),
                                  ),
                                );
                        // break;
                        default:
                          return unreadNotification.isEmpty ||
                                  unreadNotification.first == 0
                              ? IconButton(
                                  icon: Icon(
                                    Icons.notifications_rounded,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => Notifikasi(),
                                    ),
                                  ),
                                )
                              : IconButton(
                                  icon: BadgeModule.Badge(
                                    badgeContent: Text(
                                      '${unreadNotification.first}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                    badgeColor: Colors.red,
                                    toAnimate: false,
                                    child: Icon(
                                      Icons.notifications_rounded,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => Notifikasi(),
                                    ),
                                  ),
                                );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

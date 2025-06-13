// @dart=2.9

import 'dart:convert';

import 'package:badges/badges.dart' as BadgeModule;
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile/screen/marketplace/belanja.dart';
import 'package:mobile/Products/payuniblibli/layout/card_info.dart';
import 'package:mobile/Products/payuniblibli/layout/components/banner.dart';
import 'package:mobile/Products/payuniblibli/layout/kirim-saldo.dart';
import 'package:mobile/Products/payuniblibli/layout/topup.dart';
import 'package:mobile/Products/payuniblibli/layout/components/menu.dart';
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
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';
import 'package:mobile/screen/wd/withdraw.dart';

class PayuniHome extends StatefulWidget {
  @override
  _PayuniHomeState createState() => _PayuniHomeState();
}

class _PayuniHomeState extends State<PayuniHome>
    with SingleTickerProviderStateMixin {
  int carouselIndex = 0;
  bool isTransparent = true;
  Animation<Color> _bgColor;
  Animation<Color> _inputColor;
  Animation<Color> _iconColor;

  bool isSearch = false;
  TextEditingController searchQuery = TextEditingController();
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
  }

  @override
  void dispose() {
    searchQuery.dispose();
    _scrollController.dispose();
    _animationController.dispose();
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo',
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
                    'Rekomendasi produk terbaik dari kami',
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
        Flexible(
          child: FutureBuilder<List<ProdukMarket>>(
            future: products(),
            builder: (_, snapshot) {
              if (snapshot.hasError) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  child: Center(
                    child: Text(
                      'Terjadi kesalahan saat memuat produk',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  child: Center(
                    child: SpinKitThreeBounce(
                      color: Theme.of(context).primaryColor,
                      size: 35,
                    ),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: .7,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                ),
                itemBuilder: (_, i) {
                  ProdukMarket produk = snapshot.data.elementAt(i);

                  return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductDetailMarketplace(
                              produk.id,
                              produk.title,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              offset: Offset(1, 1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: produk.thumbnail,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                produk.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Spacer(),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 10,
                                right: 10,
                                bottom: 10,
                              ),
                              child: Text(
                                formatRupiah(produk.price),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget kategoriWidget() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
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
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Kategori produk yang mungkin anda cari',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    )
                  ],
                ),
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BelanjaPage(),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lihat semua',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                      Icon(
                        Icons.navigate_next,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
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
                  height:
                      ((MediaQuery.of(context).size.width - 60) * .25) * 1.5,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                      valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).primaryColor),
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
                height: ((MediaQuery.of(context).size.width - 60) * .35) * 1.5,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data.length,
                  separatorBuilder: (_, i) => SizedBox(width: 10),
                  itemBuilder: (ctx, i) {
                    CategoryModel kategori = snapshot.data[i];

                    return AspectRatio(
                      aspectRatio: 1 / 1.4,
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
                          width: (MediaQuery.of(context).size.width - 60) * .35,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 10,
                                ),
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
      ),
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
      backgroundColor: Colors.grey.shade50,
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
                // panelSaldo(),
                // SizedBox(height: 10),
                MenuComponent(),
                SizedBox(height: 5),
                CardInfo(),
                SizedBox(height: 10),
                kategoriWidget(),
                SizedBox(height: 10),
                produkWidget(),
                SizedBox(height: 5),
                SizedBox(height: 35),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            height: (MediaQuery.of(context).padding.top + 75),
            decoration: BoxDecoration(
              color: _bgColor.value,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TopupPage(),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance_wallet_rounded,
                                color: _iconColor.value,
                                size: 18,
                              ),
                              SizedBox(width: 7),
                              Text(
                                formatRupiah(
                                    bloc.user.valueWrapper?.value.saldo),
                                style: TextStyle(
                                  color: _iconColor.value,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 25,
                        color: _iconColor.value,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.toll_rounded,
                              color: _iconColor.value,
                              size: 18,
                            ),
                            SizedBox(width: 7),
                            Text(
                              formatNumber(bloc.user.valueWrapper?.value.poin) +
                                  ' Poin',
                              style: TextStyle(
                                color: _iconColor.value,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 0),
                          child: TextField(
                            controller: searchQuery,
                            keyboardType: TextInputType.text,
                            textAlignVertical: TextAlignVertical.center,
                            style: TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              isDense: true,
                              isCollapsed: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: _inputColor.value,
                              prefixIcon: Icon(Icons.search, size: 15),
                              suffixIcon: isSearch
                                  ? IconButton(
                                      icon: Icon(Icons.close_rounded, size: 15),
                                      onPressed: () {
                                        setState(() {
                                          searchQuery.clear();
                                          isSearch = false;
                                        });
                                      },
                                    )
                                  : IconButton(
                                      icon: Icon(
                                        Icons.qr_code_scanner_rounded,
                                        size: 20,
                                      ),
                                      onPressed: () async {
                                        String barcode =
                                            (await BarcodeScanner.scan())
                                                .toString();
                                        if (barcode.isNotEmpty) {
                                          return Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  TransferByQR(barcode),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                              hintText: 'Pencarian',
                              hintStyle: TextStyle(color: Colors.grey),
                              contentPadding: EdgeInsets.zero,
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
                        icon: Icon(
                          Icons.notifications_rounded,
                          color: _iconColor.value,
                        ),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => Notifikasi(),
                          ),
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
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
                                badgeContent: Text(
                                  itemCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                                badgeColor: Colors.red,
                              );
                            }),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CartMarketPage(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

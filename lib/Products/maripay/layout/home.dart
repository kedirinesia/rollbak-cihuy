// @dart=2.9

import 'dart:convert';

import 'package:badges/badges.dart' as BadgeModule;
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile/Products/maripay/layout/home_model.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/Products/maripay/layout/card_info.dart';
import 'package:mobile/component/carousel-depan.dart';
import 'package:mobile/Products/maripay/layout/menudepan.dart';
import 'package:mobile/component/rewards.dart';
import 'package:mobile/models/mp_kategori.dart';
import 'package:mobile/models/mp_produk.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/marketplace/cart.dart';
import 'package:mobile/screen/marketplace/detail_produk.dart';
import 'package:mobile/screen/marketplace/list_produk.dart';
import 'package:mobile/screen/profile/print_settings.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screen/wd/withdraw.dart';

class Home4App extends StatefulWidget {
  @override
  _Home4AppState createState() => _Home4AppState();
}

class _Home4AppState extends Home4Model {
  AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(duration: Duration(seconds: 3), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  Future<List<CategoryModel>> getCategories() async {
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
    return SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          ListView(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 70.0,
                margin: EdgeInsets.only(top: 142),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.5),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      tileMode: TileMode.clamp,
                      colors: <Color>[
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(.4)
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              MenuDepan(grid: 5, baris: 2),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Belanja Produk',
                          style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 3),
                        InkWell(
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => ListProdukMarketplace())),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Lihat Semua ',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              Icon(
                                Icons.navigate_next,
                                color: Theme.of(context).primaryColor,
                                size: 18,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CartMarketPage(),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Keranjang ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          ValueListenableBuilder<Box<dynamic>>(
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
                        ],
                      ),
                    ),
                  ],
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
                    height:
                        ((MediaQuery.of(context).size.width - 60) * .25) * 1.5,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 15),
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
                              width: (MediaQuery.of(context).size.width - 60) *
                                  .25,
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
              SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Hadiah Menarik',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              RewardComponent(),
              SizedBox(height: 10.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Kategori Produk',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
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
                    height:
                        ((MediaQuery.of(context).size.width - 60) * .25) * 1.5,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      itemCount: snapshot.data.length,
                      separatorBuilder: (_, __) => SizedBox(width: 10),
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
                              width: (MediaQuery.of(context).size.width - 60) *
                                  .25,
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
                                          borderRadius:
                                              BorderRadius.circular(5),
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
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Info Terbaru',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              CardInfo(),
              SizedBox(height: 40.0),
            ],
          ),
          Container(
              width: double.infinity,
              height: 80.0,
              margin: EdgeInsets.only(top: 142),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      tileMode: TileMode.clamp,
                      colors: <Color>[
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(.4)
                      ],
                    )),
                height: 160,
              )),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0)),
                color: Colors.white),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: 10.0),
              CarouselDepan(
                marginBottom: 0.0,
                viewportFraction: .75,
                aspectRatio: 2.8,
              ),
              Container(
                padding: EdgeInsets.only(
                    left: 5.0, right: 5.0, top: 0.0, bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        // color: Colors.red,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              // margin: EdgeInsets.only(top: 10.0),
                              child: AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) => RotationTransition(
                                  turns: _animationController,
                                  child: IconButton(
                                    icon: Icon(Icons.refresh, size: 30.0),
                                    color: Theme.of(context).primaryColor,
                                    onPressed: () {
                                      _animationController.fling().then((a) {
                                        _animationController.value = 0;
                                      });
                                      updateUserInfo();
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 0.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                      'Hi, ${bloc.username.valueWrapper?.value}',
                                      style: TextStyle(fontSize: 10.0)),
                                  SizedBox(height: 5.0),
                                  Text(
                                      formatNominal(
                                          bloc.saldo.valueWrapper?.value),
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      'Points ' +
                                          formatNominal(
                                              bloc.poin.valueWrapper?.value),
                                      style: TextStyle(fontSize: 10.0))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 20.0, left: 10.0),
                    //   child: InkWell(
                    //     onTap: () =>
                    //         Navigator.of(context).pushNamed('/withdraw'),
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.center,
                    //       children: <Widget>[
                    //         SizedBox(height: 5.0),
                    //         Icon(Icons.call_missed_outgoing,
                    //             color: Colors.black, size: 20.0),
                    //         SizedBox(height: 5.0),
                    //         Text('Withdraw',
                    //             style: TextStyle(
                    //                 fontSize: 10.0, color: Colors.black))
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(width: 20.0),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, left: 10.0),
                      child: InkWell(
                        onTap: () => Navigator.of(context).pushNamed('/myqr'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 5.0),
                            CachedNetworkImage(
                              imageUrl:
                                  'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/assets%2Ficons%2Fqr-code.png?alt=media&token=a2d4ead5-b4ed-498d-861b-1f9f92ba1a94',
                              width: 20,
                            ),
                            SizedBox(height: 5.0),
                            Text(
                              'My QR',
                              style: TextStyle(
                                fontSize: 10.0,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 20.0),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, left: 10.0),
                      child: InkWell(
                        onTap: () => Navigator.of(context).pushNamed('/topup'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 5.0),
                            Image.asset('assets/img/money.png',
                                fit: BoxFit.cover, width: 20.0),
                            SizedBox(height: 5.0),
                            Text('Topup',
                                style: TextStyle(
                                    fontSize: 10.0, color: Colors.black))
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 20.0),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, left: 10.0),
                      child: InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => WithdrawPage(),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 5.0),
                            CachedNetworkImage(
                              imageUrl:
                                  'https://dokumen.payuni.co.id/logo/maripay/bank.png',
                              width: 20,
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text('Transfer Bank',
                                style: TextStyle(
                                    fontSize: 10.0, color: Colors.black))
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, left: 10.0),
                      child: InkWell(
                        onTap: () => showModalBottomSheet(
                            context: context,
                            builder: (context) => PanelSemuaMenu()),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 5.0),
                            Icon(Icons.list,
                                color: Theme.of(context).primaryColor),
                            SizedBox(height: 5.0),
                            Text('Semua',
                                style: TextStyle(
                                    fontSize: 10.0, color: Colors.black))
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10.0),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class PanelSemuaMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
      child: GridView(
        shrinkWrap: true,
        primary: false,
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          Container(
            // color: Colors.red.withOpacity(.1),
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed('/transfer'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: LinearGradient(
                          begin: AlignmentDirectional.topCenter,
                          end: AlignmentDirectional.bottomEnd,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(.1),
                            Theme.of(context).primaryColor.withOpacity(.1),
                            Theme.of(context).primaryColor.withOpacity(.1)
                          ]),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: CachedNetworkImage(
                        imageUrl:
                            'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/assets%2Ficons%2Ftransfer%20(1).png?alt=media&token=ebd17176-58cf-4b5a-870e-88f718f1b192',
                        width: 40.0,
                        fit: BoxFit.cover),
                  ),
                  SizedBox(height: 10.0),
                  Flexible(
                    child: Text(
                      'Transfer Saldo',
                      style: TextStyle(
                          fontSize: 10.0,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.bold),
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            // color: Colors.red.withOpacity(.1),
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PrintSettingsPage(),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: LinearGradient(
                          begin: AlignmentDirectional.topCenter,
                          end: AlignmentDirectional.bottomEnd,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(.1),
                            Theme.of(context).primaryColor.withOpacity(.1),
                            Theme.of(context).primaryColor.withOpacity(.1)
                          ]),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.print_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Flexible(
                    child: Text(
                      'Atur Printer',
                      style: TextStyle(
                          fontSize: 10.0,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.bold),
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            // color: Colors.red.withOpacity(.1),
            child: InkWell(
              onTap: () async {
                String barcode = (await BarcodeScanner.scan()).toString();
                print(barcode);
                if (barcode.isNotEmpty) {
                  return Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => TransferByQR(barcode)));
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: LinearGradient(
                          begin: AlignmentDirectional.topCenter,
                          end: AlignmentDirectional.bottomEnd,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(.1),
                            Theme.of(context).primaryColor.withOpacity(.1),
                            Theme.of(context).primaryColor.withOpacity(.1)
                          ]),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: CachedNetworkImage(
                        imageUrl:
                            'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/assets%2Ficons%2Fqr-code-scan.png?alt=media&token=e6b8db9f-d654-4d81-8437-29e91009e636',
                        width: 40.0,
                        fit: BoxFit.cover),
                  ),
                  SizedBox(height: 10.0),
                  Flexible(
                    child: Text(
                      'Scan',
                      style: TextStyle(
                          fontSize: 10.0,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.bold),
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            // color: Colors.red.withOpacity(.1),
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed('/withdraw'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: LinearGradient(
                          begin: AlignmentDirectional.topCenter,
                          end: AlignmentDirectional.bottomEnd,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(.1),
                            Theme.of(context).primaryColor.withOpacity(.1),
                            Theme.of(context).primaryColor.withOpacity(.1)
                          ]),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: CachedNetworkImage(
                        imageUrl:
                            'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/assets%2Ficons%2Fmoney.png?alt=media&token=fea2189f-04f8-43d9-bc0f-1f1d386c7de4',
                        width: 40.0,
                        fit: BoxFit.cover),
                  ),
                  SizedBox(height: 10.0),
                  Flexible(
                    child: Text(
                      'Withdraw',
                      style: TextStyle(
                          fontSize: 10.0,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.bold),
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 5,
            childAspectRatio: 0.8,
            mainAxisSpacing: 10.0),
      ),
    );
  }
}

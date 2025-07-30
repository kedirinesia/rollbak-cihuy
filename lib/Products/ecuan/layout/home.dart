// @dart=2.9

import 'dart:convert';

import 'package:badges/badges.dart' as BadgeModule;
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/component/card_info.dart';
import 'package:mobile/component/carousel-depan.dart';
import 'package:mobile/component/menudepan.dart';
import 'package:mobile/component/rewards.dart';
import 'package:mobile/models/mp_kategori.dart';
import 'package:mobile/models/mp_produk.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/marketplace/belanja.dart';
import 'package:mobile/screen/marketplace/cart.dart';
import 'package:mobile/screen/marketplace/detail_produk.dart';
import 'package:mobile/screen/marketplace/list_produk.dart';
import 'package:mobile/screen/profile/reward/list_reward.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';
import 'package:mobile/screen/wd/withdraw.dart';
import 'package:http/http.dart' as http;

class Home1App extends StatefulWidget {
  @override
  _Home1AppState createState() => _Home1AppState();
}

class _Home1AppState extends State<Home1App>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    );
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

  Widget produkWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 3),
                  InkWell(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
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
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => CartMarketPage())),
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
          future: products(),
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
        ),
        InkWell(
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => BelanjaPage())),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Theme.of(context).primaryColorLight.withOpacity(.5),
            ),
            child: Center(
              child: Text(
                'Belanja Sekarang',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
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
          future: categories(),
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
                                      fontSize: 11, color: Colors.black87)),
                            )
                          ])),
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
          image: configAppBloc.iconApp.valueWrapper?.value['texture'] != null
              ? DecorationImage(
                  image: CachedNetworkImageProvider(
                      configAppBloc.iconApp.valueWrapper?.value['texture']),
                  fit: BoxFit.fitWidth)
              : null),
      child: SingleChildScrollView(
          child: Stack(
        children: <Widget>[
          configAppBloc.brandId.valueWrapper?.value == null
              ? Container(
                  width: double.infinity,
                  // height: 210,
                  child: CachedNetworkImage(
                      imageUrl:
                          'https://dokumen.payuni.co.id/logo/ecuan/background.png',
                      fit: BoxFit.cover))
              : Container(),
          // configAppBloc.brandId.value == null ? Container(
          //     width: double.infinity,
          //     height: MediaQuery.of(context).size.height,
          //     child:
          //         Image.asset('assets/img/sarinu/15.2.png', fit: BoxFit.fitWidth)) : Container(),
          configAppBloc.brandId.valueWrapper?.value == null
              ? Container()
              : Container(
                  width: double.infinity,
                  height: 210.0,
                  decoration: BoxDecoration(
                      borderRadius: new BorderRadius.only(
                          bottomLeft: Radius.elliptical(150, 50),
                          bottomRight: Radius.elliptical(150, 50)),
                      gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(.6)
                          ],
                          begin: AlignmentDirectional.topCenter,
                          end: AlignmentDirectional.bottomCenter)),
                  child: Container(),
                ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10.0)),
              child: ListView(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                children: <Widget>[
                  SizedBox(height: 20.0),
                  MenuKomisi(animationController),
                  Divider(),
                  MenuGrid(),
                  // SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text('Produk',
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 20.0)),
                  ),
                  MenuDepan(grid: 5),
                  CarouselDepan(),
                  SizedBox(height: 15),
                  produkWidget(),
                  SizedBox(height: 15),
                  kategoriWidget(),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text('Info Terbaru',
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 20.0)),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                        left: 20, right: 20, bottom: 20, top: 5),
                    child: Text(
                        'Mengenal lebih jauh aplikasi ${configAppBloc.namaApp.valueWrapper?.value}'),
                  ),
                  CardInfo(),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(top: 20, left: 20),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Hadiah Unggulan',
                              style: TextStyle(
                                  color: Colors.grey.shade700, fontSize: 20.0)),
                          TextButton(
                              child: Row(children: <Widget>[
                                Text('Lainnya',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor)),
                                SizedBox(width: 5),
                                Icon(Icons.navigate_next,
                                    color: Theme.of(context).primaryColor,
                                    size: 15),
                              ]),
                              onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => ListReward())))
                        ]),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: Text(
                        'Hadiah akan diberikan ke member ${configAppBloc.namaApp.valueWrapper?.value}'),
                  ),
                  RewardComponent(),
                  SizedBox(height: 50.0),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }
}

class MenuGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 30.0, right: 10.0, left: 10.0),
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(.2),
                offset: Offset(0, 10),
                blurRadius: 10.0)
          ]),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          InkWell(
            onTap: () async {
              var barcode = await BarcodeScanner.scan();
              print(barcode);
              // if (barcode.isNotEmpty) {
              return Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => TransferByQR(barcode.rawContent)));
              // }
            },
            child: Container(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    child: CachedNetworkImage(
                        imageUrl:
                            'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fsarinu%2Fqr-code%20(1).png?alt=media&token=def5bcd4-1f6d-4532-a1b1-9e7bf06f2c48',
                        color: Theme.of(context).primaryColor,
                        width: 20.0),
                    radius: 20.0,
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(.1),
                  ),
                  SizedBox(height: 5.0),
                  Text('Scan',
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Theme.of(context).primaryColor))
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              return Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => WithdrawPage()));
            },
            child: Container(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    child: CachedNetworkImage(
                        imageUrl:
                            'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fsarinu%2Fwithdraw%20(1).png?alt=media&token=66074a4f-6db5-4361-b0c7-9b499312fbf6',
                        width: 20.0),
                    radius: 20.0,
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(.1),
                  ),
                  SizedBox(height: 5.0),
                  Text('Transfer Bank',
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Theme.of(context).primaryColor))
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              return Navigator.of(context).pushNamed('/transfer');
            },
            child: Container(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    child: Image.asset('assets/img/next.png', width: 20.0),
                    radius: 20.0,
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(.1),
                  ),
                  SizedBox(height: 5.0),
                  Text('Kirim Saldo',
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Theme.of(context).primaryColor))
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed('/komisi');
            },
            child: Container(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    child: CachedNetworkImage(
                        imageUrl: iconApp['iconTransfer'] ?? '', width: 20.0),
                    radius: 20.0,
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(.1),
                  ),
                  SizedBox(height: 5.0),
                  Text('Komisi',
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Theme.of(context).primaryColor))
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              return Navigator.of(context).pushNamed('/customer-service');
            },
            child: Container(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    child: Image.asset('assets/img/people.png', width: 20.0),
                    radius: 20.0,
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(.1),
                  ),
                  SizedBox(height: 5.0),
                  Text('Bantuan',
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Theme.of(context).primaryColor))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class MenuKomisi extends StatefulWidget {
  final AnimationController _animationController;
  MenuKomisi(this._animationController);
  @override
  _MenuKomisiState createState() => _MenuKomisiState();
}

class _MenuKomisiState extends State<MenuKomisi> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 10.0, left: 10.0),
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(.1),
          borderRadius: BorderRadius.circular(10.0)),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: ListTile(
                title: Text(configAppBloc.labelSaldo.valueWrapper?.value,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Rp',
                        style: TextStyle(fontSize: 10.0, color: Colors.white)),
                    Text(
                        ' ' +
                            NumberFormat.decimalPattern('id')
                                .format(bloc.saldo.valueWrapper?.value),
                        style: TextStyle(fontSize: 20.0, color: Colors.white))
                  ],
                ),
                trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            AnimatedBuilder(
                              animation: widget._animationController,
                              builder: (BuildContext context, Widget child) {
                                return RotationTransition(
                                    turns: widget._animationController,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.refresh,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        widget._animationController
                                            .fling()
                                            .then((a) {
                                          widget._animationController.value = 0;
                                        });

                                        updateUserInfo();
                                        setState(() {});
                                      },
                                    ));
                              },
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pushNamed('/topup');
                              },
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 10.0),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  child: Text('Topup',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.0))),
                            ),
                          ],
                        ),
                      )
                    ])),
          )
        ],
      ),
    );
  }
}

// @dart=2.9

import 'dart:convert';

import 'package:badges/badges.dart' as BadgeModule;
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/Products/paymobileku/layout/qris/qris_page.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/screen/marketplace/belanja.dart';
import 'package:mobile/Products/paymobileku/layout/card_info.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/Products/paymobileku/layout/components/carousel-depan.dart';
import 'package:mobile/Products/paymobileku/layout/menudepan.dart';
import 'package:mobile/models/mp_kategori.dart';
import 'package:mobile/models/mp_produk.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/marketplace/cart.dart';
import 'package:mobile/screen/marketplace/detail_produk.dart';
import 'package:mobile/screen/marketplace/list_produk.dart';
import 'package:mobile/screen/profile/reward/list_reward.dart';
import 'package:mobile/Products/paymobileku/layout/topup.dart';
import 'package:mobile/screen/transfer_saldo/transfer_by_qr.dart';
import 'package:mobile/Products/paymobileku/layout/transfer.dart';
import 'package:mobile/screen/wd/withdraw.dart';
import 'package:mobile/component/rewards.dart';
import 'package:marquee/marquee.dart';

class PakeAjaHome extends StatefulWidget {
  @override
  _PakeAjaHomeState createState() => _PakeAjaHomeState();
}

class _PakeAjaHomeState extends State<PakeAjaHome> {
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

  Widget topPanel() {
    BorderRadius radius = BorderRadius.circular(6);

    return Container(
      width: double.infinity,
      height: 70,
      color: Color(0xFFDDFFBC),
      padding: EdgeInsets.all(10),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TopupPage(),
                ),
              ),
              child: Container(
                height: double.infinity,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: radius,
                ),
                child: Center(
                  child: Text(
                    'Top Up',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            VerticalDivider(
              indent: 5,
              endIndent: 5,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Image.asset('assets/img/paymobileku/icon_ewallet.png'),
                    SizedBox(width: 5),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatRupiah(bloc.user.valueWrapper.value.saldo),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Saldo Paymobileku',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            VerticalDivider(
              indent: 5,
              endIndent: 5,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Image.asset('assets/img/paymobileku/icon_ewallet.png'),
                    SizedBox(width: 5),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatRupiah(bloc.user.valueWrapper.value.komisi),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Komisi Tersedia',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget header() {
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => QrisPage()));
            },
            // onTap: () async {
            //   String barcode = (await BarcodeScanner.scan()).rawContent;
            //   if (barcode.isNotEmpty) {
            //     return Navigator.of(context).push(
            //       MaterialPageRoute(
            //         builder: (_) => TransferByQR(barcode),
            //       ),
            //     );
            //   }
            // },
            child: Container(
              width: 50.0,
              height: 50.0,
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/img/paymobileku/QRIS.png',
                    width: 30,
                    height: 30,
                  ),
                  Text(
                    'QRIS',
                    style: TextStyle(
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              return Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TransferOptionPage(),
                ),
              );
            },
            child: Container(
              width: 50.0,
              height: 50.0,
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Column(
                children: [
                  Image.asset(
                    'assets/img/paymobileku/icon_price.png',
                    width: 30,
                    height: 30,
                  ),
                  Text(
                    'Transfer',
                    style: TextStyle(
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 1.0,
            height: 40.0,
            color: Colors.grey.shade400,
          ),
          Expanded(
            child: ListTile(
              dense: true,
              visualDensity: VisualDensity(vertical: -4),
              title: Text(
                'PayMobileku Point',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
              subtitle: Text(
                formatNumber(bloc.user.valueWrapper.value.poin) + ' Pts',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: TextButton(
                child: Text(
                  'Redeem Sekarang',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ListReward(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget marquee() {
    return Container(
      height: 35.0,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(0.0),
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 5,
        ),
      ),
      child: Marquee(
        text: configAppBloc.info.valueWrapper.value.marquee != null
            ? configAppBloc.info.valueWrapper.value.marquee.message
            : 'SEPUTAR INFO : Selalu waspada terhadap segala bentuk PENIPUAN, pihak kami tidak pernah telp / meminta kode OTP apapun. Biasakan SAVE kontak kami 08980000073 atau bisa ke LIVECHAT',
        style: TextStyle(color: Colors.white),
        blankSpace: 100,
      ),
    );
  }

  Widget listProducts() {
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
      ],
    );
  }

  Widget bannerInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            'PayMobileku Info',
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Text(
            'Lihat Info Menarik dari PayMobileku Disini',
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: CardInfo(),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            'Dapatkan Hadiah Dari PayMobileku',
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Text(
            'Kumpulkan Poin Kamu dan Tukarkan dengan Reward yang Tersedia Dari PayMobileku',
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        //   Container(
        //   padding: const EdgeInsets.all(10.0),
        //   child: ListTile(
        //     title: Text('Dapat Hadiah dari Payku',
        //         style: TextStyle(
        //             fontSize: 15.0,
        //             fontWeight: FontWeight.bold)),
        //     subtitle: Text(
        //         'Kumpulkan Poin Kamu dan Tukarkan dengan Reward yang Tersedia Dari Payku',
        //         style: TextStyle(
        //             fontSize: 12.0, color: Colors.grey[500], fontWeight: FontWeight.normal)),
        //   ),
        // ),
        SizedBox(height: 20.0),
        RewardComponent(),
        SizedBox(height: 50.0)
      ],
    );
  }

  Widget listCategories() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Kategori Produk',
            style: TextStyle(fontWeight: FontWeight.bold),
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
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        http.Response response = await http.get(
          Uri.parse('$apiUrl/user/info'),
          headers: {
            'Authorization': bloc.token.valueWrapper?.value,
          },
        );

        UserModel user = UserModel.fromJson(json.decode(response.body)['data']);
        bloc.user.add(user);
        setState(() {});
      },
      child: ListView(
        children: [
          topPanel(),
          header(),
          SizedBox(height: 20),
          CarouselDepan(
            viewportFraction: .65,
            aspectRatio: 3 / 1,
          ),
          MenuDepan(grid: 5, baris: 3, gradient: true),
          // marquee(),
          // SizedBox(height: 3),
          configAppBloc.isMarketplace.valueWrapper.value
              ? listProducts()
              : SizedBox(height: 0.0),
          SizedBox(height: 10),
          configAppBloc.isMarketplace.valueWrapper.value
              ? InkWell(
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => BelanjaPage())),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color:
                          Theme.of(context).primaryColorLight.withOpacity(.5),
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
                )
              : SizedBox(height: 0.0),
          SizedBox(height: 10),
          bannerInfo(),
          SizedBox(height: 35),
        ],
      ),
    );
  }
}

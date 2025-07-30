// @dart=2.9

import 'dart:convert';

import 'package:badges/badges.dart' as BadgeModule;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/mp_produk_detail.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/marketplace/order.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as SlideDialog;
import 'package:mobile/models/mp_produk.dart';
import 'package:mobile/models/mp_produk_cart.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/marketplace/cart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;


class ProductDetailMarketplace extends StatefulWidget {
  final String id;
  final String title;
  ProductDetailMarketplace(this.id, this.title);

  @override
  _ProductDetailMarketplaceState createState() =>
      _ProductDetailMarketplaceState();
}

class _ProductDetailMarketplaceState extends State<ProductDetailMarketplace> {
  int currentImage = 0;
  TextEditingController productAmount = TextEditingController();
  bool loading = true;
  ProdukDetailMarket product;

  @override
  void initState() {
    getProduct();
    super.initState();
    analitycs.pageView('/detail/produk', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Detail Produk Marketplace',
    });
  }

  @override
  void dispose() {
    productAmount.dispose();
    super.dispose();
  }

  Future<void> getProduct() async {
    try {
      http.Response response = await http.get(
          Uri.parse('$apiUrl/market/product/${widget.id}'),
          headers: {'Authorization': bloc.token.valueWrapper?.value});

      if (response.statusCode == 200) {
        product =
            ProdukDetailMarket.fromJson(json.decode(response.body)['data']);
        print(product.images);

        setState(() {
          loading = false;
        });
      } else {
        showToast(context, 'Gagal mengambil data produk');
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('ERROR: $e');
      showToast(context, 'Gagal mengambil data produk');
      Navigator.of(context).pop();
    }
  }

  Future<List<ProdukMarket>> getProducts() async {
    try {
      http.Response response = await http.get(
          Uri.parse('$apiUrl/market/products?limit=10'),
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

  Future<void> addToCart() async {
    bool isExists = false;

    if (product.stock <= 0) {
      showToast(context, 'Stok untuk produk ini sedang kosong');
      return;
    }

    Hive.box('cart').values.forEach((el) {
      ProdukCartMarket produk = ProdukCartMarket.parse(el);

      if (produk.id == product.id) {
        el['count']++;
        isExists = true;
      }
    });

    if (!isExists) {
      Hive.box('cart')
          .add(ProdukCartMarket.create(produk: product, count: 1).toMap())
          .then((value) {
        showToast(context, "Berhasil menambahkan produk",
            duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
      }).catchError((err) {
        showToast(context, "Gagal menambahkan produk",
            duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
        print('ADD TO CART ERROR: ${err.toString()}');
      });
    }
  }

  Future<void> buyProduct() async {
    if (product.stock <= 0) {
      showToast(context, 'Stok untuk produk ini sedang kosong');
      return;
    }

    productAmount.text = "1";

    bool status = await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Jumlah Produk'),
          content: TextField(
            controller: productAmount,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              child: Text(
                'BATAL',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            TextButton(
              child: Text(
                'BELI',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
        );
      },
    );

    if (!(status ?? false)) return;
    if (int.parse(productAmount.text) < 1) {
      showToast(context, 'Produk tidak boleh kurang dari 1 item');
      return;
    }
    int amount = int.parse(productAmount.text) ?? 1;
    ProdukCartMarket produk =
        ProdukCartMarket.create(produk: product, count: amount);

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => OrderPage(products: [produk])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), elevation: 0, actions: [
        IconButton(
            icon: ValueListenableBuilder<Box<dynamic>>(
                valueListenable: Hive.box('cart').listenable(),
                builder: (context, value, child) {
                  int itemCount = value.values.length;

                  if (itemCount < 1) return Icon(Icons.shopping_cart);

                  return BadgeModule.Badge(
                      child: Icon(Icons.shopping_cart),
                      badgeContent: Text(itemCount.toString(),
                          style: TextStyle(color: Colors.white, fontSize: 11)),
                      badgeColor: Colors.red);
                }),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => CartMarketPage())))
      ]),
      body: loading
          ? Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(15),
              child: SpinKitThreeBounce(
                color: Theme.of(context).primaryColor,
                size: 25,
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      product.images.length == 0
                          ? AspectRatio(
                              aspectRatio: 4 / 2.1,
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                padding: EdgeInsets.all(15),
                                color: Colors.grey.withOpacity(.3),
                                child: Center(
                                  child: Text(
                                    'TIDAK ADA GAMBAR',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Stack(children: [
                              CarouselSlider(
                                options: CarouselOptions(
                                  aspectRatio: 4 / 2.1,
                                ),
                                items: product.images.map((p) {
                                  String url = p;

                                  return CachedNetworkImage(
                                    imageUrl: url,
                                    fit: BoxFit.cover,
                                  );
                                }).toList(),
                              ),
                              Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(.3),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                              '${currentImage + 1}/${product.images.length}',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11)))))
                            ]),
                      SizedBox(height: 20),
                      Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: Text(
                            product.title,
                            maxLines: 2,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          )),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Text(formatRupiah(product.price),
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold))),
                      SizedBox(height: 10),
                      Divider(),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        child: Table(
                          columnWidths: {
                            0: FractionColumnWidth(.3),
                            1: FractionColumnWidth(.7),
                          },
                          children: [
                            TableRow(children: [
                              Text('Berat',
                                  style: TextStyle(color: Colors.grey)),
                              Text('${formatNumber(product.weight)} gram')
                            ]),
                            TableRow(children: [
                              Text('Stok',
                                  style: TextStyle(color: Colors.grey)),
                              Text(formatNumber(product.stock))
                            ]),
                          ],
                        ),
                      ),
                      Divider(),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text('Deskripsi Produk',
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10, left: 15, right: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.description,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 10),
                            ButtonTheme(
                              minWidth: double.infinity,
                              buttonColor: Theme.of(context).primaryColor,
                              textTheme: ButtonTextTheme.primary,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              child: OutlinedButton(
                                child: Text(
                                    'Lihat Deskripsi Lengkap'.toUpperCase()),
                                // textColor: Theme.of(context).primaryColor,
                                // borderSide: BorderSide.none,
                                onPressed: () {
                                  SlideDialog.showSlideDialog(
                                    context: context,
                                    child: Expanded(
                                      child: ListView(
                                        padding: EdgeInsets.all(15),
                                        children: [Text(product.description)],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(15),
                        margin: EdgeInsets.only(bottom: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(),
                            SizedBox(height: 10),
                            Text(
                              'Produk lainnya',
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
                                          color: Theme.of(context).primaryColor,
                                          size: 35),
                                    ),
                                  );

                                return Container(
                                  height: ((MediaQuery.of(context).size.width -
                                              60) *
                                          .25) *
                                      1.5,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: snapshot.data.length,
                                    separatorBuilder: (_, i) =>
                                        SizedBox(width: 10),
                                    itemBuilder: (ctx, i) {
                                      ProdukMarket produk = snapshot.data[i];

                                      return AspectRatio(
                                        aspectRatio: 1 / 1.5,
                                        child: InkWell(
                                          onTap: () =>
                                              Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ProductDetailMarketplace(
                                                produk.id,
                                                produk.title,
                                              ),
                                            ),
                                          ),
                                          child: Container(
                                            width: (MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    60) *
                                                .25,
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.grey.withOpacity(.08),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                AspectRatio(
                                                  aspectRatio: 1,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      child: CachedNetworkImage(
                                                          imageUrl:
                                                              produk.thumbnail,
                                                          fit: BoxFit.cover,
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 5,
                                                      horizontal: 10),
                                                  child: Text(
                                                    produk.title,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(.3),
                          offset: Offset(0, -5),
                          blurRadius: 25,
                        )
                      ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ButtonTheme(
                          minWidth: double.infinity,
                          buttonColor: Theme.of(context).primaryColor,
                          textTheme: ButtonTextTheme.primary,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          child: MaterialButton(
                            child: Text('BELI'),
                            onPressed: buyProduct,
                            elevation: 0,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ButtonTheme(
                          minWidth: double.infinity,
                          buttonColor: Theme.of(context).primaryColor,
                          textTheme: ButtonTextTheme.primary,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          child: OutlinedButton(
                            child: Text('+ KERANJANG'),
                            // textColor: Theme.of(context).primaryColor,
                            // borderSide: BorderSide(
                            //     color: Theme.of(context).primaryColor),
                            onPressed: addToCart,
                          ),
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

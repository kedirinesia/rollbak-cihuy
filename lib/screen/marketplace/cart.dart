// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/mp_produk_cart.dart';
import 'package:mobile/models/mp_produk_detail.dart';
import 'package:mobile/modules.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile/screen/marketplace/order.dart';
import 'package:http/http.dart' as http;

class CartMarketPage extends StatefulWidget {
  @override
  _CartMarketPageState createState() => _CartMarketPageState();
}

class _CartMarketPageState extends State<CartMarketPage> {
  TextEditingController qty = TextEditingController();

  @override
  void initState() {
    super.initState();
    updateHarga();
  }

  @override
  void dispose() {
    qty.dispose();
    super.dispose();
  }

  void subtract(int index) {
    ProdukCartMarket produk =
        ProdukCartMarket.parse(Hive.box('cart').getAt(index));
    if (produk.count > 0) produk.count--;

    Hive.box('cart').putAt(index, produk.toMap());
  }

  void add(int index) {
    ProdukCartMarket produk =
        ProdukCartMarket.parse(Hive.box('cart').getAt(index));
    produk.count++;

    Hive.box('cart').putAt(index, produk.toMap());
  }

  Future<void> changeQuantity(int index) async {
    ProdukCartMarket produk =
        ProdukCartMarket.parse(Hive.box('cart').getAt(index));
    qty.text = produk.count.toString();
    bool status = await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
                content: TextFormField(
                    controller: qty,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Jumlah')),
                actions: [
                  TextButton(
                      child: Text(
                        'BATAL',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(false)),
                  TextButton(
                      child: Text(
                        'UBAH',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(true))
                ]));

    if (!(status ?? false)) return;

    produk.count = int.parse(qty.text);
    Hive.box('cart').putAt(index, produk.toMap());
  }

  Future<bool> checkStock(ProdukCartMarket produk) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$apiUrl/market/product/${produk.id}'),
        headers: {
          'Authorization': bloc.token.valueWrapper?.value,
        },
      );

      if (response.statusCode == 200) {
        ProdukDetailMarket product =
            ProdukDetailMarket.fromJson(json.decode(response.body)['data']);

        if (product.stock < produk.count) {
          showToast(context,
              'Stok tidak mencukupi untuk produk \'${product.title}\'');
          return false;
        } else {
          return true;
        }
      } else {
        showToast(context, 'Gagal mengambil data produk');
        return false;
      }
    } catch (e) {
      print('ERROR: $e');
      showToast(context, 'Gagal mengambil data produk');
      return false;
    }
  }

  Future<int> fetchHargaBaru(String productId) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$apiUrl/market/product/$productId'),
        headers: {
          'Authorization': bloc.token.valueWrapper?.value,
        },
      );
      print("Response from fetchHargaBaru: ${response.body}");

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print("Harga baru diperoleh: ${data['data']['harga_jual']}");
        return data['data']['harga_jual'];
      } else {
        print("Error fetching new price: ${response.statusCode}");
        return null;
      }
    } catch (error) {
      print("Exception in fetchHargaBaru: $error");
      return null;
    }
  }

  Future<void> updateHarga() async {
    print('SUDAH SAMPAI SINI!');
    var cartBox = Hive.box('cart');

    for (int i = 0; i < cartBox.length; i++) {
      try {
        var item = cartBox.getAt(i);
        ProdukCartMarket produk = ProdukCartMarket.parse(item);
        int currentPrice = await fetchHargaBaru(produk.id);

        if (currentPrice != null && produk.price != currentPrice) {
          ProdukCartMarket updatedProduk = ProdukCartMarket.create(
            produk: ProdukDetailMarket(
                id: produk.id,
                title: produk.title,
                description: produk.description,
                thumbnail: produk.thumbnail,
                weight: produk.weight,
                price: currentPrice, // Harga baru
                stock: produk.stock,
                images: produk.images),
            count: produk.count,
          );

          cartBox.putAt(i, updatedProduk.toMap());
        }
      } catch (error) {
        print("Error updating price for item $i: $error");
      }
    }
  }

  void checkout() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderPage(
          products: Hive.box('cart')
              .values
              .map((e) => ProdukCartMarket.parse(e))
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Keranjang'), elevation: 0),
      body: Hive.box('cart').values.length == 0
          ? Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(20),
              child: Center(
                  child: Text('Keranjang masih kosong'.toUpperCase(),
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 13))),
            )
          : Column(
              children: [
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: Hive.box('cart').listenable(),
                    builder: (context, Box<dynamic> box, _) {
                      print("Current cart items: ${box.values.toList()}");
                      if (box.length == 0) return Container();

                      return ListView.separated(
                        padding: EdgeInsets.all(15),
                        itemCount: box.length,
                        separatorBuilder: (ctx, i) => SizedBox(height: 8),
                        itemBuilder: (ctx, i) {
                          ProdukCartMarket produk =
                              ProdukCartMarket.parse(box.getAt(i));
                          print(
                              "Produk di UI - Judul: ${produk.title}, Harga: ${produk.price}");

                          if (produk.count < 1) {
                            Hive.box('cart').deleteAt(i);
                          }

                          return Dismissible(
                            key: Key('cart-item-$i'),
                            background: Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(5))),
                            confirmDismiss: (direction) async {
                              bool status = await showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (ctx) => AlertDialog(
                                          title: Text('Hapus Antrian',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .primaryColor)),
                                          content: Text(
                                              'Anda yakin ingin menghapus produk ini ?',
                                              textAlign: TextAlign.justify),
                                          actions: [
                                            TextButton(
                                                child: Text(
                                                  'BATAL',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                ),
                                                onPressed: () =>
                                                    Navigator.of(ctx)
                                                        .pop(false)),
                                            TextButton(
                                                child: Text(
                                                  'HAPUS',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                ),
                                                onPressed: () =>
                                                    Navigator.of(ctx)
                                                        .pop(true)),
                                          ]));
                              return status ?? false;
                            },
                            onDismissed: (direction) async {
                              await Hive.box('cart').deleteAt(i);
                            },
                            child: Container(
                                width: double.infinity,
                                height: MediaQuery.of(context).size.width * .2,
                                decoration: BoxDecoration(
                                    color: Theme.of(context).canvasColor,
                                    border: Border.all(
                                        color: Colors.grey.withOpacity(.2),
                                        width: 1),
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(.5),
                                          offset: Offset(3, 3),
                                          blurRadius: 25)
                                    ]),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(5),
                                          bottomLeft: Radius.circular(5),
                                        ),
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: CachedNetworkImage(
                                            imageUrl: produk.thumbnail,
                                            height: double.infinity,
                                            fit: BoxFit.fitHeight,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  produk.title,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(height: 3),
                                                Text(
                                                  formatRupiah(produk.price),
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                ),
                                                Spacer(),
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      InkWell(
                                                        onTap: () =>
                                                            subtract(i),
                                                        child: Icon(
                                                            Icons.remove,
                                                            size: 20,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor),
                                                      ),
                                                      InkWell(
                                                          onTap: () =>
                                                              changeQuantity(i),
                                                          child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        8),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        5),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            .3),
                                                                    width: 1)),
                                                            width: 30,
                                                            child: Text(
                                                                produk.count
                                                                    .toString(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .end),
                                                          )),
                                                      InkWell(
                                                        onTap: () => add(i),
                                                        child: Icon(Icons.add,
                                                            size: 20,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor),
                                                      ),
                                                    ])
                                              ]),
                                        ),
                                      )
                                    ])),
                          );
                        },
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  color: Colors.grey.withOpacity(.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                            SizedBox(height: 3),
                            ValueListenableBuilder(
                              valueListenable: Hive.box('cart').listenable(),
                              builder: (context, value, child) {
                                int total = 0;

                                value.values.forEach((el) {
                                  ProdukCartMarket produk =
                                      ProdukCartMarket.parse(el);
                                  total += (produk.price * produk.count);
                                });

                                return Text(formatRupiah(total),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: Theme.of(context).primaryColor));
                              },
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: ButtonTheme(
                          minWidth: double.infinity,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          buttonColor: Theme.of(context).primaryColor,
                          textTheme: ButtonTextTheme.primary,
                          child: MaterialButton(
                            elevation: 0,
                            child: Text('CHECKOUT'),
                            onPressed: checkout,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}

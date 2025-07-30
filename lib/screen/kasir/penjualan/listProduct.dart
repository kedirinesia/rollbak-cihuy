// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:barcode_scan2/barcode_scan2.dart';

// model
import 'package:mobile/models/kasir/listProduct.dart';

// component
import 'package:mobile/component/loader.dart';

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/provider/analitycs.dart';

// page screen
import 'package:mobile/screen/kasir/penjualan/checkout.dart';

import 'package:mobile/modules.dart';

class ListProduct extends StatefulWidget {
  @override
  createState() => ListProductState();
}

class ListProductState extends State<ListProduct> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController query = TextEditingController();
  TextEditingController hargaJualController = TextEditingController();

  bool loading = true;
  int totalQty = 0;
  String hargaJual = "";
  List<ListProductModel> listProducts = [];
  List<ListProductModel> tmpProdcts = [];

  @override
  void initState() {
    getData();
    super.initState();
    analitycs.pageView('/listProduct/kasir', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'List Product Kasir',
    });
  }

  void getData() async {
    setState(() {
      listProducts.clear();
      tmpProdcts.clear();
      loading = true;
      totalQty = 0;
    });

    try {
      http.Response response = await http.get(
          Uri.parse('$apiUrlKasir/transaksi/penjualan/listProduct'),
          headers: {
            'authorization': bloc.token.valueWrapper?.value,
          });

      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan saat mengambil data dari server';
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        int status = responseData['status'];
        var datas = responseData['data'];

        if (status == 200) {
          datas.forEach((data) {
            listProducts.add(ListProductModel.fromJson(data));
            tmpProdcts.add(ListProductModel.fromJson(data));
          });
        } else {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text('Gagal'),
                    content: Text(message),
                    actions: <Widget>[
                      TextButton(
                        child: Text(
                          'OK',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ));
        }
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('Gagal'),
                  content: Text(message),
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ));
      }
    } catch (err) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Gagal'),
                content: Text(
                    'Terjadi kesalahan saat mengambil data dari server. ${err.toString()}'),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ));
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  // itung total seluruh item
  void countItem() {
    int subTot = 0;
    listProducts.forEach((r) {
      subTot += r.qty;
    });

    setState(() {
      totalQty = subTot;
    });
  }

  // add qty per item
  void add(int index, ListProductModel product) async {
    if (product.qty < product.stock) {
      var tmpIndex =
          tmpProdcts.indexWhere((tmp) => tmp.sku.startsWith(product.sku));

      product.qty++;
      setState(() {
        listProducts[index] = product;
        tmpProdcts[tmpIndex] = product;
      });

      countItem();
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Tambah Item Gagal'),
                content: Text('Stock Barang Tidak Mencukupi'),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ));
    }
  }

  // update jumlah item yg akan di jual
  void updateCart(int index, ListProductModel product) async {
    product.hargaJual = int.parse(hargaJualController.text);
    setState(() {
      listProducts[index] = product;
    });
  }

  // show modal edit jumlah item
  void showModal(int index, ListProductModel product) async {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actions: [
              TextButton(
                  child: Text(
                    'BATAL',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  onPressed: () => Navigator.of(context).pop(false)),
              TextButton(
                  child: Text(
                    'UBAH',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  onPressed: () async {
                    updateCart(index, product);
                    Navigator.of(context).pop(true);
                  })
            ],
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              int itemQty = product.qty;
              return Container(
                width: MediaQuery.of(context).size.width - 100,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          product.namaBarang,
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          product.sku,
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.grey,
                          ),
                        ),
                        trailing: Text(
                          '${product.stock}',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: () {
                              if (product.qty > 0) {
                                product.qty--;

                                setState(() {
                                  listProducts[index] = product;
                                });
                                countItem();
                              }
                            },
                            child: Icon(Icons.remove,
                                size: 35,
                                color: Theme.of(context).primaryColor),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 10.0, right: 10.0),
                            child: Text(
                              '$itemQty',
                              style: TextStyle(
                                fontSize: 25.0,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (product.qty < product.stock) {
                                product.qty++;

                                setState(() {
                                  listProducts[index] = product;
                                });
                                countItem();
                              }
                            },
                            child: Icon(Icons.add,
                                size: 35,
                                color: Theme.of(context).primaryColor),
                          ),
                        ],
                      ),
                      SizedBox(height: 15.0),
                      TextFormField(
                          controller: hargaJualController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Harga Jual',
                            errorStyle: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (String value) {
                            if (value == "") {
                              return "harga jual tidak boleh kosong";
                            }
                            return value;
                          },
                          onSaved: (String value) {
                            setState(() {
                              hargaJual = value;
                            });
                          }),
                    ],
                  ),
                ),
              );
            }),
          );
        });
  }

  // submit proses next
  void submitNext() async {
    if (totalQty > 0) {
      List<ListProductModel> itemOrders = [];
      tmpProdcts.forEach((r) {
        if (r.qty > 0) {
          itemOrders.add(r);
        }
      });

      await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Checkout(itemOrders, getData),
      ));
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Pemberitahuan'),
                content: Text('Maaf Keranjang Anda Masih Kosong'),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        title: Text('Transaksi Penjualan'),
      ),
      bottomNavigationBar: bottomWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: btnNext(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            formSearch(),
            Flexible(
                flex: 1,
                child: loading
                    ? LoadWidget()
                    : listProducts.length == 0
                        ? buildEmpty()
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            padding: EdgeInsets.all(10.0),
                            itemCount: listProducts.length,
                            separatorBuilder: (_, i) => SizedBox(height: 10),
                            itemBuilder: (ctx, i) {
                              var _product = listProducts[i];
                              return GestureDetector(
                                onTap: () => add(i, _product),
                                onLongPress: () {
                                  setState(() {
                                    hargaJualController.text =
                                        _product.hargaJual.toString();
                                    hargaJual = _product.hargaJual.toString();
                                  });

                                  showModal(i, _product);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black.withOpacity(.1),
                                            offset: Offset(5, 10.0),
                                            blurRadius: 20)
                                      ]),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      foregroundColor:
                                          Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(.1),
                                      child: Text(
                                        '${_product.namaBarang.split('')[0]}',
                                        style: TextStyle(
                                          fontSize: 20.0,
                                        ),
                                      ),
                                    ),
                                    title: Text(_product.namaBarang,
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade700)),
                                    subtitle: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text('Stok  ${_product.stock}',
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.grey.shade700)),
                                        Text(' - '),
                                        Text(
                                            'Harga ${formatNominal(_product.hargaJual)}',
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.grey.shade700)),
                                      ],
                                    ),
                                    trailing: _product.qty > 0
                                        ? Container(
                                            padding: EdgeInsets.all(10.0),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            child: Text('${_product.qty}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.bold,
                                                )),
                                          )
                                        : Text(""),
                                  ),
                                ),
                              );
                            })),
          ],
        ),
      ),
    );
  }

  Widget formSearch() {
    return Container(
      padding:
          EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.1),
            blurRadius: 10.0,
            offset: Offset(5, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: query,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Cari Produk disini...',
                isDense: true,
                suffixIcon: InkWell(
                    child: Icon(Icons.search),
                    onTap: () {
                      var list = tmpProdcts
                          .where((item) => item.namaBarang
                              .toLowerCase()
                              .contains(query.text))
                          .toList();
                      setState(() {
                        listProducts = list;
                      });
                    }),
              ),
              onEditingComplete: () {
                var list = tmpProdcts
                    .where((item) =>
                        item.namaBarang.toLowerCase().contains(query.text))
                    .toList();
                setState(() {
                  listProducts = list;
                });
              },
              onChanged: (value) {
                var list = tmpProdcts
                    .where((item) =>
                        item.namaBarang.toLowerCase().contains(query.text))
                    .toList();
                setState(() {
                  listProducts = list;
                });
              },
            ),
          ),
          SizedBox(width: 10.0),
          InkWell(
            onTap: () async {
              print('scan qr code');
              var barcode = await BarcodeScanner.scan();
              if (barcode.rawContent.isNotEmpty) {
                String rawContent = barcode.rawContent;
                print('rawContent -> $rawContent');
                var list = tmpProdcts
                    .where((item) => item.sku
                        .toLowerCase()
                        .contains(rawContent.toLowerCase()))
                    .toList();
                print(list);

                if (list.length > 0) {
                  add(0, list[0]);
                } else {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text('Scan Barang Gagal'),
                            content: Text('Barang Tidak Di Temukan'),
                            actions: <Widget>[
                              TextButton(
                                child: Text(
                                  'OK',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              )
                            ],
                          ));
                }
              }
            },
            child: Image(
                image: AssetImage('assets/img/kasir/qr-code.png'),
                width: 35.0,
                height: 35.0),
          ),
        ],
      ),
    );
  }

  Widget bottomWidget() {
    return Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 20.0),
      width: double.infinity,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(.50),
            offset: Offset(0, -1),
            blurRadius: 10)
      ], color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Item',
              style: TextStyle(fontSize: 11, color: Colors.grey)),
          SizedBox(height: 5),
          Text('$totalQty',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget btnNext() {
    return FloatingActionButton.extended(
      icon: Icon(Icons.navigate_next),
      label: Text('Lanjutkan'),
      backgroundColor: Theme.of(context).primaryColor,
      onPressed: () => submitNext(),
    );
  }

  Widget buildEmpty() {
    return Center(
      child: SvgPicture.asset('assets/img/empty.svg',
          width: MediaQuery.of(context).size.width * .45),
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}

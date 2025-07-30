// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/mp_alamat.dart';
import 'package:mobile/models/mp_kurir.dart';
import 'package:mobile/models/mp_metode_bayar.dart';
import 'package:mobile/models/mp_produk_cart.dart';
import 'package:mobile/models/mp_voucher.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/marketplace/alamat/list_alamat.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screen/marketplace/kurir/list_kurir.dart';
import 'package:mobile/screen/marketplace/kurir/list_service.dart';
import 'package:mobile/screen/marketplace/voucher/voucher.dart';
import 'package:mobile/screen/marketplace/opsi_bayar.dart';
import 'package:mobile/screen/topup/topup.dart';
import 'package:mobile/screen/transaksi/verifikasi_pin.dart';

class OrderPage extends StatefulWidget {
  final List<ProdukCartMarket> products;
  OrderPage({this.products});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  TextEditingController voucherController = TextEditingController();
  bool isLoading = false;
  int totalProductPrice = 0;
  AlamatModel recieverAddress;
  MPKurir selectedCourier;
  MPKurirService selectedService;
  VoucherMarket selectedVoucher;
  int totalPriceCheckout = 0;
  int totalWeight = 0;
  MetodeBayarModel purchaseMethod =
      new MetodeBayarModel(title: 'Saldo', code: 'saldo');

  @override
  void initState() {
    widget.products.forEach((e) => totalProductPrice += (e.count * e.price));
    widget.products.forEach((e) => totalWeight += (e.count * e.weight));
    super.initState();
    analitycs.pageView('/order/mkp', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Order Marketplace',
    });
  }

  Future<void> placeOrder() async {
    if (recieverAddress == null) return;
    if (selectedCourier.code != 'cod' && selectedService == null) return;

    dynamic pin = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => VerifikasiPin()));

    if (pin == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      http.Response response = await http.post(
          Uri.parse('$apiUrl/market/order/place'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': bloc.token.valueWrapper?.value
          },
          body: json.encode({
            "items": widget.products
                .map((e) => {"product_id": e.id, "qty": e.count})
                .toList(),
            "kurir_id": selectedCourier.id,
            "service_code": (selectedCourier != null &&
                    (selectedCourier != null && selectedCourier.code == 'cod'))
                ? null
                : selectedService.service,
            "shipping_id": recieverAddress.id,
            "shipping_cost":
                (selectedCourier != null && selectedCourier.code == 'cod')
                    ? 0
                    : selectedService.cost,
            "payment_by":
                (selectedCourier != null && selectedCourier.code == 'cod')
                    ? 'cod'
                    : purchaseMethod.code,
            "voucherID": selectedVoucher != null ? selectedVoucher.id : null
          }));

      String message =
          json.decode(response.body)['message'] ?? 'Transaksi gagal';
      if (response.statusCode == 200) {
        showToast(context, "Transaksi berhasil, pesanan segera diproses");
        Hive.box('cart').clear();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      } else {
        showToast(context, message);
      }
    } catch (err) {
      showToast(context,
          'Terjadi kesalahan saat mengambil data dari server. ${err.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void submitCode() async {
    if (voucherController.text == "") {
      showToast(context, "Code voucher masih kosong");
    } else {
      setState(() {
        isLoading = true;
      });

      try {
        dynamic dataToSend = {
          'voucherCode': voucherController.text,
        };

        http.Response response = await http.post(
          Uri.parse('$apiUrl/market/voucher/validateCode'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': bloc.token.valueWrapper?.value,
          },
          body: json.encode(dataToSend),
        );

        String message = json.decode(response.body)['message'] ??
            'Terjadi kesalahan saat mengambil data dari server';
        if (response.statusCode == 200) {
          var responseData = json.decode(response.body);
          var status = responseData['status'];

          print(responseData);
          if (status == 200) {
            setState(() {
              selectedVoucher = VoucherMarket.fromJson(responseData['data']);
            });
          } else {
            showToast(context, message);
          }
        } else {
          showToast(context, message);
        }
      } catch (err) {
        showToast(context,
            'Terjadi kesalahan saat mengambil data dari server. ${err.toString()}');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    /* 
     * Akumulasi total pembayaran
     */

    var discount = 0;
    var service = 0;

    if (selectedVoucher != null) discount = selectedVoucher.nominalVoucher;
    if (selectedService != null) service = selectedService.cost;

    totalPriceCheckout = totalProductPrice - discount + service;

    if (totalPriceCheckout < 0) totalPriceCheckout = 0;

    return Scaffold(
      appBar: AppBar(title: Text('Checkout Pesanan')),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: isLoading
            ? Center(
                child: SpinKitThreeBounce(
                    color: Theme.of(context).primaryColor, size: 35))
            : ListView(
                padding: EdgeInsets.all(15),
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: Colors.grey.withOpacity(.3), width: 1),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(.4),
                              offset: Offset(4, 4),
                              blurRadius: 10)
                        ]),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 10, right: 10),
                          child: Text('Daftar Produk',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.all(5),
                          itemCount: widget.products.length,
                          itemBuilder: (ctx, i) {
                            ProdukCartMarket product = widget.products[i];

                            return ListTile(
                              dense: true,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 5),
                              leading: AspectRatio(
                                aspectRatio: 1,
                                child: CachedNetworkImage(
                                  imageUrl: product.thumbnail,
                                  height: double.infinity,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                              title: Text(product.title),
                              subtitle: Text(
                                  formatRupiah(product.price * product.count),
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold)),
                              trailing: Text('${product.count} item',
                                  style: TextStyle(fontSize: 13)),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.grey.withOpacity(.3), width: 1),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(.4),
                                offset: Offset(4, 4),
                                blurRadius: 10)
                          ]),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Alamat Penerima',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            Divider(),
                            SizedBox(height: 5),
                            recieverAddress == null
                                ? SizedBox()
                                : Text(
                                    '${recieverAddress.name} (${recieverAddress.phone})\n${recieverAddress.address1}, ${recieverAddress.address2}, ${recieverAddress.kecamatan.name}, ${recieverAddress.kota.type} ${recieverAddress.kota.name}, ${recieverAddress.provinsi.name} - ${recieverAddress.postalCode}',
                                    style:
                                        TextStyle(height: 1.2, fontSize: 13)),
                            SizedBox(height: 10),
                            ButtonTheme(
                              minWidth: double.infinity,
                              textTheme: ButtonTextTheme.primary,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              child: OutlinedButton(
                                  child: Text('PILIH ALAMAT'),
                                  // textColor: Theme.of(context).primaryColor,
                                  // borderSide: BorderSide(
                                  //     color: Theme.of(context).primaryColor),
                                  onPressed: () async {
                                    AlamatModel alamat =
                                        await Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    ListAlamatPage()));

                                    if (alamat == null) return;

                                    recieverAddress = alamat;
                                    setState(() {});
                                  }),
                            )
                          ])),
                  SizedBox(height: 10),
                  Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.grey.withOpacity(.3), width: 1),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(.4),
                                offset: Offset(4, 4),
                                blurRadius: 10)
                          ]),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ekspedisi',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            Divider(),
                            SizedBox(height: 5),
                            (selectedCourier != null &&
                                    selectedCourier.code == 'cod')
                                ? Text('COD (Cash on Delivery)')
                                : selectedService == null
                                    ? SizedBox()
                                    : Text(
                                        '${selectedCourier.name} - ${selectedService.description} (${selectedService.service})'),
                            SizedBox(height: 10),
                            ButtonTheme(
                              minWidth: double.infinity,
                              textTheme: ButtonTextTheme.primary,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              child: OutlinedButton(
                                  child: Text('PILIH EKSPEDISI'),
                                  // textColor: Theme.of(context).primaryColor,
                                  // borderSide: BorderSide(
                                  //     color: Theme.of(context).primaryColor),
                                  onPressed: () async {
                                    if (recieverAddress == null)
                                      return showToast(context,
                                          'Alamat tujuan belum dipilih');

                                    MPKurir courierResult =
                                        await Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    ListKurirPage()));

                                    if (courierResult == null) return;
                                    if (courierResult.code == 'cod') {
                                      setState(() {
                                        selectedCourier = courierResult;
                                        selectedService = null;
                                      });
                                      return;
                                    }

                                    if (selectedCourier != courierResult)
                                      selectedService = null;
                                    setState(() {
                                      selectedCourier = courierResult;
                                    });

                                    MPKurirService serviceResult =
                                        await Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    ListCourierServicePage(
                                                      courierId:
                                                          selectedCourier.id,
                                                      shippingId:
                                                          recieverAddress.id,
                                                      weight: totalWeight,
                                                    )));

                                    if (serviceResult == null) return;

                                    setState(() {
                                      selectedService = serviceResult;
                                    });
                                  }),
                            )
                          ])),
                  SizedBox(height: 10),
                  (selectedCourier != null && selectedCourier.code == 'cod')
                      ? SizedBox()
                      : buildVoucher(),
                  (selectedCourier != null && selectedCourier.code == 'cod')
                      ? SizedBox()
                      : SizedBox(height: 10),
                  Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.grey.withOpacity(.3), width: 1),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(.4),
                                offset: Offset(4, 4),
                                blurRadius: 10)
                          ]),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rincian Pesanan',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            Divider(),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Harga Produk'),
                                Text(formatRupiah(totalProductPrice),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Ongkos Kirim'),
                                Text(
                                    selectedService == null
                                        ? '0'
                                        : formatRupiah(selectedService.cost),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Nominal Voucher'),
                                Text(
                                    '${selectedVoucher != null ? '- ' + formatRupiah(selectedVoucher.nominalVoucher) : 0}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Total Bayar'),
                                Text(formatRupiah(totalPriceCheckout),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ])),
                  SizedBox(height: 10),
                  Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.grey.withOpacity(.3), width: 1),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(.4),
                                offset: Offset(4, 4),
                                blurRadius: 10)
                          ]),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Metode Pembayaran',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            Divider(),
                            SizedBox(height: 5),
                            Text((purchaseMethod.code == 'saldo' &&
                                    bloc.user.valueWrapper?.value.saldo <
                                        (totalProductPrice +
                                            (selectedService == null
                                                ? 0
                                                : selectedService.cost)))
                                ? '${purchaseMethod.title} (Tidak Cukup)'
                                : purchaseMethod.title),
                            SizedBox(height: 10),
                            ButtonTheme(
                              minWidth: double.infinity,
                              textTheme: ButtonTextTheme.primary,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              child: OutlinedButton(
                                  child: Text('PILIH METODE BAYAR'),
                                  // textColor: Theme.of(context).primaryColor,
                                  // borderSide: BorderSide(
                                  //     color: Theme.of(context).primaryColor),
                                  onPressed: () async {
                                    MetodeBayarModel method =
                                        await Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    OpsiBayarPage()));

                                    if (method == null) return;

                                    purchaseMethod = method;
                                    setState(() {});
                                  }),
                            )
                          ])),
                  SizedBox(height: 20),
                  (purchaseMethod.code == 'saldo' &&
                          bloc.user.valueWrapper?.value.saldo <
                              (totalProductPrice +
                                  (selectedService == null
                                      ? 0
                                      : selectedService.cost)))
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          child: Text('TOP UP'.toUpperCase()),
                          onPressed: () => Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                                  builder: (_) => TopupPage())))
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          child: Text('Bayar Pesanan'.toUpperCase()),
                          onPressed: placeOrder),
                ],
              ),
      ),
    );
  }

  Widget buildVoucher() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.withOpacity(.3), width: 1),
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(.4),
                offset: Offset(4, 4),
                blurRadius: 10)
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Makin hemat pakai voucher',
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Divider(),
          SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: voucherController,
                  decoration: InputDecoration(
                    hintText: 'Masukan Kode',
                  ),
                ),
              ),
              SizedBox(width: 5.0),
              ElevatedButton(
                onPressed: () => submitCode(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: Text('Gunakan'),
              ),
            ],
          ),
          SizedBox(height: 10),
          ButtonTheme(
            minWidth: double.infinity,
            textTheme: ButtonTextTheme.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            child: OutlinedButton(
                child: Text(
                  selectedVoucher == null ? 'PILIH VOUCHER' : 'HAPUS VOUCHER',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // textColor: Theme.of(context).primaryColor,
                // borderSide: BorderSide(color: Theme.of(context).primaryColor),
                onPressed: () async {
                  if (selectedVoucher == null) {
                    VoucherMarket voucher = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => VoucherMarketPage()));

                    print(voucher);
                    if (voucher == null) return;

                    setState(() {
                      selectedVoucher = voucher;
                      voucherController.text = voucher.voucherCode;
                    });
                  } else {
                    setState(() {
                      selectedVoucher = null;
                      voucherController.text = '';
                    });
                  }
                }),
          )
        ],
      ),
    );
  }
}

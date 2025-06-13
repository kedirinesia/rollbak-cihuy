// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/models/mp_transaction.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/marketplace/lacak_pesanan.dart';
import 'package:http/http.dart' as http;

class DetailPesananPage extends StatefulWidget {
  final MPTransaksi trx;
  DetailPesananPage(this.trx);

  @override
  _DetailPesananPageState createState() => _DetailPesananPageState();
}

class _DetailPesananPageState extends State<DetailPesananPage> {
    bool loading = true;
  MPTransaksi trx;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() {
    trx = widget.trx;
    loading = false;
    setState(() {});
  }

  Future<void> confirmOrder() async {
    bool status = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
              title: Text('Konfirmasi Pesanan',
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              content: Text(
                  'Anda yakin ingin konfirmasi bahwa pesanan sudah diterima?',
                  textAlign: TextAlign.justify),
              actions: [
                TextButton(
                    child: Text('BATAL'),
                    onPressed: () => Navigator.of(ctx).pop(false)),
                TextButton(
                    child: Text('KONFIRMASI'),
                    onPressed: () => Navigator.of(ctx).pop(true)),
              ],
            ));

    if (!status) return;

    http.Response response =
        await http.post(Uri.parse('$apiUrl/market/order/confirm'),
            headers: {
              'Authorization': bloc.token.valueWrapper?.value,
              'Content-Type': 'application/json'
            },
            body: json.encode({'id': trx.id}));

    if (response.statusCode == 200) {
      MPTransaksi newTrx = new MPTransaksi(
          id: trx.id,
          resi: trx.resi,
          kurir: trx.kurir,
          shipping: trx.shipping,
          ongkosKirim: trx.ongkosKirim,
          paymentType: trx.paymentType,
          products: trx.products,
          hargaJual: trx.hargaJual,
          totalHargaBeli: trx.totalHargaBeli,
          totalHargaJual: trx.totalHargaJual,
          status: MPTransaksiStatus.parse(4),
          createdAt: trx.createdAt,
          updatedAt: trx.updatedAt,
          paymentExpiredAt: trx.paymentExpiredAt);

      trx = newTrx;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(Alert(
          'Terjadi kesalahan saat mengambil data dari server',
          isError: true));
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Pesanan'), elevation: 0),
      body: loading
          ? Container(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                  child: SpinKitThreeBounce(
                      color: Theme.of(context).primaryColor, size: 25)),
            )
          : ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(15),
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: trx.status.color.withOpacity(.15),
                        child: Icon(trx.status.icon, color: trx.status.color),
                      ),
                      SizedBox(height: 10),
                      Text(trx.status.label.toUpperCase(),
                          style: TextStyle(
                              fontSize: 16,
                              color: trx.status.color,
                              fontWeight: FontWeight.bold))
                    ],
                  ),
                ),
                SizedBox(
                    height: (trx.status.code == 2 || trx.status.code == 3) &&
                            trx.kurir.code != 'cod'
                        ? 10
                        : 0),
                (trx.status.code == 2 || trx.status.code == 3) &&
                        trx.kurir.code != 'cod'
                    ? ButtonTheme(
                        minWidth: double.infinity,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textTheme: ButtonTextTheme.primary,
                        child: OutlinedButton(
                          child: Text('LACAK PENGIRIMAN',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor)),
                          onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => LacakPesananPage(trx.id))),
                        ),
                      )
                    : SizedBox(),
                SizedBox(height: (trx.status.code == 3) ? 10 : 0),
                (trx.status.code == 3)
                    ? ButtonTheme(
                        minWidth: double.infinity,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        buttonColor: Theme.of(context).primaryColor,
                        textTheme: ButtonTextTheme.primary,
                        child: MaterialButton(
                          child: Text('TERIMA PESANAN'),
                          onPressed: confirmOrder,
                          elevation: 0,
                        ),
                      )
                    : SizedBox(),
                SizedBox(height: 25),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Harga Produk',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text(formatRupiah(trx.hargaJual))
                    ]),
                SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Ongkos Kirim',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text(formatRupiah(trx.ongkosKirim))
                    ]),
                SizedBox(height: 10),
                trx.voucher != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Nominal Voucher',
                              style:
                                  TextStyle(fontSize: 13, color: Colors.grey)),
                          Text('- ${formatRupiah(trx.voucher.nominal)}')
                        ],
                      )
                    : SizedBox(height: 0.0),
                SizedBox(height: trx.voucher == null ? 0.0 : 10.0),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Total Bayar',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text(formatRupiah(trx.totalHargaJual),
                          style: TextStyle(fontWeight: FontWeight.bold))
                    ]),
                SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Kurir',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text(trx.kurir.id.isNotEmpty
                          ? trx.kurir.code == 'cod'
                              ? trx.kurir.name
                              : '${trx.kurir.name} (${trx.kurir.service})'
                          : '-')
                    ]),
                SizedBox(height: 25),
                Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                        child: Text('PENERIMA',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor)))),
                SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Nama',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text(trx.shipping.name)
                    ]),
                SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Telepon',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text(trx.shipping.phone)
                    ]),
                SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Alamat',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                            '${trx.shipping.address}, Kec. ${trx.shipping.subdistrict}, ${trx.shipping.city}, ${trx.shipping.province} ${trx.shipping.zipcode}',
                            overflow: TextOverflow.clip,
                            textAlign: TextAlign.end),
                      )
                    ]),
                SizedBox(height: 25),
                Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                        child: Text('PRODUK',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor)))),
                SizedBox(height: 10),
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: trx.products.length ?? 0,
                  separatorBuilder: (_, i) => Divider(),
                  itemBuilder: (ctx, i) {
                    MPTransaksiProduk item = trx.products[i];

                    return ListTile(
                      dense: true,
                      // contentPadding: EdgeInsets.all(0),
                      leading: item.productImage == null
                          ? CircleAvatar(
                              backgroundColor: Colors.grey.withOpacity(.15),
                              child: Icon(
                                Icons.warning,
                                color: Colors.grey,
                              ),
                            )
                          : CachedNetworkImage(
                              imageUrl: item.productImage,
                              fit: BoxFit.contain,
                              width: 50,
                            ),
                      title: Text(
                        item.productName ?? 'Produk Dihapus',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        formatRupiah(item.totalSellPrice),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 11,
                        ),
                      ),
                      trailing: Text('x ${item.quantity}'),
                    );
                  },
                )
              ],
            ),
    );
  }
}

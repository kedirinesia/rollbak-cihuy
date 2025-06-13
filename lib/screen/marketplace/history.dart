// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:lazy_load_refresh_indicator/lazy_load_refresh_indicator.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/models/mp_transaction.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/marketplace/detail_pesanan.dart';

class HistoryOrderPage extends StatefulWidget {
  @override
  _HistoryOrderPageState createState() => _HistoryOrderPageState();
}

class _HistoryOrderPageState extends State<HistoryOrderPage> {
    List<MPTransaksi> items = [];
  int page = 0;
  bool loading = true;
  bool isEdge = false;

  @override
  void initState() {
    super.initState();
    analitycs.pageView('/history/order', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'History Order',
    });
    getItems();
  }

  Future<void> getItems() async {
    if (isEdge) return;

    http.Response response = await http.get(
        Uri.parse('$apiUrl/market/order/list?page=$page'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      if (datas.length == 0) isEdge = true;
      items.addAll(datas.map((e) => MPTransaksi.fromJson(e)).toList());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(Alert(
          'Terjadi kesalahan saat mengambil data dari server',
          isError: true));
    }

    setState(() {
      page++;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(title: Text('Riwayat Pesanan'), elevation: 0),
      body: LazyLoadRefreshIndicator(
          onEndOfPage: getItems,
          onRefresh: () {
            page = 0;
            isEdge = false;
            items.clear();
            setState(() {});
            return getItems();
          },
          isLoading: loading,
          child: loading
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                      child: SpinKitThreeBounce(
                          color: Theme.of(context).primaryColor, size: 25)))
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    MPTransaksi item = items[i];

                    return ListTile(
                      dense: true,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => DetailPesananPage(item))),
                      title: Text(
                          item.products.last.productName ?? 'Produk Dihapus',
                          overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                          formatDate(item.createdAt, 'd MMMM yyyy HH:mm:ss'),
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                      leading: CircleAvatar(
                        backgroundColor: item.status.color.withOpacity(.15),
                        child: Icon(item.status.icon, color: item.status.color),
                      ),
                      trailing: Text(formatRupiah(item.totalHargaJual),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor)),
                    );
                  },
                )),
    );
  }
}

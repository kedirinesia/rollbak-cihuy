// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';
// NPM PACKAGE
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
// PROVIDER
// BLOC CONFIG
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
// MODEL
import 'package:mobile/models/mp_metode_bayar.dart';
// COMPONENT
import 'package:mobile/component/loader.dart';
// LIBS
import 'package:mobile/modules.dart';

class OpsiBayarPage extends StatefulWidget {
  @override
  _OpsiBayarPageState createState() => _OpsiBayarPageState();
}

class _OpsiBayarPageState extends State<OpsiBayarPage> {
  List<MetodeBayarModel> purchaseMethods = [
    MetodeBayarModel(
        title: 'Saldo',
        code: 'saldo',
        description: 'Pembayaran menggunakan saldo saya')
  ];
  bool loading = true;

  @override
  initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    try {
      print('GET METHOD PAYMENT');
      http.Response response = await http.get(
          Uri.parse('$apiUrl/market/order/methode-payment'),
          headers: {'Authorization': bloc.token.valueWrapper?.value});

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<dynamic> datas = responseData['data'];
        var rc = responseData['status'];
        if (rc == 200) {
          datas.forEach((e) {
            purchaseMethods.add(MetodeBayarModel.fromJson(e));
          });
        } else {
          showToast(context, responseData['meesage']);
        }
      } else {
        showToast(context, 'Gagal mengambil method pembayaran');
      }
    } catch (err) {
      print('ERROR : ${err.message}');
      showToast(context, 'Gagal mengambil method pembayaran. ERROR : $err');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void onTapMenu(MetodeBayarModel item) {
    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Metode Pembayaran'), elevation: 0),
      body: loading
          ? LoadWidget()
          : ListView.builder(
              itemCount: purchaseMethods.length,
              shrinkWrap: true,
              physics: ScrollPhysics(),
              padding: EdgeInsets.all(10.0),
              itemBuilder: (ctx, i) {
                MetodeBayarModel item = purchaseMethods[i];

                if (item.code == 'saldo') {
                  return buildItemSaldo(item);
                } else {
                  return buildItem(item);
                }
              },
            ),
    );
  }

  Widget buildItem(MetodeBayarModel item) {
    return InkWell(
      onTap: () => onTapMenu(item),
      child: Container(
        margin: EdgeInsets.only(bottom: 20.0, left: 10.0, right: 10.0),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.2),
              offset: Offset(5, 10),
              blurRadius: 10.0)
        ]),
        child: ListTile(
          dense: true,
          leading: CircleAvatar(
            foregroundColor: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(.1),
            child: item.icon.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.all(10.0),
                    child: CachedNetworkImage(
                      imageUrl: item.icon,
                      width: 40.0,
                    ))
                : Icon(Icons.list),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.title,
                style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700),
              ),
              item.admin != null
                  ? Text(
                      '+${item.admin['satuan'] == 'persen' ? '' : 'Rp '}${item.admin['nominal']}${item.admin['satuan'] == 'persen' ? '%' : ''} (admin)',
                      style: TextStyle(fontSize: 11, color: Colors.grey[800]),
                    )
                  : SizedBox()
            ],
          ),
          subtitle: Text(item.description ?? ' ',
              style: TextStyle(fontSize: 10.0, color: Colors.grey.shade700)),
          trailing: Icon(Icons.navigate_next),
        ),
      ),
    );
  }

  Widget buildItemSaldo(MetodeBayarModel item) {
    return InkWell(
      onTap: () => onTapMenu(item),
      child: Container(
        margin: EdgeInsets.only(bottom: 20.0, left: 10.0, right: 10.0),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.2),
              offset: Offset(5, 10),
              blurRadius: 10.0)
        ]),
        child: ListTile(
          dense: true,
          leading: CircleAvatar(
            foregroundColor: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(.1),
            child: Icon(Icons.list),
          ),
          title: Text(item.title,
              style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700)),
          subtitle: Text(item.description ?? ' ',
              style: TextStyle(fontSize: 10.0, color: Colors.grey.shade700)),
          trailing: Icon(Icons.navigate_next),
        ),
      ),
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}

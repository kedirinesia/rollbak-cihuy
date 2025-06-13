// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/mp_kecamatan.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/modules.dart';

class SelectKecamatanPage extends StatefulWidget {
  final String code;
  SelectKecamatanPage(this.code);

  @override
  _SelectKecamatanPageState createState() => _SelectKecamatanPageState();
}

class _SelectKecamatanPageState extends State<SelectKecamatanPage> {
  List<MarketplaceKecamatan> master = [];
  List<MarketplaceKecamatan> items = [];
  bool isLoading = true;
  TextEditingController query = TextEditingController();

  void getItems() async {
    http.Response response = await http.get(
        Uri.parse('$apiUrl/market/shipping/${widget.code}/subdistrict'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['message'];
      datas.forEach((data) => master.add(MarketplaceKecamatan.fromJson(data)));
      items = master;
    } else {
      showToast(context, 'Terjadi kesalahan saat mengambil data dari server');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getItems();
    super.initState();
  }

  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pilih Kecamatan')),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(15),
          child: isLoading
              ? Center(
                  child: SpinKitThreeBounce(
                      color: Theme.of(context).primaryColor, size: 35))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      TextFormField(
                        controller: query,
                        keyboardType: TextInputType.text,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Cari disini...',
                            prefixIcon: Icon(Icons.search),
                            suffixIcon: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: query.clear)),
                        onChanged: (value) {
                          items = master
                              .where((el) => el.name
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                          setState(() {});
                        },
                      ),
                      SizedBox(height: 15),
                      Expanded(
                        child: ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (ctx, i) {
                              MarketplaceKecamatan item = items[i];

                              return ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.all(0),
                                  title: Text(item.name,
                                      style: TextStyle(fontSize: 15)),
                                  trailing: Icon(Icons.navigate_next),
                                  onTap: () => Navigator.of(context).pop(item));
                            }),
                      )
                    ])),
    );
  }
}

// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

// model
import 'package:mobile/models/kasir/supplier.dart';

class SelectSupplier extends StatefulWidget {
  @override
  createState() => SelectSupplierState();
}

class SelectSupplierState extends State<SelectSupplier> {
    List<SupplierModel> suppliers = [];
  List<SupplierModel> filtered = [];
  bool isLoading = true;

  @override
  initState() {
    getList();

    super.initState();
  }

  void getList() async {
    try {
      http.Response response = await http
          .get(Uri.parse('$apiUrlKasir/master/supplier/all'), headers: {
        'authorization': bloc.token.valueWrapper?.value,
      });

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        var datas = responseData['data'];
        suppliers.clear();
        filtered.clear();

        datas.forEach((data) {
          suppliers.add(SupplierModel.fromJson(data));
          filtered.add(SupplierModel.fromJson(data));
        });
      } else {
        String message = json.decode(response.body)['message'];
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (err) {
      String message =
          'Terjadi kesalahan saat mengambil data dari server, ${err.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(title: Text('Supplier'), centerTitle: true, elevation: 0),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    isDense: true,
                    icon: Icon(Icons.search),
                    hintText: 'Cari Supplier'),
                onChanged: (value) {
                  filtered = suppliers
                      .where((el) => el.nama
                          .toString()
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();

                  setState(() {});
                }),
            SizedBox(height: 20),
            Flexible(
              flex: 1,
              child: isLoading
                  ? Container(
                      width: double.infinity,
                      height: double.infinity,
                      padding: EdgeInsets.all(15),
                      child: Center(
                        child: SpinKitThreeBounce(
                            color: Theme.of(context).primaryColor, size: 35),
                      ),
                    )
                  : suppliers.length == 0
                      ? Container(
                          width: double.infinity,
                          height: double.infinity,
                          padding: EdgeInsets.all(15),
                          child: Center(
                            child: Text(
                              'TIDAK ADA DATA',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            SupplierModel supplier = filtered[i];

                            return ListTile(
                                dense: true,
                                onTap: () {
                                  Navigator.of(context).pop(supplier);
                                },
                                contentPadding: EdgeInsets.all(0),
                                title: Text(supplier.nama));
                          }),
            ),
          ],
        ),
      ),
    );
  }
}

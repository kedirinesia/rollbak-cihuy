// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/mp_kurir.dart';
import 'package:http/http.dart' as http;

class ListKurirPage extends StatefulWidget {
  @override
  _ListKurirPageState createState() => _ListKurirPageState();
}

class _ListKurirPageState extends State<ListKurirPage> {
  Future<List<MPKurir>> getCouriers() async {
    try {
      http.Response response = await http.get(
          Uri.parse('$apiUrl/market/courier'),
          headers: {'Authorization': bloc.token.valueWrapper?.value});

      if (response.statusCode == 200) {
        List<dynamic> datas = json.decode(response.body)['data'];
        return datas.map((e) => MPKurir.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pilih Kurir'), elevation: 0),
      body: FutureBuilder<List<MPKurir>>(
        future: getCouriers(),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData)
            return Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(15),
              child: Center(
                child: SpinKitThreeBounce(
                  color: Theme.of(context).primaryColor,
                  size: 25,
                ),
              ),
            );

          return ListView.separated(
            padding: EdgeInsets.all(15),
            separatorBuilder: (_, i) => SizedBox(height: 10),
            itemCount: snapshot.data.length,
            itemBuilder: (ctx, i) {
              MPKurir kurir = snapshot.data[i];

              return Container(
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
                child: ListTile(
                  dense: true,
                  onTap: () => Navigator.of(context).pop(kurir),
                  title: Text(
                    kurir.name,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    kurir.description,
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  trailing: Icon(Icons.navigate_next),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

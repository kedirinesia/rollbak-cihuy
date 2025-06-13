// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/mp_kurir.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/modules.dart';

class ListCourierServicePage extends StatefulWidget {
  final String courierId;
  final String shippingId;
  final int weight;
  ListCourierServicePage({this.courierId, this.shippingId, this.weight = 100});

  @override
  _ListCourierServicePageState createState() => _ListCourierServicePageState();
}

class _ListCourierServicePageState extends State<ListCourierServicePage> {
  
  Future<List<MPKurirService>> getServices() async {
    try {
      Map<String, dynamic> dataToSend = {
        'kurir_id': widget.courierId,
        'shipping_id': widget.shippingId,
        'weight': widget.weight
      };

      http.Response response =
          await http.post(Uri.parse('$apiUrl/market/courier/service'),
              headers: {
                'Authorization': bloc.token.valueWrapper?.value,
                'Content-Type': 'application/json'
              },
              body: json.encode(dataToSend));

      if (response.statusCode == 200) {
        List<dynamic> datas = json.decode(response.body)['data'];
        return datas.map((e) => MPKurirService.fromJson(e)).toList();
      } else {
        Map<String, dynamic> data = json.decode(response.body);
        showToast(context, data['message']);
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
        title: Text('Pilih Layanan'),
        elevation: 0,
      ),
      body: FutureBuilder<List<MPKurirService>>(
        future: getServices(),
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
              MPKurirService service = snapshot.data[i];

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
                  onTap: () => Navigator.of(context).pop(service),
                  title: Text(
                    '${service.description} - ${service.service}',
                    style: TextStyle(fontSize: 15),
                  ),
                  trailing: Text(
                    formatRupiah(service.cost),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

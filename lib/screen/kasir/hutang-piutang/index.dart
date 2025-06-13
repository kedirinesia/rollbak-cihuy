// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:http/http.dart' as http;

// component
import 'package:mobile/component/loader.dart';

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/modules.dart';
// SCREEN PAGE
import 'package:mobile/screen/kasir/hutang-piutang/piutang.dart';
import 'package:mobile/screen/kasir/hutang-piutang/hutang.dart';

class HutangPiutang extends StatefulWidget {
  @override
  createState() => HutangPiutangState();
}

class HutangPiutangState extends State<HutangPiutang> {
  bool loading = true;
  int totalPiutang = 0;
  int totalHutang = 0;

  @override
  initState() {
    super.initState();
    getData();
  }

  void getData() async {
    try {
      http.Response response = await http
          .get(Uri.parse('$apiUrlKasir/dashboard/hutang-piutang'), headers: {
        'authorization': bloc.token.valueWrapper?.value,
      });

      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan saat mengambil data dari server';
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        int status = responseData['status'];
        var data = responseData['data'];

        if (status == 200) {
          setState(() {
            totalPiutang = data['piutang'];
            totalHutang = data['hutang'];
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
                    'Terjadi kesalahan saat mengambil data dari server. err : ${err.toString()}'),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ));
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hutang Piutang'),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: loading
          ? LoadWidget()
          : Container(
              margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: ListView(
                children: [
                  buildPanel(),
                  SizedBox(height: 15.0),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PiutangPage(),
                      ));
                    },
                    child: Container(
                      decoration:
                          BoxDecoration(color: Colors.white, boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(.5),
                            offset: Offset(3, 3),
                            blurRadius: 15)
                      ]),
                      child: ListTile(
                        leading: CircleAvatar(
                          foregroundColor: Theme.of(context).primaryColor,
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(.1),
                          child: Text(
                            'P',
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        title: Text('Piutang'),
                        subtitle: Text('Kelola Data Piutang Pelanggan'),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => HutangPage(),
                      ));
                    },
                    child: Container(
                      decoration:
                          BoxDecoration(color: Colors.white, boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(.5),
                            offset: Offset(3, 3),
                            blurRadius: 15)
                      ]),
                      child: ListTile(
                        leading: CircleAvatar(
                          foregroundColor: Theme.of(context).primaryColor,
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(.1),
                          child: Text(
                            'H',
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        title: Text('Hutang'),
                        subtitle: Text('Kelola Data Hutang Supplier'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildPanel() {
    return Container(
      margin: EdgeInsets.all(20.0),
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(.1),
            blurRadius: 10.0,
            offset: Offset(5, 10))
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Total Keseluruhan',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 3.0),
          Divider(),
          SizedBox(height: 3.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Total Piutang',
                      style: TextStyle(
                        fontSize: 13.0,
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      '${formatRupiah(totalPiutang)}',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: totalPiutang > 0 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Total Hutang',
                      style: TextStyle(
                        fontSize: 13.0,
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      '${formatRupiah(totalHutang)}',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: totalHutang > 0 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}

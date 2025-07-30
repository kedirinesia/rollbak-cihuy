// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:http/http.dart' as http;

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';

class MainKasir extends StatefulWidget {
  @override
  createState() => MainKasirState();
}

class MainKasirState extends State<MainKasir> {
  List boxItems = [
    {
      "title": "Satuan",
      "route": "/kasir/satuan",
      "icon": "assets/img/kasir/satuan.png"
    },
    {
      "title": "Kategori",
      "route": "/kasir/category",
      "icon": "assets/img/kasir/category.png"
    },
    {
      "title": "Pelanggan",
      "route": "/kasir/customer",
      "icon": "assets/img/kasir/customers.png"
    },
    {
      "title": "Supplier",
      "route": "/kasir/supplier",
      "icon": "assets/img/kasir/supplier.png"
    },
    {
      "title": "Barang",
      "route": "/kasir/barang",
      "icon": "assets/img/kasir/barang.png"
    },
    {
      "title": "Persediaan",
      "route": "/kasir/persediaan",
      "icon": "assets/img/kasir/stocks.png"
    },
    {
      "title": "Penjualan",
      "route": "/kasir/trx/penjualan",
      "icon": "assets/img/kasir/transaction.png"
    },
    {
      "title": "Laporan",
      "route": "/laporan",
      "icon": "assets/img/kasir/report.png"
    },
    {
      "title": "Hutang Piutang",
      "route": "/kasir/hutang-piutang",
      "icon": "assets/img/kasir/debt.png"
    }
  ];

  int pendapatan = 0;
  int piutang = 0;
  int hutang = 0;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    analitycs.pageView('/home/kasir', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Home Kasir',
    });
    print('Sampai Sini');
    getData();
  }

  void getData() async {
    setState(() {
      loading = true;
    });
    try {
      print(bloc.token.valueWrapper?.value);
      http.Response response = await http
          .get(Uri.parse('$apiUrlKasir/dashboard/hutang-piutang'), headers: {
        'authorization': bloc.token.valueWrapper?.value,
      });

      print('Sampai Sini Kedua');

      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan saat mengambil data dari server';
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        int status = responseData['status'];
        print(response.body);
        if (status == 200) {
          var data = responseData['data'];
          setState(() {
            pendapatan = data['pendapatan'] != null ? data['pendapatan'] : 0;
            piutang = data['piutang'] != null ? data['piutang'] : 0;
            hutang = data['hutang'] != null ? data['hutang'] : 0;
          });
        } else {
          final snackBar = SnackBar(
            content: Text(message),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        final snackBar = SnackBar(
          content: Text(message),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (err) {
      final snackBar = SnackBar(
        content:
            const Text('Terjadi kesalahan saat mengambil data dari server'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void onClick(box) async {
    if (box['route'] != '') {
      dynamic response = await Navigator.of(context).pushNamed(box['route']);

      getData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Kasir'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              size: 25.0,
              color: Colors.white,
            ),
            onPressed: () => getData(),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 200.0,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(.8)
                  ],
                      begin: AlignmentDirectional.topCenter,
                      end: AlignmentDirectional.bottomCenter)),
            ),
            Container(
              padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
              width: double.infinity,
              child: ListView(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                children: [
                  panelHutangPiutang(),
                  SizedBox(height: 20.0),
                  Container(
                    margin: EdgeInsets.only(left: 20.0, right: 20.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(.1),
                              blurRadius: 10.0,
                              offset: Offset(5, 10))
                        ]),
                    child: MenuKasir(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0)
          ],
        ),
      ),
    );
  }

  Widget panelHutangPiutang() {
    return Container(
      margin: EdgeInsets.only(left: 20.0, right: 20.0),
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.1),
                blurRadius: 10.0,
                offset: Offset(5, 10))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Periode Harian',
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
                      'Pendapatan',
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      '${formatRupiah(pendapatan)}',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
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
                      'Piutang',
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      '${formatRupiah(piutang)}',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
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
                      'Hutang',
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      '${formatRupiah(hutang)}',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.0),
          Divider(),
          SizedBox(height: 20.0),
          InkWell(
            onTap: () async {
              dynamic response =
                  await Navigator.of(context).pushNamed('/laporan');

              getData();
            },
            child: Container(
              child: Text(
                'Selengkapnya',
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget MenuKasir() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      child: GridView.builder(
        shrinkWrap: true,
        primary: false,
        physics: BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 5,
            childAspectRatio: 0.8,
            mainAxisSpacing: 10.0),
        itemCount: boxItems.length,
        itemBuilder: (_, int index) {
          var box = boxItems[index];
          return Container(
            child: InkWell(
              onTap: () => onClick(box),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Image.asset(
                      box['icon'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Expanded(
                    child: Text(
                      box['title'],
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.bold),
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}

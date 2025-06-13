// @dart=2.9

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/provider/analitycs.dart';

// model
// import 'package:mobile/models/kasir/persediaan.dart';

// component
import 'package:mobile/component/loader.dart';

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/modules.dart';

class LabaRugi extends StatefulWidget {
  @override
  createState() => LabaRugiState();
}

class LabaRugiState extends State<LabaRugi> {
  TextEditingController tglAwalController = TextEditingController();
  TextEditingController tglAkhirController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();

  // FORMAT TANGGAL
  var formatter = new DateFormat('yyyy-MM-dd');
  DateTime selectedAwal = getFirstDate(); //DateTime.now();
  DateTime selectedAkhir = DateTime.now();
  // END

  bool loading = true;
  int pendapatan = 0;
  int pembelian = 0;
  int labaKotor = 0;

  @override
  void initState() {
    getData();

    super.initState();
    analitycs.pageView('/labaRugi/kasir', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Laporan Laba Rugi Kasir',
    });
  }

  void getData() async {
    setState(() {
      tglAwalController.text = formatter.format(selectedAwal);
      tglAkhirController.text = formatter.format(selectedAkhir);
    });
    try {
      http.Response response = await http.get(
          Uri.parse(
              '$apiUrlKasir/laporan/laba-rugi?tgl_awal=${tglAwalController.text}&tgl_akhir=${tglAkhirController.text}'),
          headers: {
            'authorization': bloc.token.valueWrapper?.value,
          });

      var responseData = json.decode(response.body);
      String message = responseData['message'] ??
          'Terjadi kesalahan saat mengambil data dari server';
      if (response.statusCode == 200) {
        int status = responseData['status'];
        var datas = responseData['data'];

        if (status == 200) {
          setState(() {
            pembelian = datas['pembelian'] != null ? datas['pembelian'] : 0;
            pendapatan = datas['pendapatan'] != null ? datas['pendapatan'] : 0;
            labaKotor = datas['labaKotor'] != null ? datas['labaKotor'] : 0;
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
                    'Terjadi kesalahan saat mengambil data dari server. ${err.toString()}'),
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
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  // SELECT DATE
  Future _selectDate(String key) async {
    DateTime picked = await showDatePicker(
      context: context,
      initialDate: key == 'awal' ? selectedAwal : selectedAkhir,
      firstDate: new DateTime(1900),
      lastDate: new DateTime(2500),
    );

    if (picked != null) {
      String value = formatter.format(picked);
      print('picked -> $picked, value -> $value');

      if (key == 'awal') {
        setState(() {
          selectedAwal = picked;
          tglAwalController.text = value;
        });
      } else {
        setState(() {
          selectedAkhir = picked;
          tglAkhirController.text = value;
        });
      }
    }
  }

  // SHOW MODAL BOTTOM
  void _shodPopupBottom(BuildContext context) async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext cxt) {
          return _buildPopup();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        title: Text('Laporan Laba Rugi'),
        actions: [
          IconButton(
            onPressed: () => _shodPopupBottom(context),
            icon: Icon(
              Icons.search,
              color: Colors.white,
              size: 25.0,
            ),
          ),
        ],
      ),
      body: loading
          ? LoadWidget()
          : Container(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: [
                  _buildRincian(),
                ],
              ),
            ),
    );
  }

  Widget _buildRincian() {
    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(.1),
            offset: Offset(5, 10.0),
            blurRadius: 20)
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text('Pembelian'),
            subtitle: Text(
              'Total HPP Transaksi Penjualan',
              style: TextStyle(
                fontSize: 11.0,
              ),
            ),
            trailing: Container(
              padding: EdgeInsets.all(10.0),
              child: Text('${formatRupiah(pembelian)}',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
          SizedBox(height: 5.0),
          Divider(),
          SizedBox(height: 5.0),
          ListTile(
            title: Text('Pendapatan'),
            subtitle: Text(
              'Total Hasil Dari Transaksi Penjualan',
              style: TextStyle(
                fontSize: 11.0,
              ),
            ),
            trailing: Container(
              padding: EdgeInsets.all(10.0),
              child: Text('${formatRupiah(pendapatan)}',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
          SizedBox(height: 5.0),
          Divider(),
          SizedBox(height: 5.0),
          ListTile(
            title: Text('Laba Kotor'),
            subtitle: Text(
              'Hasil Laba Kotor Saat ini',
              style: TextStyle(
                fontSize: 11.0,
              ),
            ),
            trailing: Container(
              padding: EdgeInsets.all(10.0),
              child: Text('${formatRupiah(labaKotor)}',
                  style: TextStyle(
                    color: labaKotor > 0 ? Colors.green : Colors.red,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET SLIDE POPUP FILTER
  Widget _buildPopup() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pencarian Laporan',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            GestureDetector(
              onTap: () => _selectDate('awal'),
              child: AbsorbPointer(
                child: FocusScope(
                  node: new FocusScopeNode(),
                  child: TextFormField(
                    controller: tglAwalController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Tanggal Awal',
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            GestureDetector(
              onTap: () => _selectDate('akhir'),
              child: AbsorbPointer(
                child: FocusScope(
                  node: new FocusScopeNode(),
                  child: TextFormField(
                    controller: tglAkhirController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Tanggal Akhir',
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'TUTUP',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                SizedBox(width: 5.0),
                Expanded(
                  child: MaterialButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        getData();
                      },
                      child: Text("SUBMIT"),
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}

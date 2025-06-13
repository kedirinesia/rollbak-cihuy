// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Api.dart' show apiUrl;
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/transfer.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/Products/lariz/layout/components/verifikasi_pin.dart';
import 'package:mobile/screen/transfer_saldo/detail_transfer.dart';

class TransferByQR extends StatefulWidget {
  final String tujuan;

  TransferByQR(this.tujuan);

  @override
  _TransferByQRState createState() => _TransferByQRState();
}

class _TransferByQRState extends State<TransferByQR> {
  String trxId = '';
  String userId = '';
  String phone = '';
  String nama = '';
  int nom = 25000;
  bool loading = true;
  List tipsNominal = [
    25000,
    50000,
    100000,
    150000,
    250000,
    300000,
    500000,
    1000000
  ];
  int selectedNominal = 0;
  TextEditingController jumlahControl = TextEditingController();

  @override
  void initState() {
    getData(widget.tujuan, nom);
    analitycs.pageView('/transfer/saldo',
        {'userId': bloc.userId.valueWrapper?.value, 'title': 'Transfer Saldo'});
    super.initState();
  }

  void getData(String tujuan, int nominal) async {
    http.Response response =
        await http.post(Uri.parse('$apiUrl/transfer/inquiry'),
            headers: {
              'Authorization': bloc.token.valueWrapper?.value,
              'Content-Type': 'application/json'
            },
            body: jsonEncode({'phone': tujuan, 'nominal': nominal}));

    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body)['data'];
      userId = data['tujuan']['_id'];
      phone = data['tujuan']['phone'];
      nama = data['tujuan']['nama'];
      nom = data['nominal'];
      trxId = data['trxId'];
      analitycs.pageView('/transfer/saldo/inquiry/' + nama, {
        'userId': bloc.userId.valueWrapper?.value,
        'title': 'Cek Penerima ' + nama
      });
      setState(() {
        loading = false;
      });
    } else {
      String message = json.decode(response.body)['message'];
      await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                  title: Text('Transfer Gagal'),
                  content: Text(message),
                  actions: <Widget>[
                    TextButton(
                        child: Text(
                          'TUTUP',
                          style: TextStyle(
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop())
                  ]));
      Navigator.of(context).pop();
    }
  }

  void transfer() async {
    if (jumlahControl.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Nominal belum diisi')));
      return;
    }
    String pin = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => VerifikasiPin()));

    if (pin != null) {
      setState(() {
        loading = true;
      });
      sendDeviceToken();
      double parsedNominal =
          double.parse(jumlahControl.text.replaceAll('.', ''));
      http.Response response = await http.post(
          Uri.parse('$apiUrl/transfer/send'),
          headers: {
            'Authorization': bloc.token.valueWrapper?.value,
            'Content-Type': 'application/json'
          },
          body: json.encode(
              {'user_id': userId, 'nominal': parsedNominal, 'trxId': trxId}));
      setState(() {
        loading = false;
      });
      if (response.statusCode == 200) {
        TransferModel trf =
            TransferModel.fromJson(json.decode(response.body)['data']);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => DetailTransfer(
                nama, phone, int.parse(jumlahControl.text), trf)));
      } else {
        String message = json.decode(response.body)['message'];
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                    title: Text('Transfer Gagal'),
                    content: Text(message),
                    actions: <Widget>[
                      TextButton(
                          child: Text(
                            'TUTUP',
                            style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                            ),
                          ),
                          onPressed: () =>
                              Navigator.of(context, rootNavigator: true).pop())
                    ]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Yuk Transfer Saldo!'),
          backgroundColor: Theme.of(context).secondaryHeaderColor,
        ),
        floatingActionButton: loading
            ? Container()
            : FloatingActionButton.extended(
                onPressed: transfer,
                label: Text('Kirim Saldo Sekarang'),
                backgroundColor: Theme.of(context).secondaryHeaderColor),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: loading
            ? Container(
                child: Center(
                  child: SpinKitDoubleBounce(
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        color: Theme.of(context).secondaryHeaderColor,
                        padding: EdgeInsets.only(bottom: 20.0, top: 20.0),
                        child: Center(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 32.0,
                            foregroundColor:
                                Theme.of(context).secondaryHeaderColor,
                            child: CachedNetworkImage(
                              imageUrl:
                                  'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/assets%2Ficons%2Fshop.png?alt=media&token=3c4cd36c-9501-42f1-8a9f-54b98747a092',
                              width: 32.0,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: CachedNetworkImage(
                              imageUrl:
                                  'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/assets%2Ficons%2Fshop.png?alt=media&token=3c4cd36c-9501-42f1-8a9f-54b98747a092',
                              fit: BoxFit.contain),
                        ),
                        title: Text(nama.toUpperCase() ?? 'Error...',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(widget.tujuan ?? '-'),
                      ),
                      SizedBox(height: 10.0),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Jumlah',
                              hintText: nom.toString(),
                              icon: Text('Rp')),
                          autofocus: true,
                          controller: jumlahControl,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text('Rekomendasi Nominal',
                            textAlign: TextAlign.start),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 3.0,
                                  mainAxisSpacing: 10.0,
                                  crossAxisSpacing: 10.0),
                          itemCount: 8,
                          itemBuilder: (_, int index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedNominal = tipsNominal[index];
                                });
                                jumlahControl.text =
                                    tipsNominal[index].toString();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                                color: tipsNominal[index] == selectedNominal
                                    ? Theme.of(context).secondaryHeaderColor
                                    : Colors.grey[200],
                                child: Center(
                                  child: Text(formatRupiah(tipsNominal[index]),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: tipsNominal[index] ==
                                                  selectedNominal
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 12.0,
                                          fontWeight: tipsNominal[index] ==
                                                  selectedNominal
                                              ? FontWeight.bold
                                              : FontWeight.normal)),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 100.0)
                    ],
                  ),
                ),
              ));
  }

  Widget loadingWidget() {
    return Flexible(
        flex: 1,
        child: Center(
            child: SpinKitThreeBounce(
                color: Theme.of(context).secondaryHeaderColor, size: 35)));
  }
}

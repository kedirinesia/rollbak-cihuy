// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/bank.dart';
import 'package:mobile/modules.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Bloc.dart' show bloc;
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/payment_tutorial.dart';

class TransferDepositPage extends StatefulWidget {
  final int nominal;
  final int type;

  TransferDepositPage(this.nominal, this.type);

  @override
  _TransferDepositPageState createState() => _TransferDepositPageState();
}

class _TransferDepositPageState extends State<TransferDepositPage> {
  bool loading = true;
  List<BankModel> banks = [];

  @override
  void initState() {
    getData();
    super.initState();
    analitycs.pageView('/transfer/deposit/', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Transfer Deposit',
    });
  }

  void getData() async {
    http.Response response = await http.get(
        Uri.parse('$apiUrl/bank/list?type=${widget.type}'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      (json.decode(response.body)['data'] as List).forEach((item) {
        banks.add(BankModel.fromJson(item));
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Rekening'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: packageName == 'com.lariz.mobile'
            ? Theme.of(context).secondaryHeaderColor
            : Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.home_rounded),
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) =>
                      configAppBloc.layoutApp?.valueWrapper?.value['home'] ??
                      templateConfig[
                          configAppBloc.templateCode.valueWrapper?.value],
                ),
                (route) => false),
          ),
        ],
      ),
      body: ListView(children: <Widget>[
        Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    packageName == 'com.lariz.mobile'
                        ? Theme.of(context).secondaryHeaderColor
                        : Theme.of(context).primaryColor,
                    Theme.of(context).canvasColor
                  ],
                  begin: AlignmentDirectional.topCenter,
                  end: AlignmentDirectional.bottomCenter),
            ),
            child: Center(
                child: InkWell(
              onTap: () {
                Clipboard.setData(
                        ClipboardData(text: widget.nominal.toString()))
                    .then((_) {
                  showToast(context, 'Berhasil menyalin nominal');
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    formatRupiah(widget.nominal),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Ketuk untuk menyalin nominal'.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black.withOpacity(.7),
                    ),
                  ),
                  SizedBox(height: 5),
                  packageName == 'id.paymobileku.app'
                      ? Text(
                          'Harap transfer sesuai nominal yang tertera'
                              .toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[600]))
                      : SizedBox()
                ],
              ),
            ))),
        loading
            ? Center(
                child: SpinKitThreeBounce(
                    color: packageName == 'com.lariz.mobile'
                        ? Theme.of(context).secondaryHeaderColor
                        : Theme.of(context).primaryColor,
                    size: 35))
            : Container(
                margin: EdgeInsets.all(15),
                child: ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: banks.length,
                  separatorBuilder: (context, i) => SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    return InkWell(
                      onTap: () {
                        if (banks[i].isGangguan) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Untuk saat ini, rekening tersebut sedang mengalami gangguan')));
                        } else {
                          Clipboard.setData(
                              ClipboardData(text: banks[i].noRek));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Nomor rekening berhasil disalin ke papan klip')));
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(.1),
                                  offset: Offset(5, 10),
                                  blurRadius: 20)
                            ]),
                        child: Container(
                            padding: EdgeInsets.all(15),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(banks[i].namaBank,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.0)),
                                        Text(banks[i].noRek,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.0)),
                                      ]),
                                  SizedBox(height: 5),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text('a.n. ${banks[i].namaRekening}',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12)),
                                        Text(
                                            banks[i].isGangguan
                                                ? 'GANGGUAN'
                                                : 'TERSEDIA',
                                            style: TextStyle(
                                                color: banks[i].isGangguan
                                                    ? Colors.red
                                                    : Colors.green,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold))
                                      ]),
                                ])),
                      ),
                    );
                  },
                ),
              ),
        SizedBox(
          height: 20.0,
        ),
        packageName == 'id.paymobileku.app'
            ? SizedBox()
            : Text('Harap transfer sesuai nominal yang tertera'.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[600])),
        SizedBox(height: 20),
        PaymentTutorialPage(),
        SizedBox(height: 10),
      ]),
    );
  }
}

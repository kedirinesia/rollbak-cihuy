// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/contact.dart';
import 'package:mobile/config.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/transfer_saldo/inquiry_transfer.dart';

class TransferSaldo extends StatefulWidget {
  final String tujuan;
  TransferSaldo(this.tujuan);

  @override
  _TransferSaldoState createState() => _TransferSaldoState();
}

class _TransferSaldoState extends State<TransferSaldo> {
  TextEditingController nomorTujuan = TextEditingController();
  TextEditingController nominal = TextEditingController();

  bool activateContact = false;

  @override
  void initState() {
    nomorTujuan.text = widget.tujuan == null ? '' : widget.tujuan;
    super.initState();
    analitycs.pageView('/informasi/', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Informasi',
    });
  }

  void cek() {
    if (nomorTujuan.text.length != 0 && nominal.text.length != 0) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) =>
              InquiryTransfer(nomorTujuan.text, int.parse(nominal.text))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: <Widget>[
          SliverAppBar(
            iconTheme: IconThemeData(color: Colors.white),
            expandedHeight: 200.0,
            backgroundColor: Theme.of(context).primaryColor,
            pinned: true,
            flexibleSpace:
                FlexibleSpaceBar(title: Text('Kirim Saldo'), centerTitle: true),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            Container(
                padding: EdgeInsets.all(15),
                child: Column(children: <Widget>[
                  TextFormField(
                    controller: nomorTujuan,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                      labelText: 'Nomor Tujuan',
                      suffixIcon: IconButton(
                          icon: Icon(Icons.contacts),
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (_) => ContactPage()))
                                .then((nomor) {
                              if (nomor != null) {
                                nomorTujuan.text = nomor;
                              }
                            });
                          }),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: nominal,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        prefixText: 'Rp ',
                        labelText: 'Nominal'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 15)
                ]))
          ]))
        ]),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Theme.of(context).primaryColor,
          label: Text('Kirim'),
          icon: Icon(Icons.send),
          onPressed: () => cek(),
        ));
  }
}

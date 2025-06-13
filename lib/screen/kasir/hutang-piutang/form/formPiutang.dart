// @dart=2.9

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

// model
import 'package:mobile/models/kasir/piutang.dart';
import 'package:mobile/models/kasir/kasirPrint.dart';

// component

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/modules.dart';

// SCREEN
import 'package:mobile/screen/select_state/trxPiutang.dart';

class FormPiutang extends StatefulWidget {
  PiutangModel piutang;
  int saldoHutang;

  FormPiutang(this.piutang, this.saldoHutang);

  @override
  createState() => FormPiutangState();
}

class FormPiutangState extends State<FormPiutang> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nominalController = TextEditingController();
  TextEditingController keteranganController = TextEditingController();
  TextEditingController tglController = TextEditingController();
  TextEditingController idTrxController = TextEditingController();
  KasirPrintModel printTrx;

  // FORMAT TANGGAL
  DateTime selectedDate = DateTime.now();
  var formatter = new DateFormat('yyyy-MM-dd');
  // END

  bool loading = false;
  int radioValue = 0;
  String titleForm = "Memberi Piutang";
  String nominal = "";

  @override
  initState() {
    super.initState();
  }

  // SELECT DATE
  Future _selectDate() async {
    DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.utc(1965, 1, 1),
      lastDate: new DateTime(2500),
      locale: Locale('id', 'ID'),
    );

    if (picked != null) {
      String value = formatter.format(picked);

      setState(() {
        selectedDate = picked;
        tglController.text = value;
      });
    }
  }

  void prosesForm() async {
    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {
      if (int.parse(nominal) >= 0) {
        setState(() {
          loading = true;
        });

        Map<String, dynamic> dataToSend = {
          'id_piutang': widget.piutang.id,
          'nominal': nominal,
          'tanggal': tglController.text,
          'keterangan': keteranganController.text,
          'radioValue': radioValue,
          'type_piutang': widget.piutang.type,
          'id_transaksi': printTrx != null ? printTrx.id : null,
        };
        print(dataToSend);

        try {
          http.Response response = await http.post(
              Uri.parse('$apiUrlKasir/transaksi/piutang/addMutasi'),
              headers: {
                'Content-Type': 'application/json',
                'authorization': bloc.token.valueWrapper?.value,
              },
              body: json.encode(dataToSend));

          String message = json.decode(response.body)['message'] ??
              'Terjadi kesalahan saat mengambil data dari server';
          if (response.statusCode == 200) {
            var responseData = json.decode(response.body);
            int status = responseData['status'];
            if (status == 200) {
              List<dynamic> datas = responseData['data'];
              await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text('Berhasil'),
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
              Navigator.of(context).pop("success");
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
                        'Terjadi kesalahan saat mengirim data ke server\nError: ${err.toString()}'),
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
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('Gagal'),
                  content: Text(
                      'Nominal tidak boleh bernilai negatif atau kurang dari 0'),
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
          flexibleSpace: FlexibleSpaceBar(
              title: Text(
                titleForm,
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              centerTitle: true),
        ),
        SliverList(
            delegate: SliverChildListDelegate([
          loading
              ? loadingWidget()
              : Container(
                  padding: EdgeInsets.all(15),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Expanded(
                                  child: MaterialButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(0.0),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          radioValue = 0;
                                          titleForm = "Memberi Piutang";
                                          idTrxController.text = '';
                                          printTrx = null;
                                        });
                                      },
                                      child: Text("Memberi"),
                                      color: radioValue == 0
                                          ? Colors.red
                                          : Colors.grey,
                                      textColor: Colors.white)),
                              Expanded(
                                  child: MaterialButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(0.0),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          radioValue = 1;
                                          titleForm = "Menerima Piutang";
                                        });
                                      },
                                      child: Text("Menerima"),
                                      color: radioValue == 1
                                          ? Colors.green
                                          : Colors.grey,
                                      textColor: Colors.white)),
                            ],
                          ),
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                            controller: nominalController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Nominal',
                              errorStyle: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (String value) {
                              if (value == "") {
                                return "nominal tidak boleh kosong";
                              }
                            },
                            onSaved: (String value) {
                              setState(() {
                                nominal = value;
                              });
                            }),
                        SizedBox(height: 15.0),
                        GestureDetector(
                          onTap: () => _selectDate(),
                          child: AbsorbPointer(
                            child: FocusScope(
                              node: new FocusScopeNode(),
                              child: TextFormField(
                                controller: tglController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Tanggal',
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: keteranganController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Keterangan',
                            errorStyle: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                        ),
                        SizedBox(height: 15),
                        radioValue == 1
                            ? TextFormField(
                                controller: idTrxController,
                                keyboardType: TextInputType.text,
                                readOnly: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'ID Transaksi (Optional)',
                                  errorStyle: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                                onTap: () async {
                                  KasirPrintModel response =
                                      await Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => SelectTrxPiutang(
                                            widget.piutang.id)),
                                  );

                                  if (response == null) return;
                                  idTrxController.text = response.id;
                                  setState(() {
                                    printTrx = response;
                                  });
                                },
                              )
                            : SizedBox(height: 0.0),
                      ],
                    ),
                  ),
                ),
        ])),
      ]),
      bottomNavigationBar: bottomWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: loading
          ? null
          : FloatingActionButton.extended(
              backgroundColor: Theme.of(context).primaryColor,
              icon: Icon(Icons.send),
              label: Text('Kirim'),
              onPressed: () => prosesForm(),
            ),
    );
  }

  Widget bottomWidget() {
    return Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 20.0),
      width: double.infinity,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(.50),
            offset: Offset(0, -1),
            blurRadius: 10)
      ], color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Piutang',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          SizedBox(height: 5),
          Text('${formatRupiah(widget.saldoHutang)}',
              style: TextStyle(
                  fontSize: 16.0,
                  color: widget.saldoHutang > 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget loadingWidget() {
    return Center(
      child:
          SpinKitThreeBounce(color: Theme.of(context).primaryColor, size: 35),
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}

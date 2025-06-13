// @dart=2.9

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

// model
import 'package:mobile/models/kasir/hutang.dart';

// component

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/modules.dart';

class FormHutang extends StatefulWidget {
  HutangModel hutang;
  int saldoHutang;

  FormHutang(this.hutang, this.saldoHutang);

  @override
  createState() => FormHutangState();
}

class FormHutangState extends State<FormHutang> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nominalController = TextEditingController();
  TextEditingController keteranganController = TextEditingController();
  TextEditingController tglController = TextEditingController();

  // FORMAT TANGGAL
  DateTime selectedDate = DateTime.now();
  var formatter = new DateFormat('yyyy-MM-dd');
  // END

  bool loading = false;
  int radioValue = 0;
  String titleForm = "Bayar Hutang";
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
          'id_hutang': widget.hutang.id,
          'nominal': nominal,
          'tanggal': tglController.text,
          'keterangan': keteranganController.text,
          'radioValue': radioValue,
        };
        print(dataToSend);

        try {
          http.Response response = await http.post(
              Uri.parse('$apiUrlKasir/transaksi/hutang/addMutasi'),
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
                                        onPressed: () {
                                          setState(() {
                                            radioValue = 0;
                                            titleForm = "Bayar Hutang";
                                          });
                                        },
                                        child: Text("Bayar"),
                                        color: radioValue == 0
                                            ? Colors.green
                                            : Colors.grey,
                                        textColor: Colors.white)),
                                Expanded(
                                    child: MaterialButton(
                                        onPressed: () {
                                          setState(() {
                                            radioValue = 1;
                                            titleForm = "Minta Uang";
                                          });
                                        },
                                        child: Text("Minta"),
                                        color: radioValue == 1
                                            ? Colors.red
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
                        ],
                      ),
                    ),
                  )
          ]),
        )
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
          Text('Total Hutang',
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

// @dart=2.9

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';

// model
import 'package:mobile/models/kasir/customer.dart';
import 'package:mobile/models/kasir/listProduct.dart';

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

// SCREEN
import 'package:mobile/screen/select_state/customer.dart';
import 'package:mobile/screen/kasir/penjualan/detailPayment.dart';

import 'package:mobile/modules.dart';

class Payment extends StatefulWidget {
  VoidCallback clearOrders;
  List<ListProductModel> listItem;

  Payment(this.listItem, this.clearOrders);

  @override
  createState() => PaymentState();
}

class PaymentState extends State<Payment> {
  TextEditingController customerController = TextEditingController();
  TextEditingController keteranganController = TextEditingController();
  TextEditingController terminController = TextEditingController();
  TextEditingController jatuhTmpController =
      TextEditingController(); // controller tanggal jatuh tempo utk trx HUTANG

  // FORMAT TANGGAL
  DateTime selectedDate = DateTime.now();
  var formatter = new DateFormat('yyyy-MM-dd');
  // END

  bool loading = true;
  bool disableBtn = false;
  int radioValue = 0; // [0] -> CASH, [1] -> HUTANG
  int totalHarga = 0;
  int nominalAngka = 0; // uang bayar type integer
  String nominalStr = ""; // uang bayar type string
  List<ListProductModel> itemOrders = [];
  CustomerModel customer;

  @override
  void initState() {
    setData();
    super.initState();
    analitycs.pageView('/payment/kasir', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Payment Kasir',
    });
  }

  void setData() async {
    int harga = 0;
    widget.listItem.forEach((data) {
      itemOrders.add(data);
      harga += data.qty * data.hargaJual;
    });

    setState(() {
      loading = false;
      totalHarga = harga;
    });
  }

  // SELECT DATE
  Future _selectDate() async {
    DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(), //DateTime( DateTime.now().year - 1 , 5),
      lastDate: new DateTime(2500),
    );

    if (picked != null) {
      String value = formatter.format(picked);

      setState(() {
        selectedDate = picked;
        jatuhTmpController.text = value;
      });
    }
  }

  void _onKeyboardTap(String value) {
    String n = nominalStr + value;
    setState(() {
      nominalStr = n;
      nominalAngka = int.parse(n);
      disableBtn = radioValue == 1
          ? true
          : int.parse(n) >= totalHarga
              ? true
              : false;
    });
  }

  void _chooseCustomer() async {
    print('pilih pelanggan');
    CustomerModel response = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SelectCustomer()),
    );

    if (response == null) {
      if (customer == null) {
        setState(() {
          radioValue = 0;
          terminController.text = 'CASH';
          disableBtn = nominalAngka >= totalHarga ? true : false;
        });
      }
    } else {
      customerController.text = response.nama;
      setState(() {
        customer = response;
      });
    }
  }

  void _saveForm(context) async {
    Navigator.of(context, rootNavigator: true).pop();
    if (radioValue == 1 && customer == null) {
      _chooseCustomer();
    }
  }

  _setKeterangan() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width - 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'FORM TAMBAHAN',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    child: Row(
                      children: [
                        Expanded(
                            child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0.0),
                                ),
                                onPressed: () {
                                  setState(() {
                                    radioValue = 0;
                                    terminController.text = 'CASH';
                                    jatuhTmpController.text = '';
                                    selectedDate = DateTime.now();
                                    disableBtn = nominalAngka >= totalHarga
                                        ? true
                                        : false;
                                  });
                                },
                                child: Text("CASH"),
                                color: radioValue == 0
                                    ? Colors.green
                                    : Colors.grey,
                                textColor: Colors.white)),
                        Expanded(
                            child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0.0),
                                ),
                                onPressed: () {
                                  setState(() {
                                    radioValue = 1;
                                    terminController.text = 'HUTANG';
                                    disableBtn = true;
                                  });
                                },
                                child: Text("HUTANG"),
                                color:
                                    radioValue == 1 ? Colors.red : Colors.grey,
                                textColor: Colors.white)),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.0),
                  radioValue == 1
                      ? GestureDetector(
                          onTap: () => _selectDate(),
                          child: AbsorbPointer(
                            child: FocusScope(
                              node: new FocusScopeNode(),
                              child: TextFormField(
                                controller: jatuhTmpController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Jatuh Tempo',
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  SizedBox(height: 10.0),
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
          );
        }),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text(
              'TUTUP',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
          TextButton(
            child: Text(
              'SIMPAN',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            onPressed: () => _saveForm(context),
          )
        ],
      ),
    );
  }

  void paymentOrder() async {
    print('kirim orderan ke server utk di proses');
    if (itemOrders.length > 0) {
      setState(() {
        loading = true;
      });
      try {
        var orders = [];
        itemOrders.forEach((item) {
          orders.add({
            'id_gudang': item.id,
            'id_barang': item.id_barang,
            'sku': item.sku,
            'nama_barang': item.namaBarang,
            'stock': item.stock,
            'qty': item.qty,
            'harga_beli': item.hargaBeli,
            'harga_jual': item.hargaJual,
            'id_kategori': item.id_kategori,
            'id_satuan': item.id_satuan,
          });
        });

        Map<String, dynamic> dataToSend = {
          'id_customer': customer != null ? customer.id : null,
          'keterangan': keteranganController.text,
          'termin': radioValue,
          'jatuhTempo': jatuhTmpController.text,
          'totalHarga': totalHarga,
          'uangBayar': nominalAngka,
          'orders': orders,
        };

        http.Response response =
            await http.post(Uri.parse('$apiUrlKasir/transaksi/penjualan/trx'),
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
            print(responseData);
            widget.clearOrders(); // clear transaksi sebelum nya
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Berhasil'),
                content: Text(message),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            );

            dynamic response =
                await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => DetailPayment(
                  // itemOrders,
                  responseData['idTrx']),
            ));

            if (response == null) {
              setState(() {
                disableBtn = false;
                radioValue = 0; // [0] -> CASH, [1] -> HUTANG
                totalHarga = 0;
                nominalAngka = 0; // uang bayar type integer
                nominalStr = ""; // uang bayar type string
                itemOrders.clear();
                CustomerModel customer;
              });
            }
          } else {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: Text('Warning'),
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
                    title: Text('Warning'),
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
                  title: Text('Warning'),
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
                title: Text('Pemberitahuan'),
                content: Text('Maaf Daftar Pesanan Anda Kosong'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'Total : ${formatNominal(totalHarga)}',
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  '${formatRupiah(nominalAngka)}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 38.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: buildMiddle(),
                ),
              ),
              SizedBox(height: 20.0),
              loading
                  ? loadingWidget()
                  : NumericKeyboard(
                      onKeyboardTap: _onKeyboardTap,
                      textColor: Colors.black,
                      rightButtonFn: () {
                        if (nominalStr.length > 0) {
                          String n =
                              nominalStr.substring(0, nominalStr.length - 1);
                          String valStr = n.length > 0 ? n : '';
                          int valNumber = n.length > 0 ? int.parse(n) : 0;

                          setState(() {
                            nominalStr = valStr;
                            nominalAngka = valNumber;
                            disableBtn = radioValue == 1
                                ? true
                                : valNumber >= totalHarga
                                    ? true
                                    : false;
                          });
                        } else {
                          setState(() {
                            nominalStr = "";
                            nominalAngka = 0;
                            disableBtn = radioValue == 1 ? true : false;
                          });
                        }
                      },
                      rightIcon: Icon(
                        Icons.backspace,
                        color: Colors.black,
                      ),
                      leftButtonFn: () => disableBtn ? paymentOrder() : null,
                      leftIcon: Icon(
                        Icons.check,
                        color: disableBtn
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                        size: 30.0,
                      ),
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly)
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMiddle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 10.0),
        InkWell(
          onTap: () => _chooseCustomer(),
          child: Container(
            padding: EdgeInsets.all(3.0),
            margin: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3.0),
                border: Border.all(color: Colors.grey)),
            child: Text(
              '${customerController.text != '' ? customerController.text : 'Pelanggan'}',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ),
        SizedBox(width: 10.0),
        InkWell(
          onTap: () => _setKeterangan(),
          child: Container(
            padding: EdgeInsets.all(3.0),
            margin: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3.0),
                border: Border.all(color: Colors.grey)),
            child: Text(
              'Keterangan Struk',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ),
        SizedBox(width: 10.0),
        InkWell(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.all(3.0),
            margin: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3.0),
                border: Border.all(color: Theme.of(context).primaryColor)),
            child: Text(
              'Permbayaran : ${radioValue == 0 ? 'CASH' : 'HUTANG'}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ],
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

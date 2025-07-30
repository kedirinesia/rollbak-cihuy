// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/Products/payuniblibli/layout/transaksi/trx_banner.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/models/postpaid.dart';
import 'package:mobile/modules.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screen/transaksi/verifikasi_pin.dart';

class PostpaidPage extends StatefulWidget {
  final MenuModel menu;
  PostpaidPage(this.menu);

  @override
  _PostpaidPageState createState() => _PostpaidPageState();
}

class _PostpaidPageState extends State<PostpaidPage> {
  bool _loading = false;
  TextEditingController _idpel = TextEditingController();
  PostpaidInquiryModel inq;

  @override
  void dispose() {
    _idpel.dispose();
    super.dispose();
  }

  Future<void> inquiry() async {
    if (_loading) return;
    if (_idpel.text.isEmpty)
      return showToast(context, 'Nomor meter atau ID pelanggan masih kosong');

    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
    });

    http.Response response = await http.post(
      Uri.parse('$apiUrl/trx/postpaid/inquiry'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': bloc.token.valueWrapper?.value,
      },
      body: json.encode({
        'kode_produk': widget.menu.kodeProduk,
        'tujuan': _idpel.text.trim(),
        'counter': 1,
      }),
    );

    if (response.statusCode == 200) {
      inq = PostpaidInquiryModel.fromJson(json.decode(response.body)['data']);
    } else {
      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan saat mengambil data tagihan';
      showToast(context, message);
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> purchase() async {
    if (inq == null) return;
    if (_loading) return;
    if (inq.total > bloc.user.valueWrapper?.value.saldo)
      return showToast(context, 'Saldo tidak mencukupi');

    String pin = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VerifikasiPin(),
      ),
    );

    if (pin == null) return;
    setState(() {
      _loading = true;
    });

    sendDeviceToken();
    http.Response response = await http.post(
      Uri.parse('$apiUrl/trx/postpaid/purchase'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': bloc.token.valueWrapper?.value,
      },
      body: json.encode({
        'tracking_id': inq.trackingId,
      }),
    );

    if (response.statusCode == 200) {
      String message =
          'Transaksi diproses, silahkan cek status tagihan pada riwayat transaksi';
      showToast(context, message);
    } else {
      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan saat melakukan transaksi';
      showToast(context, message);
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menu.name),
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade100,
      body: ListView(
        children: [
          BannerTransaction(),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.all(15),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.menu.description,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  'Nomor Meter / ID Pelanggan',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _idpel,
                  autofocus: true,
                  keyboardType: widget.menu.isString
                      ? TextInputType.text
                      : TextInputType.number,
                  inputFormatters: [
                    widget.menu.isString
                        ? FilteringTextInputFormatter.allow(
                            RegExp("[0-9a-zA-Z-_.]"))
                        : FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    // suffixIcon: _idpel.text.isEmpty
                    //     ? IconButton(
                    //         icon: Icon(Icons.contacts_rounded),
                    //         onPressed: () async {
                    //           String nomor = await Navigator.of(context).push(
                    //             MaterialPageRoute(
                    //               builder: (_) => ContactPage(),
                    //             ),
                    //           );
                    //           if (nomor == null) return;
                    //           if (nomor.startsWith('62')) {
                    //             _idpel.text = '0' + nomor.substring(2);
                    //           } else if (nomor.startsWith('+62')) {
                    //             _idpel.text = '0' + nomor.substring(3);
                    //           } else {
                    //             _idpel.text = nomor;
                    //           }
                    //         },
                    //       )
                    //     : IconButton(
                    //         icon: Icon(Icons.close),
                    //         onPressed: () {
                    //           setState(() {
                    //             _idpel.clear();
                    //           });
                    //         },
                    //       ),
                  ),
                ),
                SizedBox(height: 10),
                _loading
                    ? Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: SpinKitThreeBounce(
                            color: Theme.of(context).primaryColor,
                            size: 25,
                          ),
                        ),
                      )
                    : inq != null
                        ? Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Info Tagihan'),
                                SizedBox(height: 15),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Text('No Pelanggan'),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 7,
                                      child: Text(
                                        inq.noPelanggan,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Text('Nama'),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 7,
                                      child: Text(
                                        inq.nama,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                inq.params.length > 0
                                    ? SizedBox(height: 5)
                                    : SizedBox(),
                                ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: inq.params.length,
                                  separatorBuilder: (_, __) =>
                                      SizedBox(height: 5),
                                  itemBuilder: (_, i) {
                                    Map<String, dynamic> param =
                                        inq.params.elementAt(i);

                                    return Row(
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Text(param['label']),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          flex: 7,
                                          child: Text(
                                            param['value'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                inq.params.length > 0
                                    ? SizedBox(height: 5)
                                    : SizedBox(),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Text('Tagihan'),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 7,
                                      child: Text(
                                        formatRupiah(inq.tagihan),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Text('Admin'),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 7,
                                      child: Text(
                                        formatRupiah(inq.admin),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Text('Total'),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 7,
                                      child: Text(
                                        formatRupiah(inq.total),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : SizedBox(),
                SizedBox(height: 30),
                MaterialButton(
                  minWidth: double.infinity,
                  elevation: 0,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  child: Text(
                      inq == null ? 'Cek Tagihan' : 'Lanjut ke pembayaran'),
                  onPressed: inq == null ? inquiry : purchase,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

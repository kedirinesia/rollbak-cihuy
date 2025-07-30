// @dart=2.9

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

// model
import 'package:mobile/models/kasir/kasirPrint.dart';

// component
import 'package:mobile/component/loader.dart';

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/modules.dart';

// page screen
import 'package:mobile/screen/kasir/laporan/jual/lapDetailJual.dart';

class LapJual extends StatefulWidget {
  @override
  createState() => LapJualState();
}

class LapJualState extends State<LapJual> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  TextEditingController tglAwalController = TextEditingController();
  TextEditingController tglAkhirController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  List<KasirPrintModel> listTrxs = [];
  List<KasirPrintModel> tmpTrxs = [];

  // FORMAT TANGGAL
  var formatter = new DateFormat('yyyy-MM-dd');
  DateTime selectedAwal = getFirstDate();
  DateTime selectedAkhir = DateTime.now();
  // END

  int page = 0;
  bool isEdge = false;
  bool loading = true;
  int totalJual = 0;
  int totalBeli = 0;
  int keuntungan = 0;

  @override
  initState() {
    getData();

    super.initState();
  }

  void getData() async {
    setState(() {
      tglAwalController.text = formatter.format(selectedAwal);
      tglAkhirController.text = formatter.format(selectedAkhir);
    });
    try {
      if (isEdge) return;
      http.Response response = await http.get(
          Uri.parse(
              '$apiUrlKasir/laporan/penjualan?page=$page&tgl_awal=${tglAwalController.text}&tgl_akhir=${tglAkhirController.text}'),
          headers: {
            'authorization': bloc.token.valueWrapper?.value,
          });

      var responseData = json.decode(response.body);
      String message = responseData['message'] ??
          'Terjadi kesalahan saat mengambil data dari server';
      if (response.statusCode == 200) {
        int status = responseData['status'];
        Map datas = responseData['data'];
        var nominal = datas['nominal'];
        var trx = datas['trx'];

        if (trx.length == 0)
          setState(() {
            isEdge = true;
            loading = false;
          });
        if (status == 200) {
          trx.forEach((data) {
            listTrxs.add(KasirPrintModel.fromJson(data));
            tmpTrxs.add(KasirPrintModel.fromJson(data));
          });

          setState(() {
            page++;
            totalJual = nominal['totalJual'];
            totalBeli = nominal['totalBeli'];
            keuntungan = nominal['keuntungan'];
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

  void refreshData() async {
    setState(() {
      listTrxs.clear();
      tmpTrxs.clear();
      page = 0;
      loading = true;
      isEdge = false;
    });

    getData();
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
        title: Text('Laporan Penjualan'),
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            _buildBox(),
            SizedBox(height: 15.0),
            Flexible(
              flex: 1,
              child: loading
                  ? LoadWidget()
                  : listTrxs.length == 0
                      ? buildEmpty()
                      : SmartRefresher(
                          controller: _refreshController,
                          enablePullUp: true,
                          enablePullDown: true,
                          onRefresh: () async {
                            refreshData();
                            _refreshController.refreshCompleted();
                          },
                          onLoading: () async {
                            getData();
                            _refreshController.loadComplete();
                          },
                          child: ListView.separated(
                              shrinkWrap: true,
                              physics: ScrollPhysics(),
                              padding: EdgeInsets.all(10.0),
                              itemCount: listTrxs.length,
                              separatorBuilder: (_, i) => SizedBox(height: 10),
                              itemBuilder: (ctx, i) {
                                KasirPrintModel trx = listTrxs[i];
                                return _buildItem(trx);
                              })),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET ITEM
  Widget _buildItem(KasirPrintModel trx) {
    return InkWell(
      onTap: () async {
        dynamic response = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => LapDetailJual(trx.id),
        ));

        refreshData();
      },
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.1),
              offset: Offset(5, 10.0),
              blurRadius: 20)
        ]),
        child: ListTile(
          title: Text(
            'ID Trx : ${trx.id.toUpperCase()}',
            style: TextStyle(fontSize: 13.0, color: Colors.grey.shade700),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5.0),
              Text(
                  'Pelanggan : ${trx.customerModel != null ? trx.customerModel.nama : '-'}',
                  style:
                      TextStyle(fontSize: 13.0, color: Colors.grey.shade700)),
              SizedBox(height: 5.0),
              Text('Harga Beli : ${formatNominal(trx.totalBeli)}',
                  style:
                      TextStyle(fontSize: 13.0, color: Colors.grey.shade700)),
              SizedBox(height: 5.0),
              Text('Harga Jual : ${formatNominal(trx.totalJual)}',
                  style:
                      TextStyle(fontSize: 13.0, color: Colors.grey.shade700)),
              SizedBox(height: 5.0),
              RichText(
                text: TextSpan(
                  text: 'Status : ',
                  style: TextStyle(fontSize: 13.0, color: Colors.grey.shade700),
                  children: [
                    TextSpan(
                        text: trx.lunas ? 'LUNAS' : 'BELUM LUNAS',
                        style: TextStyle(
                          fontSize: 13.0,
                          color: trx.lunas ? Colors.green : Colors.red,
                        )),
                  ],
                ),
              ),
              SizedBox(height: 5.0),
              Text(
                  'Tanggal : ${formatDate(trx.created_at, 'd MMMM yyyy HH:mm:ss')}',
                  style:
                      TextStyle(fontSize: 13.0, color: Colors.grey.shade700)),
            ],
          ),
          trailing: Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: Theme.of(context).primaryColor,
            ),
            child: Text('${trx.totalQty}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ),
      ),
    );
  }

  // WIDGET BOX TOP
  Widget _buildBox() {
    return Container(
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(.1),
            blurRadius: 10.0,
            offset: Offset(5, 10))
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${formatRupiah(totalJual)}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      'Pendapatan',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${formatRupiah(totalBeli)}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      'Pembelian',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(),
          Container(
            padding: EdgeInsets.all(10.0),
            child: RichText(
              text: TextSpan(
                text: 'Keuntungan ',
                style: TextStyle(
                  color: keuntungan > 0 ? Colors.green : Colors.red,
                  fontSize: 12.0,
                ),
                children: [
                  TextSpan(
                    text: '${formatRupiah(keuntungan)}',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: keuntungan > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
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
                        refreshData();
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

  // WIDGET EMPTY
  Widget buildEmpty() {
    return Center(
      child: SvgPicture.asset('assets/img/empty.svg',
          width: MediaQuery.of(context).size.width * .45),
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}

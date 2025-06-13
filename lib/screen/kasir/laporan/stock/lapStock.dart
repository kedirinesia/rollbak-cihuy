// @dart=2.9

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

// model
import 'package:mobile/models/kasir/persediaan.dart';

// component
import 'package:mobile/component/loader.dart';

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

import 'package:mobile/modules.dart';

// PAGE SCREEN
import 'package:mobile/screen/kasir/laporan/stock/lapDetailStock.dart';

class LapStock extends StatefulWidget {
  @override
  createState() => LapStockState();
}

class LapStockState extends State<LapStock> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  TextEditingController tglAwalController = TextEditingController();
  TextEditingController tglAkhirController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  List<LapStockModel> listStocks = [];

  // FORMAT TANGGAL
  var formatter = new DateFormat('yyyy-MM-dd');
  DateTime selectedAwal = getFirstDate(); //DateTime.now();
  DateTime selectedAkhir = DateTime.now();
  // END

  int page = 0;
  bool isEdge = false;
  bool loading = true;
  int totalStock = 0;

  @override
  void initState() {
    getData();

    super.initState();
    analitycs.pageView('/lapStok/kasir', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Laporan Stok Kasir',
    });
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
              '$apiUrlKasir/laporan/arus-stock?page=$page&tgl_awal=${tglAwalController.text}&tgl_akhir=${tglAkhirController.text}'),
          headers: {
            'authorization': bloc.token.valueWrapper?.value,
          });

      var responseData = json.decode(response.body);
      String message = responseData['message'] ??
          'Terjadi kesalahan saat mengambil data dari server';
      if (response.statusCode == 200) {
        int status = responseData['status'];
        var datas = responseData['data'];
        var hasil = datas['hasil'];

        if (hasil.length == 0)
          setState(() {
            isEdge = true;
            loading = false;
          });
        if (status == 200) {
          hasil.forEach((data) {
            listStocks.add(LapStockModel.fromJson(data));
          });

          setState(() {
            page++;
            totalStock = datas['totalStock'] != null ? datas['totalStock'] : 0;
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

  // REFRESH DATA
  void refreshData() async {
    setState(() {
      listStocks.clear();
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
        title: Text('Laporan Stok Barang'),
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
      bottomNavigationBar: bottomWidget(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: loading
            ? LoadWidget()
            : listStocks.length == 0
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
                        itemCount: listStocks.length,
                        separatorBuilder: (_, i) => SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          LapStockModel item = listStocks[i];
                          return _buildItem(item);
                        })),
      ),
    );
  }

  // WIDGET ITEM
  Widget _buildItem(LapStockModel item) {
    return InkWell(
      onTap: () async {
        dynamic response = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => LapDetailStock(
            item.barangModel != null ? item.barangModel.namaBarang : '-',
            item.id_barang,
            tglAwalController.text,
            tglAkhirController.text,
          ),
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
            '${item.barangModel != null ? item.barangModel.namaBarang : '-'}',
            style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5.0),
              Text('Stok Masuk : ${item.debet} item',
                  style:
                      TextStyle(fontSize: 13.0, color: Colors.grey.shade700)),
              SizedBox(height: 5.0),
              Text('Stok Keluar : ${item.kredit} item',
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
            child: Text('${item.debet - item.kredit}',
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

  // WIDGET BOTTOM BAR
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
          Text('Total Stok',
              style: TextStyle(fontSize: 11, color: Colors.grey)),
          SizedBox(height: 5),
          Text('$totalStock',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                  fontWeight: FontWeight.bold)),
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

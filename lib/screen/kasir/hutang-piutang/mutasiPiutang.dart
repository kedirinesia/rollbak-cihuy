// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';

// install package
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

// model
import 'package:mobile/models/kasir/piutang.dart';

// component
import 'package:mobile/component/loader.dart';

// config bloc
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';

import 'package:mobile/modules.dart';

// SCREEN PAGE
import 'package:mobile/screen/kasir/hutang-piutang/form/formPiutang.dart';
import 'package:share/share.dart';

class MutasiPiutang extends StatefulWidget {
  PiutangModel piutang;
  MutasiPiutang(this.piutang);

  @override
  createState() => DetailPiutangState();
}

class DetailPiutangState extends State<MutasiPiutang> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<MutasiPiutangModel> detailPiutangs = [];

  int page = 0;
  bool loading = true;
  bool isEdge = false;
  int saldoHutang = 0;

  @override
  initState() {
    getData();

    super.initState();
  }

  void getData() async {
    try {
      if (isEdge) return;
      Map<String, dynamic> dataToSend = {
        'id_piutang': widget.piutang.id,
      };

      http.Response response = await http.post(
          Uri.parse('$apiUrlKasir/transaksi/piutang/detail?page=$page'),
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
          datas.forEach((data) {
            detailPiutangs.add(MutasiPiutangModel.fromJson(data));
          });
          setState(() {
            page++;
            saldoHutang = responseData['saldoHutang'];
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
                content:
                    Text('Terjadi kesalahan saat mengambil data dari server'),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ));
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void onPressed() async {
    dynamic response = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FormPiutang(
        widget.piutang,
        saldoHutang,
      ),
    ));

    if (response != null) {
      setState(() {
        page = 0;
        isEdge = false;
        detailPiutangs.clear();
      });
      getData();
    }
  }

  void share() {
    List<String> detailPiutang = [];

    detailPiutangs.forEach((e) {
      detailPiutang.add(
          'Nominal: ${formatRupiah(e.debet)} \nTanggal: ${formatDate(e.created_at, 'd MMMM yyyy HH:mm:ss')} \n\n');
    });

    String title = configAppBloc.namaApp.valueWrapper?.value;
    String separator =
        '------------------------------------------------------------';
    String desc =
        '''Hai Kak...! \n\n|Jadilah pelanggan yang bijak dengan cara melakukan pembayaran hutang tepat pada waktunya. \n|$separator \n\n|Detail piutang: \n\n||Total: ${formatRupiah(saldoHutang)} \n\n|Untuk mekanisme pembayaran bisa hubungi nomor kami kak: ${bloc.user.valueWrapper?.value.phone} \n\n|*Salam ${bloc.user.valueWrapper?.value.namaToko}*''';

    List<String> splitSubj = desc.split('|');

    detailPiutang.forEach((element) => splitSubj.insert(5, element));

    String descFinal = splitSubj.join();

    Share.share(descFinal, subject: title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          '${widget.piutang.customerModel.nama}',
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              size: 30.0,
              color: Colors.white,
            ),
            onPressed: () => onPressed(),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            _buildBoxTop(),
            SizedBox(height: 10.0),
            _buildTopHeader(),
            SizedBox(height: 5.0),
            Flexible(
              flex: 1,
              child: loading
                  ? LoadWidget()
                  : detailPiutangs.length == 0
                      ? buildEmpty()
                      : SmartRefresher(
                          controller: _refreshController,
                          enablePullUp: true,
                          enablePullDown: true,
                          onRefresh: () async {
                            page = 0;
                            isEdge = false;
                            detailPiutangs.clear();
                            getData();
                            _refreshController.refreshCompleted();
                          },
                          onLoading: () async {
                            getData();
                            _refreshController.loadComplete();
                          },
                          child: ListView.separated(
                              shrinkWrap: true,
                              physics: ScrollPhysics(),
                              itemCount: detailPiutangs.length,
                              separatorBuilder: (_, i) => SizedBox(height: 5),
                              itemBuilder: (ctx, i) {
                                MutasiPiutangModel _detailPiutang =
                                    detailPiutangs[i];
                                return _buildItem(_detailPiutang);
                              }),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(Icons.share),
          onPressed: () => share()),
    );
  }

  Widget _buildItem(MutasiPiutangModel detailPiutang) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.1),
              offset: Offset(5, 10.0),
              blurRadius: 20)
        ]),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${detailPiutang.keterangan} ',
                    textScaleFactor: 0.9,
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    formatDate(detailPiutang.created_at, 'd MMMM yyyy'),
                    textScaleFactor: 0.8,
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                '${formatNominal(detailPiutang.debet)}',
                textScaleFactor: 1.2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.red,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '${formatNominal(detailPiutang.kredit)}',
                textScaleFactor: 1.2,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Catatan',
              textScaleFactor: 0.9,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Memberi',
              textScaleFactor: 0.9,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Menerima',
              textScaleFactor: 0.9,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoxTop() {
    return Container(
      margin: EdgeInsets.all(20.0),
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(.1),
            blurRadius: 10.0,
            offset: Offset(5, 10))
      ]),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                saldoHutang > 0 ? 'Hutang Pelanggan' : 'Lunas',
                style: TextStyle(
                  fontSize: 18.0,
                  color: saldoHutang > 0 ? Colors.grey.shade700 : Colors.green,
                  fontWeight:
                      saldoHutang > 0 ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              Text(
                '${formatRupiah(saldoHutang > 0 ? saldoHutang : 0)}',
                style: TextStyle(
                  fontSize: 20.0,
                  color: saldoHutang > 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: widget.piutang.jatuhTempo != '' ? 5.0 : 0.0),
          widget.piutang.jatuhTempo != '' ? Divider() : SizedBox(height: 0),
          SizedBox(height: widget.piutang.jatuhTempo != '' ? 5.0 : 0.0),
          widget.piutang.jatuhTempo != ''
              ? Text(
                  formatDate(widget.piutang.jatuhTempo, 'd MMMM yyyy'),
                  style: TextStyle(fontSize: 15.0, color: Colors.grey.shade700),
                )
              : Text(
                  'Sampai Akhir Hayat',
                  style: TextStyle(fontSize: 15.0, color: Colors.grey.shade700),
                )
        ],
      ),
    );
  }

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

// @dart=2.9

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:installed_apps/installed_apps.dart';

import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

import 'package:http/http.dart' as http;
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/config.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/custom_alert_dialog.dart';
import 'package:qr_flutter/qr_flutter.dart';
// import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import 'package:mobile/models/trx.dart';
import 'package:mobile/models/bank.dart';
import 'package:mobile/modules.dart';

import 'package:mobile/screen/transaksi/print.dart';
import 'package:mobile/screen/printPreviewSby.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailTransaksi extends StatefulWidget {
  final TrxModel data;

  DetailTransaksi(this.data);
  @override
  _DetailTransaksiState createState() => _DetailTransaksiState();
}

class _DetailTransaksiState extends State<DetailTransaksi> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  TrxModel trx;
  List<BankModel> banks = [];
  ScreenshotController _screenshotController = ScreenshotController();
  File image;
  bool danaApp = false;
  bool customPrint = false;

  @override
  void initState() {
    trx = widget.data;
    print("SAMPAI SINI $trx");
    super.initState();
    analitycs.pageView('/history/transaksi/' + trx.id, {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'History Transaksi '
    });
    getData();
    checkingDanaApp();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void checkingDanaApp() async {
    InstalledApps.getAppInfo('id.dana').then((app) {
      print(app);
      setState(() {
        danaApp = true;
      });
    }).catchError((e) {
      setState(() {
        danaApp = false;
      });
    });
  }

  Future<String> getPhoneNumberCs() async {
    print("=== FETCHING CUSTOMER SERVICE DATA ===");
    print("API URL: $apiUrl/cs/list");
    print("Token: ${bloc.token.valueWrapper?.value}");
    
    try {
      String link;

      http.Response response = await http.get(Uri.parse('$apiUrl/cs/list'),
          headers: {'Authorization': bloc.token.valueWrapper?.value});
      
      print("CS Response Status Code: ${response.statusCode}");
      print("CS Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        List<dynamic> responseData = json.decode(response.body)['data'];
        print("=== PARSED CS DATA ===");
        print("Number of CS entries: ${responseData.length}");
        print("Raw CS data: $responseData");
        
        responseData.forEach((e) {
          print("CS Entry: $e");
          print("CS Link: ${e['link']}");
          if (e['link'] is String &&
              (e['link'] as String).contains('api.whatsapp.com')) {
            link = e['link'];
            print("Found WhatsApp link: $link");
          }
        });
        print("Final selected link: $link");
      } else {
        print("CS API call failed with status code: ${response.statusCode}");
      }
      return link;
    } catch (err) {
      print("Error fetching CS data: $err");
      return '';
    }
  }

  Future<void> sendWhatsApp() async {
    // String phoneNumber = await getPhoneNumberCs();
    String link = await getPhoneNumberCs();

    if (link == null) return;
    print(link);

    // if (phoneNumber == null) return;

    // phoneNumber = phoneNumber.replaceAll(RegExp("[^0-9]"), "");
    // phoneNumber = phoneNumber.replaceFirst(RegExp('0'), '62');

    // Map<String, String> phones = {
    //   'mypay.co.id': '6282352513472',
    //   'payku.id': '628871500528',
    //   'com.payuni.popay': '628882436151',
    //   'com.payuni.id': '6281617118314',
    //   'co.pakaiaja.id': '628980000073',
    //   'com.mocipay.app': '6282213893106',
    //   'com.centralbayar.apk': '6285222222281',
    //   'ayoba.co.id': '6287890000023',
    // };

    String keluhan = '';
    if (trx.status == 0 || trx.status == 1) {
      keluhan = '*Transaksi masih pending, Mohon dibantu kak.*';
    } else if (trx.status == 2) {
      keluhan = '*Transaksi sukses tapi belum masuk, Mohon dibantu kak.*';
    } else if (trx.status == 3) {
      keluhan = '*Bantu cek alasan gagalnya apa ya?*';
    }

    String message =
        'Halo min, saya mengalami kendala transaksi, mohon dibantu.\r\nID: *${trx.id}*\r\nTujuan: *${trx.tujuan}*\r\nTanggal: *${formatDate(trx.created_at, "d MMMM yyyy HH:mm:ss")}*\r\nKode: *${trx.produk['kode_produk']}*\r\nNama Produk: *${trx.produk['nama']}*\r\nSN: *${trx.sn}*\r\n\r\nKeluhan: $keluhan';
    // String url = Uri.encodeFull(
    //     'https://api.whatsapp.com/send?phone=$phoneNumber&text=$message');
    String url = '$link&text=${Uri.encodeFull(message)}';

    launch(url);
  }

  Future<void> getData() async {
    print("=== FETCHING TRANSACTION DATA ===");
    print("API URL: $apiUrl/trx/${widget.data.id}/print");
    print("Token: ${bloc.token.valueWrapper?.value}");
    
    http.Response response = await http.get(
        Uri.parse('$apiUrl/trx/${widget.data.id}/print'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");
    
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body)['data'];
      print("=== PARSED RESPONSE DATA ===");
      print("Full Response Data: $responseData");
      print("Payment By: ${responseData['payment_by']}");
      
      if (responseData['payment_by'] == 'transfer') {
        print("Payment is transfer, fetching bank data...");
        await getBank();
      }
      setState(() {
        trx = TrxModel.fromJson(responseData);
        customPrint = responseData['custom_print'] ?? false;
        print("=== TRANSACTION MODEL CREATED ===");
        print("Transaction ID: ${trx.id}");
        print("Transaction Status: ${trx.status}");
        print("Transaction Amount: ${trx.harga_jual}");
        print("Transaction Target: ${trx.tujuan}");
        print("Product Info: ${trx.produk}");
        print("Payment Method: ${trx.paymentBy}");
        print("Serial Number: ${trx.sn}");
        print("Created At: ${trx.created_at}");
        print("Keterangan: ${trx.keterangan}");
        print("Point: ${trx.point}");
        print("Print Data: ${trx.print}");
        print("Payment Detail: ${trx.paymentDetail}");
        print("Status Model: ${trx.statusModel}");
        print("Custom Print: $customPrint");
      });
    } else {
      print("API call failed with status code: ${response.statusCode}");
    }
  }

  Future<void> getBank() async {
    print("=== FETCHING BANK DATA ===");
    print("API URL: $apiUrl/bank/list?type=1");
    print("Token: ${bloc.token.valueWrapper?.value}");
    
    http.Response response = await http.get(
        Uri.parse('$apiUrl/bank/list?type=1'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});
    
    print("Bank Response Status Code: ${response.statusCode}");
    print("Bank Response Body: ${response.body}");
    
    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      print("=== PARSED BANK DATA ===");
      print("Number of banks: ${datas.length}");
      print("Raw bank data: $datas");
      
      banks = datas.map((e) => BankModel.fromJson(e)).toList();
      print("=== BANK MODELS CREATED ===");
      for (int i = 0; i < banks.length; i++) {
        print("Bank ${i + 1}:");
        print("  - Name: ${banks[i].namaBank}");
        print("  - Account Number: ${banks[i].noRek}");
        print("  - Account Holder: ${banks[i].namaRekening}");
        print("  - Is Gangguan: ${banks[i].isGangguan}");
      }
    } else {
      print("Bank API call failed with status code: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Transaksi'),
        centerTitle: true,
        backgroundColor: packageName == 'com.lariz.mobile'
            ? Theme.of(context).secondaryHeaderColor
            : Theme.of(context).primaryColor,
        elevation: 0,
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
      body: Container(
        color: Theme.of(context).canvasColor,
        child: SmartRefresher(
          controller: _refreshController,
          enablePullUp: false,
          onRefresh: () async {
            await getData();
            _refreshController.refreshCompleted();
          },
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(15),
            children: <Widget>[
              Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(.1),
                            offset: Offset(5, 10.0),
                            blurRadius: 20)
                      ]),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                                trx.produk == null
                                    ? '-'
                                    : trx.produk['nama'] ?? '-',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: packageName == 'com.lariz.mobile'
                                      ? Theme.of(context).secondaryHeaderColor
                                      : Theme.of(context).primaryColor,
                                ))
                          ],
                        ),
                        Divider(),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: trx.tujuan))
                                .then((_) {
                              showToast(
                                  context, 'Berhasil menyalin nomor tujuan');
                            });
                          },
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Nomor Tujuan',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 11)),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(trx.tujuan,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(width: 5),
                                    Icon(
                                      Icons.copy_rounded,
                                      size: 17,
                                      color: packageName == 'com.lariz.mobile'
                                          ? Theme.of(context)
                                              .secondaryHeaderColor
                                          : Theme.of(context).primaryColor,
                                    ),
                                  ],
                                )
                              ]),
                        ),
                        SizedBox(height: 10),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Deskripsi Produk',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 11)),
                              SizedBox(height: 5),
                              Text(
                                  trx.produk == null
                                      ? '-'
                                      : trx.produk['description'] ?? '-',
                                  style: TextStyle(fontWeight: FontWeight.bold))
                            ]),
                        SizedBox(height: 10),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Harga',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 11)),
                              SizedBox(height: 5),
                              Text(formatRupiah(trx.harga_jual),
                                  style: TextStyle(fontWeight: FontWeight.bold))
                            ]),
                        SizedBox(height: 10),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Admin',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 11)),
                              SizedBox(height: 5),
                              Text(formatRupiah(trx.admin),
                                  style: TextStyle(fontWeight: FontWeight.bold))
                            ]),
                        SizedBox(height: 10),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Methode Pembayaran',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 11)),
                              SizedBox(height: 5),
                              Text(
                                  trx.paymentBy != null
                                      ? trx.paymentBy.toUpperCase()
                                      : 'BALANCE',
                                  style: TextStyle(fontWeight: FontWeight.bold))
                            ]),
                      ])),
              SizedBox(height: trx.paymentBy == 'balance' ? 0.0 : 20.0),
              trx.paymentBy == 'balance'
                  ? SizedBox(height: 0.0)
                  : trx.status == 4
                      ? trx.paymentBy == 'transfer'
                          ? viewPaymentTrf()
                          : viewPaymentQris()
                      : Container(),
              SizedBox(height: 20.0),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(.1),
                          offset: Offset(5, 10.0),
                          blurRadius: 20)
                    ]),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Informasi Transaksi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: packageName == 'com.lariz.mobile'
                                    ? Theme.of(context).secondaryHeaderColor
                                    : Theme.of(context).primaryColor,
                              )),
                          Icon(
                            Icons.receipt,
                            color: packageName == 'com.lariz.mobile'
                                ? Theme.of(context).secondaryHeaderColor
                                : Theme.of(context).primaryColor,
                          )
                        ],
                      ),
                      Divider(),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Status',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                            SizedBox(height: 5),
                            Text(trx.statusModel.statusText.toUpperCase(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: trx.statusModel.color))
                          ]),
                      SizedBox(height: 10),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Keterangan',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                            SizedBox(height: 5),
                            Text(trx.keterangan == null ? '-' : trx.keterangan,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ))
                          ]),
                      SizedBox(height: 10),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Pengisian Ke',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                            SizedBox(height: 5),
                            Text(trx.counter.toString(),
                                style: TextStyle(fontWeight: FontWeight.bold))
                          ]),
                      SizedBox(height: 10),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Bonus Poin',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                            SizedBox(height: 5),
                            Text('${formatNumber(trx.point)} Poin',
                                style: TextStyle(fontWeight: FontWeight.bold))
                          ]),
                      SizedBox(height: 10),
                      trx.print.length == 0
                          ? InkWell(
                              onLongPress: () async {
                                await Clipboard.setData(
                                    ClipboardData(text: trx.sn));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text("Serial number berhasil disalin"),
                                  ),
                                );
                              },
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('Nomor Serial',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 11)),
                                    SizedBox(height: 5),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Flexible(
                                              flex: 1,
                                              child: Container(
                                                child: Text(trx.sn,
                                                    overflow: TextOverflow.clip,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ))
                                        ])
                                  ]),
                            )
                          : SizedBox(),
                      trx.print.length == 0 ? SizedBox(height: 10) : SizedBox(),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: trx.print.length,
                        separatorBuilder: (_, i) => SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                trx.print[i]['label'],
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      trx.print[i]['value'].toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      width: trx.print[i]['label']
                                              .toString()
                                              .toLowerCase()
                                              .contains('token')
                                          ? 5
                                          : 0),
                                  trx.print[i]['label']
                                          .toString()
                                          .toLowerCase()
                                          .contains('token')
                                      ? InkWell(
                                          child: Icon(
                                            Icons.content_copy,
                                            size: 18,
                                            color: Colors.grey,
                                          ),
                                          onTap: () async {
                                            await Clipboard.setData(
                                                ClipboardData(
                                                    text: trx.print[i]
                                                        ['value']));
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Berhasil menyalin token'),
                                              ),
                                            );
                                          },
                                        )
                                      : SizedBox(),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      trx.print.length == 0 ? SizedBox() : SizedBox(height: 10),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('ID Transaksi',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                            SizedBox(height: 5),
                            Text(trx.id.toUpperCase(),
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ]),
                      SizedBox(height: 10),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Waktu Transaksi',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                            SizedBox(height: 5),
                            Text(
                              "${formatDate(trx.created_at, "d MMMM yyyy HH:mm:ss")} WIB",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ]),
                      SizedBox(height: 10),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Waktu Status',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                            SizedBox(height: 5),
                            Text(
                              "${formatDate(trx.created_at, "d MMMM yyyy HH:mm:ss")} WIB",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          ])
                    ]),
              ),
              packageName == 'id.paymobileku.app'
                  ? SizedBox()
                  : TextButton(
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Hero(
                              tag: 'cs',
                              child: Icon(
                                Icons.help_outline,
                                color: packageName == 'com.lariz.mobile'
                                    ? Theme.of(context).secondaryHeaderColor
                                    : Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(width: 5),
                            Text('Komplain')
                          ]),
                      onPressed: () {
                        List<String> packageList = [
                          'mypay.co.id',
                          'id.payku.app',
                          'popay.id',
                          'mobile.payuni.id',
                          'co.pakaiaja.id',
                          'com.mocipay.app',
                          'com.centralbayar.apk',
                          'ayoba.co.id',
                          'com.talentapay.android',
                          'id.outletpay.mobile',
                          'com.popayfdn',
                          'com.xenaja.app',
                          'com.ampedia.mobile',
                          'id.paymobileku.app'
                        ];

                        var isPackage = false;

                        packageList.forEach((element) {
                          if (element == packageName) {
                            isPackage = true;
                          }
                        });

                        if (isPackage) return sendWhatsApp();

                        return Navigator.of(context)
                            .pushNamed('/customer-service');
                      },
                    )
            ],
          ),
        ),
      ),
      floatingActionButton: trx.status != 2
          ? null
          : FloatingActionButton(
              child: Icon(Icons.print),
              backgroundColor: packageName == 'com.lariz.mobile'
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).primaryColor,
              onPressed: () {
                print("Sudah Sampai Sini $trx");
                if (widget.data.produk != null &&
                    widget.data.produk != null &&
                    widget.data.produk.containsKey('type')) {
                  
                  // Check if custom_print is true
                  if (customPrint) {
                    print("Redirecting to printPreviewSby for custom print transaction");
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PrintPreviewSby(trx: trx),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PrintPreview(
                            trx: trx,
                            isPostpaid: widget.data.produk['type'] == 1),
                      ),
                    );
                  }
                } else {
                  showCustomDialog(
                      context: context,
                      type: DialogType.error,
                      title: 'Produk Tidak Ditemukan',
                      content:
                          'Maaf, Produk tidak ditemukan atau telah dihapus');
                }
              }),
    );
  }

  Widget viewPaymentTrf() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.1),
                offset: Offset(5, 10.0),
                blurRadius: 20)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Center(
              child: Text(
                formatRupiah(trx.harga_jual),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: packageName == 'com.lariz.mobile'
                      ? Theme.of(context).secondaryHeaderColor
                      : Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
          ),
          Center(
              child: Text('Wajib Transfer Sesuai Nominal !',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.red))),
          Divider(),
          ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: banks.length,
              separatorBuilder: (_, i) => SizedBox(height: 5),
              itemBuilder: (context, i) {
                BankModel bank = banks.elementAt(i);

                return InkWell(
                  onTap: () {
                    if (bank.isGangguan) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Untuk saat ini, rekening tersebut sedang mengalami gangguan')));
                    } else {
                      Clipboard.setData(ClipboardData(text: bank.noRek));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Nomor rekening berhasil disalin ke papan klip')));
                    }
                  },
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(bank.namaBank,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18.0)),
                    subtitle: Text('a.n. ${bank.namaRekening}',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          bank.noRek,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18.0),
                        ),
                        Text(bank.isGangguan ? 'GANGGUAN' : 'TERSEDIA',
                            style: TextStyle(
                                color:
                                    bank.isGangguan ? Colors.red : Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }

  Widget viewPaymentQris() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.1),
                offset: Offset(5, 10.0),
                blurRadius: 20)
          ]),
      child: Screenshot(
        controller: _screenshotController,
        child: ListView(
          padding: EdgeInsets.all(20),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(formatRupiah(trx.harga_jual),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: packageName == 'com.lariz.mobile'
                        ? Theme.of(context).secondaryHeaderColor
                        : Theme.of(context).primaryColor,
                  )),
            ),
            SizedBox(height: 15),
            Align(
                alignment: Alignment.center,
                child: Text(
                    'Silahkan Lakukan Pembayaran Dengan Scan QRCode ini dengan Aplikasi yang mendukung Scan QRIS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ))),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: QrImageView(
                backgroundColor: Theme.of(context).canvasColor,
                foregroundColor: Colors.black,
                gapless: true,
                size: MediaQuery.of(context).size.width * .75,
                version: QrVersions.auto,
                data: trx.paymentDetail.paymentImg,
              ),
            ),
            SizedBox(height: 10),
            trx.status == 4
                ? Align(
                    alignment: Alignment.center,
                    child: Text(
                        'Bayar Sebelum ${formatDate(trx.paymentDetail.paymentExpired, "d MMMM yyyy HH:mm:ss")}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        )))
                : SizedBox(height: 0.0),
            SizedBox(height: 10),
            trx.status == 4
                ? danaApp
                    ? InkWell(
                        onTap: () async {
                          image = File.fromRawPath(
                              await _screenshotController.capture(
                                  pixelRatio: 2.5,
                                  delay: Duration(milliseconds: 100)));
                          if (image == null) return;
                          await Share.shareFiles([image.path],
                              text: 'Bayar Pakai Dana', packageApp: 'id.dana');
                        },
                        // child: Container(
                        //   margin: EdgeInsets.only(right: 20, left: 20),
                        //   padding: EdgeInsets.symmetric(
                        //       vertical: 20, horizontal: 20.0),
                        //   decoration: BoxDecoration(
                        //       color: Colors.blue,
                        //       borderRadius: BorderRadius.circular(10.0)),
                        //   child: Center(
                        //     child: Text('BAYAR PAKAI APLIKASI DANA',
                        //         style: TextStyle(
                        //             color: Colors.white,
                        //             fontWeight: FontWeight.bold)),
                        //   ),
                        // ),
                      )
                    : Container()
                : Container(),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

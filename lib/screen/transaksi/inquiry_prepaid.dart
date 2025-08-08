// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/Products/talentapay/layout/history.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/bloc/TemplateConfig.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/payment-list.dart';
import 'package:mobile/models/trx.dart';
import 'package:mobile/models/virtual_account.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/provider/api.dart';
import 'package:mobile/screen/history/history.dart';
import 'package:mobile/screen/profile/kyc/not_verified_user.dart';
import 'package:mobile/screen/transaksi/detail_transaksi.dart';
import 'package:mobile/screen/transaksi/trx_wait.dart';
import 'package:mobile/screen/transaksi/verifikasi_pin.dart';
import 'package:mobile/Products/seepays/layout/verifikasi_pin.dart' as seepays;
import '../../bloc/Bloc.dart' show bloc;
import 'dart:convert';

class InquiryPrepaid extends StatefulWidget {
  final String nomorTujuan;
  final String kodeProduk;
  final int nominal;

  InquiryPrepaid(this.kodeProduk, this.nomorTujuan, {this.nominal});

  @override                   
  _InquiryPrepaidState createState() => _InquiryPrepaidState();
}

class _InquiryPrepaidState extends InquiryPrepaidController {
  @override
  void initState() {
    super.initState();
    analitycs.pageView(
        '/menu/transaksi/' +
            widget.kodeProduk +
            '?tujuan=' +
            widget.nomorTujuan,
        {
          'userId': bloc.userId.valueWrapper?.value,
          'title': 'Inquiry Transaksi ' + widget.kodeProduk
        });
    checkNumberFavorite(widget.nomorTujuan);
    getData(widget.kodeProduk, widget.nomorTujuan);
    fetchMethodePembayaran();
  }

  @override
  Widget build(BuildContext context) {
    return afterTrx
        ? TransactionWaitPage()
        : Scaffold(
            body: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  iconTheme: IconThemeData(color: Colors.white),
                  expandedHeight:
                      configAppBloc.enableMultiChannel.valueWrapper?.value
                          ? null
                          : 200.0,
                  backgroundColor: packageName == 'com.lariz.mobile'
                      ? Theme.of(context).secondaryHeaderColor
                      : Theme.of(context).primaryColor,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text('Konfirmasi Pembelian'),
                    centerTitle: true,
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.home_rounded),
                      onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) =>
                                configAppBloc
                                    .layoutApp?.valueWrapper?.value['home'] ??
                                templateConfig[configAppBloc
                                    .templateCode.valueWrapper?.value],
                          ),
                          (route) => false),
                    ),
                  ],
                ),
                loading
                    ? loadingWidget()
                    : SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Container(
                              padding: EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(.1),
                                              offset: Offset(5, 10),
                                              blurRadius: 20)
                                        ]),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text('Detail Pembelian',
                                                    style: TextStyle(
                                                        color: packageName ==
                                                                'com.lariz.mobile'
                                                            ? Theme.of(context)
                                                                .secondaryHeaderColor
                                                            : Theme.of(context)
                                                                .primaryColor,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Icon(
                                                  Icons.receipt,
                                                  color: packageName ==
                                                          'com.lariz.mobile'
                                                      ? Theme.of(context)
                                                          .secondaryHeaderColor
                                                      : Theme.of(context)
                                                          .primaryColor,
                                                )
                                              ]),
                                          Divider(),
                                          SizedBox(height: 10),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text('Nama Produk',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10)),
                                                SizedBox(width: 5),
                                                Flexible(
                                                  flex: 1,
                                                  child: Text(data['nama'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      textAlign:
                                                          TextAlign.right),
                                                ),
                                              ]),
                                          SizedBox(height: 10),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text('Description',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10)),
                                                SizedBox(width: 5),
                                                Flexible(
                                                  flex: 1,
                                                  child: Text(
                                                      data['description'] ?? '',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      textAlign:
                                                          TextAlign.right),
                                                ),
                                              ]),
                                          SizedBox(height: 10),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text('Nomor Tujuan',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10)),
                                                Text(data['tujuan'],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)), 
                                              ]),
                                          SizedBox(height: 10),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text('Pengisian Ke',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10)),
                                                Text(data['counter'].toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ]),
                                          SizedBox(height: 10),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text('Poin',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10)),
                                                Text(data['point'].toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ]),
                                          data['params'] == null
                                              ? SizedBox()
                                              : data['params'].length > 0
                                                  ? ListView.separated(
                                                      shrinkWrap: true,
                                                      padding: EdgeInsets.only(
                                                          top: 10),
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      itemCount:
                                                          data['params'].length,
                                                      separatorBuilder: (_,
                                                              i) =>
                                                          SizedBox(height: 10),
                                                      itemBuilder: (ctx, i) {
                                                        Map<String, dynamic>
                                                            item =
                                                            data['params'][i];
                                                        return Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: <Widget>[
                                                              Text(
                                                                  item['label'],
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          10)),
                                                              Flexible(
                                                                flex: 1,
                                                                child: Text(
                                                                    item[
                                                                        'value'],
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                              ),
                                                            ]);
                                                      })
                                                  : SizedBox()
                                        ]),
                                  ),
                                  SizedBox(height: 15),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(.1),
                                              offset: Offset(5, 10),
                                              blurRadius: 20)
                                        ]),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text('Detail Harga',
                                                    style: TextStyle(
                                                        color: packageName ==
                                                                'com.lariz.mobile'
                                                            ? Theme.of(context)
                                                                .secondaryHeaderColor
                                                            : Theme.of(context)
                                                                .primaryColor,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Icon(
                                                  Icons.receipt,
                                                  color: packageName ==
                                                          'com.lariz.mobile'
                                                      ? Theme.of(context)
                                                          .secondaryHeaderColor
                                                      : Theme.of(context)
                                                          .primaryColor,
                                                )
                                              ]),
                                          Divider(),
                                          SizedBox(height: 10),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text('Harga Awal',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10)),
                                                Text(
                                                    formatRupiah(
                                                        data['harga_jual']),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ]),
                                          SizedBox(height: 10),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text('Diskon',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10)),
                                                Text(
                                                    formatRupiah(
                                                        data['discount']),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ]),
                                          SizedBox(height: 10),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text('Cashback',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10)),
                                                Text(
                                                    formatRupiah(
                                                        data['cashback']),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ]),
                                          SizedBox(height: 10),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text('Admin',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10)),
                                                Text(
                                                    formatRupiah(_opsiBayar == 0
                                                        ? 0
                                                        : _opsiBayar == 1
                                                            ? data['unik']
                                                            : _opsiBayar == 2
                                                                ? (_jumlahBayar +
                                                                        data[
                                                                            'discount'] -
                                                                        data[
                                                                            'harga_jual'])
                                                                    .toInt()
                                                                : 0),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ]),
                                          SizedBox(height: 10),
                                          Divider(),
                                          SizedBox(height: 10),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text('Total Bayar',
                                                    style: TextStyle(
                                                        color: packageName ==
                                                                'com.lariz.mobile'
                                                            ? Theme.of(context)
                                                                .secondaryHeaderColor
                                                            : Theme.of(context)
                                                                .primaryColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20)),
                                                Text(
                                                    _opsiBayar == 0
                                                        ? formatRupiah(data[
                                                                'harga_jual'] -
                                                            data['discount'])
                                                        : formatRupiah(
                                                            _jumlahBayar),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                      color: packageName ==
                                                              'com.lariz.mobile'
                                                          ? Theme.of(context)
                                                              .secondaryHeaderColor
                                                          : Theme.of(context)
                                                              .primaryColor,
                                                    )),
                                              ]),
                                        ]),
                                  ),
                                  SizedBox(
                                      height: configAppBloc.enableMultiChannel
                                              .valueWrapper?.value
                                          ? 15.0
                                          : 0.0),
                                  configAppBloc.enableMultiChannel.valueWrapper
                                          ?.value
                                      ? Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(.1),
                                                    offset: Offset(5, 10),
                                                    blurRadius: 20),
                                              ]),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text('Metode Pembayaran',
                                                      style: TextStyle(
                                                          color: packageName == 'com.lariz.mobile'
                                                              ? Theme.of(
                                                                      context)
                                                                  .secondaryHeaderColor
                                                              : Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Icon(
                                                    Icons.receipt,
                                                    color: packageName ==
                                                            'com.lariz.mobile'
                                                        ? Theme.of(context)
                                                            .secondaryHeaderColor
                                                        : Theme.of(context)
                                                            .primaryColor,
                                                  )
                                                ],
                                              ),
                                              Divider(),
                                              SizedBox(height: 10),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          _opsiBayar = 0;
                                                        });
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                color: _opsiBayar ==
                                                                        0
                                                                    ? packageName ==
                                                                            'com.lariz.mobile'
                                                                        ? Theme.of(context)
                                                                            .secondaryHeaderColor
                                                                        : Theme.of(context)
                                                                            .primaryColor
                                                                    : Colors
                                                                        .white,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              .1),
                                                                      blurRadius:
                                                                          10.0,
                                                                      offset:
                                                                          Offset(
                                                                              0,
                                                                              5))
                                                                ],
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10.0))),
                                                        child: ListTile(
                                                            leading:
                                                                CircleAvatar(
                                                              foregroundColor: _opsiBayar ==
                                                                      0
                                                                  ? packageName ==
                                                                          'com.lariz.mobile'
                                                                      ? Theme.of(
                                                                              context)
                                                                          .secondaryHeaderColor
                                                                      : Theme.of(
                                                                              context)
                                                                          .primaryColor
                                                                  : Colors
                                                                      .white,
                                                              backgroundColor: _opsiBayar ==
                                                                      0
                                                                  ? Colors.white
                                                                  : packageName ==
                                                                          'com.lariz.mobile'
                                                                      ? Theme.of(
                                                                              context)
                                                                          .secondaryHeaderColor
                                                                      : Theme.of(
                                                                              context)
                                                                          .primaryColor,
                                                              child: Icon(Icons
                                                                  .wallet_giftcard),
                                                            ),
                                                            title: Text(
                                                                'Saldo $namaApp',
                                                                style: TextStyle(
                                                                    color: _opsiBayar ==
                                                                            0
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black)),
                                                            subtitle: Text(
                                                                formatRupiah(bloc
                                                                    .user
                                                                    .valueWrapper
                                                                    .value
                                                                    .saldo),
                                                                style: TextStyle(
                                                                    color: _opsiBayar ==
                                                                            0
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black))),
                                                      ),
                                                    ),
                                                    SizedBox(height: 10.0),
                                                    configAppBloc
                                                                .packagename
                                                                .valueWrapper
                                                                ?.value !=
                                                            'com.xenaja.app'
                                                        ? InkWell(
                                                            onTap: () {
                                                              checkMinDep(1);
                                                            },
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  color: _opsiBayar == 1
                                                                      ? packageName == 'com.lariz.mobile'
                                                                          ? Theme.of(context).secondaryHeaderColor
                                                                          : Theme.of(context).primaryColor
                                                                      : Colors.white,
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                        color: Colors
                                                                            .black
                                                                            .withOpacity(
                                                                                .1),
                                                                        blurRadius:
                                                                            10.0,
                                                                        offset: Offset(
                                                                            0,
                                                                            5))
                                                                  ],
                                                                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
                                                              child: ListTile(
                                                                leading:
                                                                    CircleAvatar(
                                                                  foregroundColor: _opsiBayar ==
                                                                          1
                                                                      ? packageName ==
                                                                              'com.lariz.mobile'
                                                                          ? Theme.of(context)
                                                                              .secondaryHeaderColor
                                                                          : Theme.of(context)
                                                                              .primaryColor
                                                                      : Colors
                                                                          .white,
                                                                  backgroundColor: _opsiBayar ==
                                                                          1
                                                                      ? Colors
                                                                          .white
                                                                      : packageName ==
                                                                              'com.lariz.mobile'
                                                                          ? Theme.of(context)
                                                                              .secondaryHeaderColor
                                                                          : Theme.of(context)
                                                                              .primaryColor,
                                                                  child: Icon(Icons
                                                                      .credit_card),
                                                                ),
                                                                trailing:
                                                                    _opsiBayar ==
                                                                            1
                                                                        ? Text(
                                                                            formatRupiah(data['harga_unik']),
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          )
                                                                        : Text(
                                                                            ''),
                                                                title: Text(
                                                                    'Transfer Bank',
                                                                    style: TextStyle(
                                                                        color: _opsiBayar ==
                                                                                1
                                                                            ? Colors.white
                                                                            : Colors.black)),
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                    SizedBox(
                                                        height: configAppBloc
                                                                    .packagename
                                                                    .valueWrapper
                                                                    .value !=
                                                                'com.xenaja.app'
                                                            ? 10.0
                                                            : 0.0),
                                                    InkWell(
                                                      onTap: () {
                                                        checkMinDep(2);
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                color: _opsiBayar ==
                                                                        2
                                                                    ? packageName ==
                                                                            'com.lariz.mobile'
                                                                        ? Theme.of(context)
                                                                            .secondaryHeaderColor
                                                                        : Theme.of(context)
                                                                            .primaryColor
                                                                    : Colors
                                                                        .white,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              .1),
                                                                      blurRadius:
                                                                          10.0,
                                                                      offset:
                                                                          Offset(
                                                                              0,
                                                                              5))
                                                                ],
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10.0))),
                                                        child: ListTile(
                                                          leading: CircleAvatar(
                                                            foregroundColor: _opsiBayar ==
                                                                    2
                                                                ? packageName ==
                                                                        'com.lariz.mobile'
                                                                    ? Theme.of(
                                                                            context)
                                                                        .secondaryHeaderColor
                                                                    : Theme.of(
                                                                            context)
                                                                        .primaryColor
                                                                : Colors.white,
                                                            backgroundColor: _opsiBayar ==
                                                                    2
                                                                ? Colors.white
                                                                : packageName ==
                                                                        'com.lariz.mobile'
                                                                    ? Theme.of(
                                                                            context)
                                                                        .secondaryHeaderColor
                                                                    : Theme.of(
                                                                            context)
                                                                        .primaryColor,
                                                            child: Icon(
                                                                Icons.qr_code),
                                                          ),
                                                          title: Text(
                                                              'Scan Qris',
                                                              style: TextStyle(
                                                                  color: _opsiBayar ==
                                                                          2
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .black)),
                                                          trailing:
                                                              _opsiBayar == 2
                                                                  ? Text(
                                                                      formatRupiah(
                                                                          _jumlahBayar),
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    )
                                                                  : Text(''),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : SizedBox(height: 0.0),
                                  SizedBox(height: boxFavorite ? 15.0 : 0.0),
                                  boxFavorite
                                      ? Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(.1),
                                                    offset: Offset(5, 10),
                                                    blurRadius: 20),
                                              ]),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Simpan Nomor',
                                                    style: TextStyle(
                                                      color: packageName ==
                                                              'com.lariz.mobile'
                                                          ? Theme.of(context)
                                                              .secondaryHeaderColor
                                                          : Theme.of(context)
                                                              .primaryColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.receipt,
                                                    color: packageName ==
                                                            'com.lariz.mobile'
                                                        ? Theme.of(context)
                                                            .secondaryHeaderColor
                                                        : Theme.of(context)
                                                            .primaryColor,
                                                  )
                                                ],
                                              ),
                                              Divider(),
                                              SizedBox(height: 10),
                                              TextFormField(
                                                controller: tujuanController,
                                                keyboardType:
                                                    TextInputType.text,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  border: OutlineInputBorder(),
                                                  labelText: 'Nomor Tujuan',
                                                  prefixIcon:
                                                      Icon(Icons.contacts),
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              TextFormField(
                                                controller: namaController,
                                                keyboardType:
                                                    TextInputType.text,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  border: OutlineInputBorder(),
                                                  labelText: 'Nama',
                                                  prefixIcon:
                                                      Icon(Icons.person),
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              SizedBox(
                                                width: double.infinity,
                                                height: 40.0,
                                                child: TextButton(
                                                  child: Text(
                                                    'SIMPAN',
                                                    style: TextStyle(
                                                      color: packageName ==
                                                              'com.lariz.mobile'
                                                          ? Theme.of(context)
                                                              .secondaryHeaderColor
                                                          : Theme.of(context)
                                                              .primaryColor,
                                                    ),
                                                  ),
                                                  onPressed: simpanFavorite,
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      : SizedBox(height: 80.0),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
            floatingActionButton: loading
                ? null
                : FloatingActionButton.extended(
                    backgroundColor: packageName == 'com.lariz.mobile'
                        ? Theme.of(context).secondaryHeaderColor
                        : Theme.of(context).primaryColor,
                    label: Text('Bayar'),
                    icon: Icon(Icons.navigate_next),
                    onPressed: () =>
                        _opsiBayar == 0 ? bayar() : purchaseOther(),
                  ),
          );
  }
}

abstract class InquiryPrepaidController extends State<InquiryPrepaid> {
  TextEditingController tujuanController = TextEditingController();
  TextEditingController namaController = TextEditingController();

  bool loading = true;
  bool boxFavorite = false;
  Map<String, dynamic> data;
  List<dynamic> listPayment;
  bool afterTrx = false;

  List<VirtualAccount> vaList = [];
  int minDep = 10000;
  double adminQris = 0;
  int _opsiBayar = 0; // 0 -> SALDO, 1 -> TRANSFER BANK, 2 -> QRIS
  int _jumlahBayar = 0;

  fetchMethodePembayaran() async {
    try {
      List<dynamic> datas = await api.get('/deposit/methode', cache: true);
      listPayment = datas.map((e) => PaymentModel.fromJson(e)).toList();
      listPayment.forEach((element) {
        print(element);
        if (element.type == 8) {
          setState(() {
            adminQris = element.admin_trx != null
                ? element.admin_trx['nominal']
                : element.admin['nominal'];
          });
        }
      });
    } catch (e) {
      listPayment = [];
    } finally {}
  }

  checkMinDep(int value) async {
    int jumlah = 0;
    if (value == 1) {
      jumlah = data['harga_unik'];
    } else if (value == 2) {
      jumlah = (data['harga_unik'] +
              ((data['harga_unik'] - data['discount']) * (adminQris / 100)))
          .toInt();
      jumlah -= data['discount'];
    }

    if (jumlah >= data['min_dep']) {
      setState(() {
        _opsiBayar = value;
        _jumlahBayar = jumlah;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        Alert(
          'Minimal Pembayaran harus ${formatRupiah(minDep)}',
          isError: true,
        ),
      );
      setState(() {
        _opsiBayar = 0;
      });
    }
  }

  getVA() async {
    http.Response response = await http.get(
      Uri.parse('$apiUrl/deposit/virtual-account/list'),
      headers: {
        'Authorization': bloc.token.valueWrapper?.value,
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      datas.map((el) => vaList.add(VirtualAccount.fromJson(el))).toList();
    }

    setState(() {
      loading = false;
    });
  }

  getData(String kodeProduk, String tujuan) async {
    Map<String, dynamic> dataToSend;
    if (widget.nominal != null) {
      dataToSend = {
        'kode_produk': kodeProduk,
        'tujuan': tujuan,
        'nominal': widget.nominal
      };
    } else {
      dataToSend = {'kode_produk': kodeProduk, 'tujuan': tujuan};
    }
    http.Response response =
        await http.post(Uri.parse('$apiUrl/trx/prepaid/inquiry'),
            headers: {
              'Authorization': bloc.token.valueWrapper?.value,
              'Content-Type': 'application/json'
            },
            body: json.encode(dataToSend));

    if (response.statusCode == 200) {
      setState(() {
        loading = false;
        data = jsonDecode(response.body)['data'];
      });
      print(data);
    } else if (response.statusCode == 403 &&
        json.decode(response.body)['need_verification']) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) =>
              configAppBloc
                  .layoutApp.valueWrapper?.value['not_verified_user'] ??
              NotVerifiedPage()));
      setState(() {
        loading = false;
      });
    } else {
      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan pada server';
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(content: Text(message), actions: [
                TextButton(
                    child: Text(
                      'TUTUP',
                      style: TextStyle(
                        color: packageName == 'com.lariz.mobile'
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: Navigator.of(ctx).pop)
              ]));
      Navigator.of(context).pop();
      setState(() {
        loading = false;
      });
    }
  }

  checkNumberFavorite(String tujuan) async {
    setState(() {
      tujuanController.text = tujuan;
    });

    Map<String, dynamic> dataToSend = {'tujuan': tujuan, 'type': 'prepaid'};

    http.Response response =
        await http.post(Uri.parse('$apiUrl/favorite/checkNumber'),
            headers: {
              'Authorization': bloc.token.valueWrapper?.value,
              'Content-Type': 'application/json',
            },
            body: json.encode(dataToSend));

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      setState(() {
        boxFavorite = !responseData['data'];
      });
    } else {
      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan pada server';
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
                child: Text(
                  'TUTUP',
                  style: TextStyle(
                    color: packageName == 'com.lariz.mobile'
                        ? Theme.of(context).secondaryHeaderColor
                        : Theme.of(context).primaryColor,
                  ),
                ),
                onPressed: () => Navigator.of(ctx).pop()),
          ],
        ),
      );

      setState(() {
        boxFavorite = true;
      });
    }
  }

  simpanFavorite() async {
    if (tujuanController.text == '' || namaController.text == '') {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                  content: Text("Nomor Tujuan dan Nama Tidak Boleh Kosong !"),
                  actions: [
                    TextButton(
                        child: Text(
                          'TUTUP',
                          style: TextStyle(
                            color: packageName == 'com.lariz.mobile'
                                ? Theme.of(context).secondaryHeaderColor
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                        onPressed: Navigator.of(ctx).pop)
                  ]));
    } else {
      setState(() {
        loading = true;
      });

      var dataToSend = {
        'tujuan': tujuanController.text,
        'nama': namaController.text,
        'type': 'prepaid',
      };

      http.Response response =
          await http.post(Uri.parse('$apiUrl/favorite/saveNumber'),
              headers: {
                'Authorization': bloc.token.valueWrapper?.value,
                'Content-Type': 'application/json',
              },
              body: json.encode(dataToSend));

      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan pada server';
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
                child: Text(
                  'TUTUP',
                  style: TextStyle(
                    color: packageName == 'com.lariz.mobile'
                        ? Theme.of(context).secondaryHeaderColor
                        : Theme.of(context).primaryColor,
                  ),
                ),
                onPressed: () => Navigator.of(ctx).pop()),
          ],
        ),
      );

      setState(() {
        loading = false;
      });
    }
  }

  // BAYAR OPSI LAIN
  purchaseOther() async {
    setState(() {
      loading = true;
    });

    try {
      sendDeviceToken();
      String pin = await Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => packageName == 'com.seepaysbiller.app' ? seepays.VerifikasiPin() : VerifikasiPin()));
      if (pin != null) {
        var dataToSend = {
          'kode_produk': data['kode_produk'],
          'tujuan': data['tujuan'],
          'counter': data['counter'],
          'opsi_bayar': _opsiBayar,
          'unik': data['unik'],
          'pin': pin
        };

        http.Response response =
            await http.post(Uri.parse('$apiUrl/trx/prepaid/purchaseOrder'),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': bloc.token.valueWrapper?.value
                },
                body: json.encode(dataToSend));

        if (response.statusCode == 200) {
          if (realtimePrepaid) {
            Navigator.of(context).popUntil(ModalRoute.withName('/'));
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TransactionWaitPage(),
              ),
            );
          } else {
            await getLatestTrx();
            Navigator.of(context).popUntil(ModalRoute.withName('/'));
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => HistoryPage(initIndex: 1),
              ),
            );
          }
        } else {
          String message = json.decode(response.body)['message'] ??
              'Terjadi kesalahan pada server';
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
        }
      }
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Terjadi kesalahan pada server. ERR : ${err.toString()}')));
    }
  }

  // BAYAR VIA SALDO
  bayar() async {
    // if (realtimePrepaid) {
    //   setState(() {
    //     loading = false;
    //   });
    // } else {
    //   setState(() {
    //     loading = true;
    //   });
    // }
    setState(() {
      loading = true;
    });

    try {
      sendDeviceToken();
      String pin = await Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => packageName == 'com.seepaysbiller.app' ? seepays.VerifikasiPin() : VerifikasiPin()));
      if (pin != null) {
        if (realtimePrepaid) {
          setState(() {
            afterTrx = true;
          });
        }
        var dataToSend = {
          'kode_produk': data['kode_produk'],
          'tujuan': data['tujuan'],
          'counter': data['counter'],
          'pin': pin
        };

        if (widget.nominal != null) {
          dataToSend['nominal'] = widget.nominal;
        }

        http.Response response =
            await http.post(Uri.parse('$apiUrl/trx/prepaid/purchase'),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': bloc.token.valueWrapper?.value
                },
                body: json.encode(dataToSend));
        if (response.statusCode == 200) {
          if (!realtimePrepaid) {
            TrxModel trx = await getLatestTrx();
            Navigator.of(context).popUntil(ModalRoute.withName('/'));
            packageName == 'com.talentapay.android'
                ? Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => HistoryPageTalenta(initIndex: 1),
                    ),
                  )
                : Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => packageName == 'com.eralink.mobileapk'
                            ? DetailTransaksi(trx)
                            : HistoryPage(initIndex: 1)),
                  );
          }
        } else {
          setState(() {
            afterTrx = false;
          });
          String message = json.decode(response.body)['message'] ??
              'Terjadi kesalahan pada server';
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
        }
      }
      setState(() {
        loading = false;
      });
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Terjadi kesalahan pada server. ERR : ${err.toString()}')));
      setState(() {
        loading = false;
      });
    }
  }

  Future<TrxModel> getLatestTrx() async {
    http.Response response = await http.get(
        Uri.parse('$apiUrl/trx/list?page=0&limit=1'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      return TrxModel.fromJson(datas[0]);
    } else {
      return null;
    }
  }

  Widget loadingWidget() {
    return SliverList(
        delegate: SliverChildListDelegate([
      Container(
        padding: EdgeInsets.all(20),
        child: Center(
          child: SpinKitThreeBounce(
            color: packageName == 'com.lariz.mobile'
                ? Theme.of(context).secondaryHeaderColor
                : Theme.of(context).primaryColor,
            size: 35,
          ),
        ),
      )
    ]));
  }
}

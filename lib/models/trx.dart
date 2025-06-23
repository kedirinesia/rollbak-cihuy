// @dart=2.9

import 'package:flutter/material.dart';

class TrxModel {
  String id;
  int status;
  int admin;
  TrxStatus statusModel;
  int counter;
  String tujuan;
  Map<String, dynamic> produk;
  int harga_jual;
  String sn;
  String paymentBy;
  String paymentID;
  String created_at;
  String updated_at;
  String keterangan;
  int point;
  List<dynamic> print;
  TrxPaymentDetail paymentDetail;

  TrxModel(
      {this.id,
      this.harga_jual,
      this.admin,
      this.status,
      this.created_at,
      this.updated_at,
      this.statusModel,
      this.produk,
      this.sn,
      this.counter,
      this.tujuan,
      this.keterangan,
      this.point,
      this.paymentBy,
      this.paymentID,
      this.paymentDetail,
      
      this.print});

  TrxModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    harga_jual = json['harga_jual'] ?? 0;
    admin = json['admin'] ?? 0;
    status = json['status'] ?? 0;
    point = json['poin'] ?? 0;
    keterangan = json['keterangan'] ?? '-';
    counter = json['counter'] ?? 1;
    created_at = json['created_at'] ?? '';
    updated_at = json['updated_at'] ?? '';
    produk = json['produk_id'];
    statusModel = TrxStatus.parsing(json['status'] ?? 0);
    sn = json['sn'] ?? 'N/A';
    tujuan = json['tujuan'] ?? '-';
    paymentBy = json['payment_by'] ?? '';
    paymentID = json['payment_id'] ?? '';
    paymentDetail = json['payment_detail'] != null
        ? TrxPaymentDetail.fromJson(json['payment_detail'])
        : null;
    print = json['print'] ?? [];
  }
}

class TrxPaymentDetail {
  String paymentCode;
  String paymentImg;
  int paymentType;
  int paymentAdmin;
  // int paymentAmount;
  int paymentNetAmount;
  String paymentExpired;

  TrxPaymentDetail({
    this.paymentCode,
    this.paymentImg,
    this.paymentType,
    this.paymentAdmin,
    // this.paymentAmount,
    this.paymentNetAmount,
    this.paymentExpired,
  });

  factory TrxPaymentDetail.fromJson(Map<String, dynamic> json) {
    return TrxPaymentDetail(
        paymentCode: json['payment_code'] ?? '',
        paymentImg: json['payment_image'] ?? '',
        paymentType: json['payment_type'] ?? 0,
        paymentAdmin: json['payment_admin'] ?? 0,
        // paymentAmount : json['payment_amount'] ?? 0,
        paymentNetAmount: json['payment_net_amount'] ?? 0,
        paymentExpired: json['payment_expired']);
  }
}

class TrxStatus {
  int status;
  Color color;
  String statusText;
  String icon;

  TrxStatus({this.status, this.color, this.statusText});

  TrxStatus.parsing(int st) {
    if (st == 0) {
      statusText = 'Dalam Proses';
      color = Color(0XFF253536);
      status = st;
      icon =
          'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fcoffee-cup.png?alt=media&token=fd0d0a4d-9689-4ab9-8473-72516ccd3c5f';
    } else if (st == 1) {
      statusText = 'Dalam Proses';
      color = Color(0XFF253536);
      status = st;
      icon =
          'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fcoffee-cup.png?alt=media&token=fd0d0a4d-9689-4ab9-8473-72516ccd3c5f';
    } else if (st == 2) {
      statusText = 'Sukses';
      color = Color(0XFF007C21);
      status = st;
      icon =
          'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Ftrophy.png?alt=media&token=271f57f4-bc76-4f19-8f69-b3543376adff';
    } else if (st == 3) {
      statusText = 'Gagal';
      color = Color(0XFFA70C00);
      status = st;
      icon =
          'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Ferror.png?alt=media&token=f5148d8a-a90d-494f-8368-0daf85eb4803';
    } else if (st == 4) {
      statusText = 'Belum Dibayar';
      color = Color(0XFFA70C00);
      status = st;
      icon =
          'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Ferror.png?alt=media&token=f5148d8a-a90d-494f-8368-0daf85eb4803';
    } else if (st == 5) {
      statusText = 'Terbayar';
      color = Color(0XFFA70C00);
      status = st;
      icon =
          'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Ferror.png?alt=media&token=f5148d8a-a90d-494f-8368-0daf85eb4803';
    } else {
      statusText = 'Expired';
      color = Color(0XFFA70C00);
      status = st;
      icon =
          'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Ferror.png?alt=media&token=f5148d8a-a90d-494f-8368-0daf85eb4803';
    }
  }
}

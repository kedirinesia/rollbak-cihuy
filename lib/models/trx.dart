
import 'package:flutter/material.dart';

class TrxModel {
  late String id;
  late int status;
  late int admin;
  late TrxStatus statusModel;
  late int counter;
  late String tujuan;
  late Map<String, dynamic> produk;
  late int harga_jual;
  late String sn;
  late String paymentBy;
  late String paymentID;
  late String created_at;
  late String updated_at;
  late String keterangan;
  late int point;
  late List<dynamic> print;
  TrxPaymentDetail? paymentDetail;

  TrxModel(
      {required this.id,
      required this.harga_jual,
      required this.admin,
      required this.status,
      required this.created_at,
      required this.updated_at,
      required this.statusModel,
      required this.produk,
      required this.sn,
      required this.counter,
      required this.tujuan,
      required this.keterangan,
      required this.point,
      required this.paymentBy,
      required this.paymentID,
      this.paymentDetail,
      required this.print});

  TrxModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'] ?? '';
    harga_jual = json['harga_jual'] ?? 0;
    admin = json['admin'] ?? 0;
    status = json['status'] ?? 0;
    point = json['poin'] ?? 0;
    keterangan = json['keterangan'] ?? '-';
    counter = json['counter'] ?? 1;
    created_at = json['created_at'] ?? '';
    updated_at = json['updated_at'] ?? '';
    produk = json['produk_id'] ?? {};
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
  String? paymentCode;
  String? paymentImg;
  int? paymentType;
  int? paymentAdmin;
  // int paymentAmount;
  int? paymentNetAmount;
  String? paymentExpired;

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
        paymentCode: json['payment_code'],
        paymentImg: json['payment_image'],
        paymentType: json['payment_type'],
        paymentAdmin: json['payment_admin'],
        // paymentAmount : json['payment_amount'] ?? 0,
        paymentNetAmount: json['payment_net_amount'],
        paymentExpired: json['payment_expired']);
  }
}

class TrxStatus {
  late int status;
  late Color color;
  late String statusText;
  String? icon;

  TrxStatus({required this.status, required this.color, required this.statusText});

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

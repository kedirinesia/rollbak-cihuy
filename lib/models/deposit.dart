// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/models/mutasi.dart';

class DepositModel {
  int nominal;
  MutasiModel mutasi;
  String created_at;
  String expired_at;
  String id;
  int status;
  int type;
  int paymentId;
  int admin;
  String kodePembayaran;
  String nama;
  String vaname;
  String keterangan;
  String url_payment;
  DepositStatus statusModel;

  DepositModel(
      {this.id,
      this.nominal,
      this.mutasi,
      this.status,
      this.created_at,
      this.expired_at,
      this.type,
      this.paymentId,
      this.admin,
      this.kodePembayaran,
      this.nama,
      this.vaname,
      this.keterangan,
      this.statusModel});

  DepositModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    nominal = json['nominal'] ?? 0;
    status = json['status'] ?? 3;
    mutasi = json['mutasi_id'] != null
        ? MutasiModel.fromJson(json['mutasi_id'])
        : null;
    created_at = json['created_at'] ?? '';
    expired_at = json['expired_at'] ?? '';
    type = json['type'] ?? 0;
    paymentId = json['payment_id'] ?? 0;
    admin = json['admin'];
    kodePembayaran = json['kode_pembayaran'] ?? '';
    nama = json['nama_customer'] ?? '';
    vaname = json['vaname'] ?? '';
    keterangan = json['keterangan'] ?? '';
    url_payment = json['url_payment'] ?? '';
    statusModel = DepositStatus.parsing(json['status'] ?? 3);
  }
}

class DepositBank {}

class DepositStatus {
  int status;
  Color color;
  String statusText;
  String icon;

  DepositStatus({this.status, this.color, this.statusText});

  DepositStatus.parsing(int st) {
    if (st == 0) {
      statusText = 'Pending';
      color = Color(0XFF253536);
      status = st;
      icon =
          'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fshipment.png?alt=media&token=a0cc3543-b791-442e-90cc-3fbeb8f4be3a';
    } else if (st == 1) {
      statusText = 'Sukses';
      color = Color(0XFF007C21);
      status = st;
      icon =
          'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fthumbs-up.png?alt=media&token=ebd501b5-4c2f-4c26-aa54-85c1fc4bb5f1';
    } else {
      statusText = 'Gagal';
      color = Color(0XFFA70C00);
      status = st;
      icon =
          'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Ffail.png?alt=media&token=8e91a475-10c5-4130-bf6a-e282a6a72db0';
    }
  }
}

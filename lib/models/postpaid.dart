// @dart=2.9

import 'package:mobile/models/trx.dart';

class PostpaidInquiryModel {
  String nama;
  String noPelanggan;
  String produk;
  String trackingId;
  String sn;
  int tagihan;
  int admin;
  int fee;
  int total;
  int saldoAwal;
  int saldoAkhir;
  int saldoTerpotong;
  List<dynamic> params;

  PostpaidInquiryModel(
      {this.nama,
      this.noPelanggan,
      this.produk,
      this.trackingId,
      this.sn,
      this.tagihan,
      this.admin,
      this.fee,
      this.total,
      this.saldoAwal,
      this.saldoAkhir,
      this.saldoTerpotong,
      this.params});

  factory PostpaidInquiryModel.fromJson(dynamic json) {
    return PostpaidInquiryModel(
        nama: json['nama'],
        noPelanggan: json['no_pelanggan'],
        produk: json['product'],
        trackingId: json['tracking_id'],
        sn: json['sn'],
        tagihan: json['tagihan'],
        admin: json['admin'],
        fee: json['fee'],
        total: json['total_tagihan'],
        saldoAwal: json['saldo_awal'],
        saldoAkhir: json['saldo_akhir'],
        saldoTerpotong: json['saldo_terpotong'],
        params: json['params'] != null ? json['params'] : []);
  }
}

class PostpaidPurchaseModel {
  String id;
  String nama;
  String noPelanggan;
  String produk;
  String trackingId;
  String sn;
  int tagihan;
  int admin;
  int fee;
  int total;
  int saldoAwal;
  int saldoAkhir;
  int saldoTerpotong;
  List<dynamic> params;
  TrxStatus status;

  PostpaidPurchaseModel({
    this.id,
    this.nama,
    this.noPelanggan,
    this.produk,
    this.trackingId,
    this.sn,
    this.tagihan,
    this.admin,
    this.fee,
    this.total,
    this.saldoAwal,
    this.saldoAkhir,
    this.saldoTerpotong,
    this.params,
    this.status,
  });

  factory PostpaidPurchaseModel.fromJson(dynamic json) {
    return PostpaidPurchaseModel(
      id: json['id'],
      nama: json['nama'],
      noPelanggan: json['no_pelanggan'],
      produk: json['product'],
      trackingId: json['tracking_id'].toString(),
      sn: json['sn'],
      tagihan: json['tagihan'] ?? 0,
      admin: json['admin'] ?? 0,
      fee: json['fee'] ?? 0,
      total: json['total_tagihan'],
      saldoAwal: json['saldo_awal'],
      saldoAkhir: json['saldo_akhir'] ?? 0,
      saldoTerpotong: json['saldo_terpotong'] != null
          ? json['saldo_terpotong']
          : json['total_tagihan'] ?? 0,
      params: json['params'] ?? [],
      status: TrxStatus.parsing(json['status'] ?? 0),
    );
  }
}

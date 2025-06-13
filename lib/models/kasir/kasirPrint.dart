// @dart=2.9

import 'package:mobile/models/kasir/customer.dart';
import 'package:mobile/models/kasir/supplier.dart';

class KasirPrintModel {
  String id;
  String noFaktur;
  String jenis;
  bool lunas;
  String termin;
  int totalQty;
  int totalBeli;
  int totalJual;
  int terbayar;
  String created_at;
  String updated_at;
  List<dynamic> detailTrx;
  CustomerModel customerModel;
  SupplierModel supplierModel;
  Map userID;

  KasirPrintModel({
    this.id,
    this.noFaktur,
    this.jenis,
    this.lunas,
    this.termin,
    this.totalQty,
    this.totalBeli,
    this.totalJual,
    this.terbayar,
    this.created_at,
    this.updated_at,
    this.detailTrx,
    this.customerModel,
    this.supplierModel,
    this.userID,
  });

  factory KasirPrintModel.fromJson(Map<String, dynamic> json) {
    return KasirPrintModel(
      id: json['_id'],
      noFaktur: json['no_faktur'],
      jenis: json['jenis'],
      lunas: json['lunas'],
      termin: json['termin'],
      totalQty: json['total_qty'],
      totalBeli: json['total_beli'],
      totalJual: json['total_jual'],
      terbayar: json['terbayar'],
      detailTrx: json['detail_trx'],
      customerModel: json['id_customer'] != null
          ? CustomerModel.fromJson(json['id_customer'])
          : null,
      supplierModel: json['id_supplier'] != null
          ? SupplierModel.fromJson(json['id_supplier'])
          : null,
      userID: json['user_id'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
    );
  }
}

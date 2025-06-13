// @dart=2.9

import 'package:mobile/models/kasir/supplier.dart';
import 'package:mobile/models/kasir/customer.dart';

class DetailTrxModel {
  String id;
  String namaBarang;
  int qty;
  int hargaBeli;
  int hargaJual;
  String id_gudang;
  String created_at;
  SupplierModel supplierModel;
  CustomerModel customerModel;

  DetailTrxModel({
    this.id,
    this.namaBarang,
    this.qty,
    this.hargaBeli,
    this.hargaJual,
    this.id_gudang,
    this.created_at,
    this.customerModel,
    this.supplierModel,
  });

  factory DetailTrxModel.fromJson(Map<String, dynamic> json) {
    return DetailTrxModel(
      id: json['_id'],
      namaBarang: json['nama_barang'],
      qty: json['qty'],
      hargaBeli: json['harga_beli'],
      hargaJual: json['harga_jual'],
      id_gudang: json['id_gudang'],
      customerModel: json['id_customer'] != null
          ? CustomerModel.fromJson(json['id_customer'])
          : null,
      supplierModel: json['id_supplier'] != null
          ? SupplierModel.fromJson(json['id_supplier'])
          : null,
      created_at: json['created_at'],
    );
  }
}

// @dart=2.9

import 'package:mobile/models/kasir/supplier.dart';

// MODEL ASSET PERSEIDAAN
class PersediaanModel {
  String id;
  int hargaBeli;
  int qty;
  int stock;
  String id_kategori;
  String id_satuan;
  ProdukModel barangModel;
  SupplierModel supplierModel;
  String created_at;

  PersediaanModel(
      {this.id,
      this.hargaBeli,
      this.qty,
      this.stock,
      this.id_kategori,
      this.id_satuan,
      this.barangModel,
      this.supplierModel,
      this.created_at});

  factory PersediaanModel.fromJson(Map<String, dynamic> json) {
    return PersediaanModel(
      id: json['_id'],
      qty: json['qty'],
      stock: json['stock'],
      hargaBeli: json['harga_beli'],
      barangModel: json['id_barang'] != null
          ? ProdukModel.fromJson(json['id_barang'])
          : null,
      id_kategori: json['id_kategori'],
      id_satuan: json['id_satuan'],
      supplierModel: json['id_supplier'] != null
          ? SupplierModel.fromJson(json['id_supplier'])
          : null,
      created_at: json['created_at'],
    );
  }
}

// MODEL LAPORAN ASSET PERSEIDAAN
class LapPersediaanModel {
  int stock;
  int hargaJual;
  int total;
  String id_barang;
  ProdukModel barangModel;

  LapPersediaanModel(
      {this.stock,
      this.hargaJual,
      this.total,
      this.id_barang,
      this.barangModel});

  factory LapPersediaanModel.fromJson(Map<String, dynamic> json) {
    return LapPersediaanModel(
      stock: json['stock'],
      hargaJual: json['harga_jual'],
      total: json['total'],
      id_barang: json['id_barang'],
      barangModel: json['masterBarang'] != null
          ? ProdukModel.fromJson(json['masterBarang'])
          : null,
    );
  }
}

// LAPORAN ARUS STOCK PERSEIDAAN & DETAIL STOCK PER BARANG
class LapStockModel {
  String id_barang;
  int debet;
  int kredit;
  String keterangan;
  String created_at;
  ProdukModel barangModel;

  LapStockModel({
    this.id_barang,
    this.debet,
    this.kredit,
    this.keterangan,
    this.created_at,
    this.barangModel,
  });

  factory LapStockModel.fromJson(Map<String, dynamic> json) {
    return LapStockModel(
      id_barang: json['_id'],
      debet: json['debet'],
      kredit: json['kredit'],
      keterangan: json['keterangan'] != null ? json['keterangan'] : '-',
      created_at: json['created_at'] != null ? json['created_at'] : '-',
      barangModel: json['masterBarang'] != null
          ? ProdukModel.fromJson(json['masterBarang'])
          : null,
    );
  }
}

// MODEL BARANG UNTUK PERSEIDAAN
class ProdukModel {
  String id;
  String sku;
  String namaBarang;
  String imgUrl;
  int hargaJual;
  String id_kategori;
  String id_satuan;
  bool aktif;
  String created_at;

  ProdukModel({
    this.id,
    this.sku,
    this.namaBarang,
    this.imgUrl,
    this.hargaJual,
    this.id_kategori,
    this.id_satuan,
    this.aktif,
    this.created_at,
  });

  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    return ProdukModel(
      id: json['_id'],
      sku: json['sku'],
      imgUrl: json['imgUrl'],
      namaBarang: json['nama_barang'],
      hargaJual: json['harga_jual'],
      id_kategori: json['id_kategori'],
      id_satuan: json['id_satuan'],
      aktif: json['aktif'] ?? false,
      created_at: json['created_at'],
    );
  }
}

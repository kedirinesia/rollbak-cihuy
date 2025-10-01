
import 'package:mobile/models/kasir/supplier.dart';

// MODEL ASSET PERSEIDAAN
class PersediaanModel {
  final String? id;
  final int? hargaBeli;
  final int? qty;
  final int? stock;
  final String? id_kategori;
  final String? id_satuan;
  final ProdukModel? barangModel;
  final SupplierModel? supplierModel;
  final String? created_at;

  const PersediaanModel({
    this.id = '',
    this.hargaBeli = 0,
    this.qty = 0,
    this.stock = 0,
    this.id_kategori = '',
    this.id_satuan = '',
    this.barangModel = null,
    this.supplierModel = null,
    this.created_at = '',
  });

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
  final int? stock;
  final int? hargaJual;
  final int? total;
  final String? id_barang;
  final ProdukModel? barangModel;

  const LapPersediaanModel({
    this.stock = 0,
    this.hargaJual = 0,
    this.total = 0,
    this.id_barang = '',
    this.barangModel = null,
  });

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
  final String? id_barang;
  final int? debet;
  final int? kredit;
  final String? keterangan;
  final String? created_at;
  final ProdukModel? barangModel;

  const LapStockModel({
    this.id_barang = '',
    this.debet = 0,
    this.kredit = 0,
    this.keterangan = '',
    this.created_at = '',
    this.barangModel = null,
  });

  factory LapStockModel.fromJson(Map<String, dynamic> json) {
    return LapStockModel(
      id_barang: json['_id'],
      debet: json['debet'],
      kredit: json['kredit'],
      keterangan: json['keterangan'] ?? '-',
      created_at: json['created_at'] ?? '-',
      barangModel: json['masterBarang'] != null
          ? ProdukModel.fromJson(json['masterBarang'])
          : null,
    );
  }
}

// MODEL BARANG UNTUK PERSEIDAAN
class ProdukModel {
  final String? id;
  final String? sku;
  final String? namaBarang;
  final String? imgUrl;
  final int? hargaJual;
  final String? id_kategori;
  final String? id_satuan;
  final bool? aktif;
  final String? created_at;

  const ProdukModel({
    this.id = '',
    this.sku = '',
    this.namaBarang = '',
    this.imgUrl = '',
    this.hargaJual = 0,
    this.id_kategori = '',
    this.id_satuan = '',
    this.aktif = false,
    this.created_at = '',
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

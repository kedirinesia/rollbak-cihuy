
import 'package:mobile/models/kasir/category.dart';
import 'package:mobile/models/kasir/satuan.dart';

class BarangModel {
  String id;
  String sku;
  String namaBarang;
  String imgUrl;
  int hargaJual;
  CategoryModel? categoryModel;
  SatuanModel? satuanModel;
  bool aktif;
  String created_at;

  BarangModel({
    required this.id,
    required this.sku,
    required this.namaBarang,
    required this.imgUrl,
    required this.hargaJual,
    this.categoryModel,
    this.satuanModel,
    required this.aktif,
    required this.created_at,
  });

  factory BarangModel.fromJson(Map<String, dynamic> json) {
    return BarangModel(
      id: json['_id'],
      sku: json['sku'],
      imgUrl: json['imgUrl'],
      namaBarang: json['nama_barang'],
      hargaJual: json['harga_jual'],
      categoryModel: json['id_kategori'] != null
          ? CategoryModel.fromJson(json['id_kategori'])
          : null,
      satuanModel: json['id_satuan'] != null
          ? SatuanModel.fromJson(json['id_satuan'])
          : null,
      aktif: json['aktif'] ?? false,
      created_at: json['created_at'],
    );
  }
}


import 'package:mobile/utils/debug_helper.dart';

class PrepaidDenomModel {
  final String nama;
  final String description;
  final String note;
  final int harga_jual;
  final int harga_promo;
  final String kode_produk;
  final bool bebas_nominal;
  final String id;

  PrepaidDenomModel({
    required this.nama,
    required this.description,
    required this.note,
    required this.id,
    required this.harga_jual,
    required this.harga_promo,
    required this.kode_produk,
    required this.bebas_nominal,
  });

  factory PrepaidDenomModel.fromJson(Map<String, dynamic> json) {
    DebugHelper.debugPrint('PrepaidDenomModel.fromJson - JSON keys: ${json.keys}');
    DebugHelper.debugPrint('PrepaidDenomModel.fromJson - harga_jual value: ${json['harga_jual']}');
    DebugHelper.debugPrint('PrepaidDenomModel.fromJson - harga_promo value: ${json['harga_promo']}');

    return PrepaidDenomModel(
      id: json['_id'] ?? '',
      kode_produk: json['kode_produk'] ?? '',
      nama: json['nama'] ?? '',
      description: json['description'] ?? '',
      note: json['notes'] ?? '',
      harga_jual: json['harga_jual'] ?? json['harga'] ?? 0,
      harga_promo: json['harga_promo'] ?? json['harga_promo'] ?? 0,
      bebas_nominal: json['bebas_nominal'] ?? false,
    );
  }
}

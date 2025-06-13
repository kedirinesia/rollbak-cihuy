// @dart=2.9

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
    this.nama,
    this.description,
    this.note,
    this.id,
    this.harga_jual,
    this.harga_promo,
    this.kode_produk,
    this.bebas_nominal,
  });

  factory PrepaidDenomModel.fromJson(Map<String, dynamic> json) {
    return PrepaidDenomModel(
      id: json['_id'],
      kode_produk: json['kode_produk'] ?? '0',
      nama: json['nama'],
      description: json['description'] ?? '',
      note: json['notes'] ?? '',
      harga_jual: json['harga_jual'] ?? 0,
      harga_promo: json['harga_promo'],
      bebas_nominal: json['bebas_nominal'] ?? false,
    );
  }
}

// @dart=2.9

class PulsaModel {
  String id;
  String kodeProduk;
  String nama;
  String desc;
  String note;
  int hargaJual;
  int hargaPromo;
  dynamic category;

  PulsaModel({
    this.id,
    this.kodeProduk,
    this.nama,
    this.desc,
    this.note,
    this.hargaJual,
    this.hargaPromo,
    this.category,
  });

  factory PulsaModel.fromJson(Map<String, dynamic> json) {
    dynamic category;

    if (json['kategori_id'] is String) {
      category = json['kategori_id'];
    } else {
      category = KategoriPulsaModel.fromJson(json['kategori_id']);
    }

    return PulsaModel(
      id: json['_id'],
      kodeProduk: json['kode_produk'],
      nama: json['nama'],
      desc: json['description'],
      note: json['notes'] ?? '',
      hargaJual: json['harga_jual'],
      hargaPromo: json['harga_promo'],
      category: category,
    );
  }
}

class KategoriPulsaModel {
  final String id;
  final String name;
  final String iconUrl;

  KategoriPulsaModel({
    this.id,
    this.name,
    this.iconUrl,
  });

  factory KategoriPulsaModel.fromJson(dynamic json) => KategoriPulsaModel(
        id: json['_id'],
        name: json['name'],
        iconUrl: json['icon'],
      );
}


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
    required this.id,
    required    this.kodeProduk,
    required this.nama,
    required this.desc,
    required this.note,
    required this.hargaJual,
    required this.hargaPromo,
    required this.category,
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
      hargaJual: json['harga_jual'] ?? 0,
      hargaPromo: json['harga_promo'] ?? 0,
      category: category,
    );
  }
}

class KategoriPulsaModel {
  final String id;
  final String name;
  final String iconUrl;

  KategoriPulsaModel({
    required this.id,
    required this.name,
    required this.iconUrl,
  });

  factory KategoriPulsaModel.fromJson(dynamic json) => KategoriPulsaModel(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
        iconUrl: json['icon'] ?? '',
      );
}

// @dart=2.9

class SatuanModel {
  String id;
  String nama;
  bool aktif;
  String created_at;

  SatuanModel({
    this.id,
    this.nama,
    this.aktif,
    this.created_at,
  });

  factory SatuanModel.fromJson(Map<String, dynamic> json) {
    return SatuanModel(
      id: json['_id'],
      nama: json['nama'],
      aktif: json['aktif'] ?? false,
      created_at: json['created_at'],
    );
  }
}

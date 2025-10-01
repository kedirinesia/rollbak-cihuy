
class SatuanModel {
  String id;
  String nama;
  bool aktif;
  String created_at;

  SatuanModel({
    required this.id,
    required this.nama,
    required this.aktif,
    required this.created_at,
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

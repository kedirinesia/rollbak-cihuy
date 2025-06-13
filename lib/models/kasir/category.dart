// @dart=2.9

class CategoryModel {
  String id;
  String nama;
  bool aktif;
  String created_at;

  CategoryModel({this.id, this.nama, this.aktif, this.created_at});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'],
      nama: json['nama'],
      aktif: json['aktif'] ?? false,
      created_at: json['created_at'],
    );
  }
}

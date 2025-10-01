
class CategoryModel {
  String id;
  String nama;
  bool aktif;
  String created_at;

  CategoryModel({required this.id, required this.nama, required this.aktif, required this.created_at});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'],
      nama: json['nama'],
      aktif: json['aktif'] ?? false,
      created_at: json['created_at'],
    );
  }
}

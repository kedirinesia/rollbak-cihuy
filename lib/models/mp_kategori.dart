// @dart=2.9

class CategoryModel {
  final String id;
  final String judul;
  final String description;
  final String thumbnailUrl;

  CategoryModel({this.id, this.judul, this.description, this.thumbnailUrl});

  factory CategoryModel.fromJson(Map<String, dynamic> data) {
    return CategoryModel(
        id: data['_id'],
        judul: data['judul'],
        description: data['description'],
        thumbnailUrl: data['thumbnail']);
  }
}

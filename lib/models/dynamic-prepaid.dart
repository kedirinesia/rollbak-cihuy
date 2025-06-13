// @dart=2.9


class DynamicPrepaidDenomModel {
  String name;
  String description;
  int price;
  String code;
  String category;

  DynamicPrepaidDenomModel(
      {this.name, this.description, this.price, this.code, this.category});

  DynamicPrepaidDenomModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'] ?? 0;
    code = json['code'] ?? '0';
    description = json['description'] ?? '';
    category = json['category'] ?? '';
  }
}

class DynamicPrepaidLayoutModel {
  String kategori;
  String title;
  List<DynamicPrepaidDenomModel> produk;

  DynamicPrepaidLayoutModel({this.kategori, this.title, this.produk});

  DynamicPrepaidLayoutModel.fromJson(Map<String, dynamic> json) {
    kategori = json['kategori'] ?? '';
    title = json['title'] ?? '';
    produk = (json['produk'] as List)
        .map((p) => DynamicPrepaidDenomModel.fromJson(p))
        .toList();
  }
}

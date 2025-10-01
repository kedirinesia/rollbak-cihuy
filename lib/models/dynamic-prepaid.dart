
class DynamicPrepaidDenomModel {
  String? name;
  String? description;
  int? price;
  String? code;
  String? category;

  DynamicPrepaidDenomModel({
    this.name,
    this.description,
    this.price,
    this.code,
    this.category,
  });

  DynamicPrepaidDenomModel.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String?;
    description = json['description'] as String?;
    price = json['price'] as int?;
    code = json['code'] as String?;
    category = json['category'] as String?;
  }
}

class DynamicPrepaidLayoutModel {
  String? kategori;
  String? title;
  List<DynamicPrepaidDenomModel>? produk;

  DynamicPrepaidLayoutModel({
    this.kategori,
    this.title,
    this.produk,
  });

  DynamicPrepaidLayoutModel.fromJson(Map<String, dynamic> json) {
    kategori = json['kategori'] as String?;
    title = json['title'] as String?;
    final produkList = json['produk'] as List?;
    produk = produkList?.map((p) => DynamicPrepaidDenomModel.fromJson(p as Map<String, dynamic>)).toList();
  }
}

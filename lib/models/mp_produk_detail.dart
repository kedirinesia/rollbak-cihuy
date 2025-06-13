// @dart=2.9

class ProdukDetailMarket {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final String categoryId;
  final int weight;
  final int price;
  final int stock;
  final List<String> images;

  ProdukDetailMarket({
    this.id,
    this.title,
    this.description,
    this.thumbnail,
    this.categoryId,
    this.weight,
    this.price,
    this.stock,
    this.images,
  });

  factory ProdukDetailMarket.fromJson(dynamic json) {
    List<String> images = [];

    (json['images'] ?? []).forEach((e) {
      images.add(e.toString());
    });

    return ProdukDetailMarket(
      id: json['_id'],
      title: json['judul'],
      description: json['description'],
      thumbnail: json['thumbnail'],
      categoryId: json['category_id'],
      weight: json['berat'] ?? 1000,
      price: json['harga_jual'] ?? 0,
      stock: json['stock'] ?? 0,
      images: images,
    );
  }
}

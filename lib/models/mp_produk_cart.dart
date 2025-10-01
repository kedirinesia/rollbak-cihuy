
import 'package:mobile/models/mp_produk_detail.dart';

class ProdukCartMarket extends ProdukDetailMarket {
  int count;

  ProdukCartMarket({
    required  String id,
    required String title,
    required String description,
    required String thumbnail,
    required int weight,
    required int price,
    required int stock,
    required String categoryId,
    required List<String> images,
    required this.count,
  }) : super(
          id: id,
          title: title,
          description: description,
          thumbnail: thumbnail,
          weight: weight,
          price: price,
          stock: stock,
          categoryId: categoryId,
          images: images,
        );

  factory ProdukCartMarket.create({required ProdukDetailMarket produk, required int count}) {
    return ProdukCartMarket(
      id: produk.id,
      categoryId: produk.categoryId,
      title: produk.title,
      description: produk.description,
      thumbnail: produk.thumbnail,
      weight: produk.weight,
      price: produk.price,
      stock: produk.stock,
      images: produk.images,
      count: count,
    );
  }

  factory ProdukCartMarket.parse(dynamic map) {
    return ProdukCartMarket(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      thumbnail: map['thumbnail'],
      weight: map['weight'],
      price: map['price'],
      stock: map['stock'],
      categoryId: map['categoryId'],
      images: map['images'],
      count: map['count'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'title': this.title,
      'description': this.description,
      'thumbnail': this.thumbnail,
      'weight': this.weight,
      'price': this.price,
      'stock': this.stock,
      'images': this.images,
      'count': this.count,
    };
  }
}

// @dart=2.9

import 'package:mobile/models/mp_produk_detail.dart';

class ProdukCartMarket extends ProdukDetailMarket {
  int count;

  ProdukCartMarket({
    String id,
    String title,
    String description,
    String thumbnail,
    int weight,
    int price,
    int stock,
    List<String> images,
    this.count,
  }) : super(
          id: id,
          title: title,
          description: description,
          thumbnail: thumbnail,
          weight: weight,
          price: price,
          stock: stock,
          images: images,
        );

  factory ProdukCartMarket.create({ProdukDetailMarket produk, int count}) {
    return ProdukCartMarket(
      id: produk.id,
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

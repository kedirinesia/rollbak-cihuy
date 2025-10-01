
class ProdukMarket {
  final String id;
  final String title;
  final String thumbnail;
  final int price;
  final String categoryId;

  ProdukMarket(
      {required this.id, required this.title, required this.thumbnail, required this.price, required this.categoryId});

  factory ProdukMarket.fromJson(dynamic data) {
    return ProdukMarket(
      id: data['_id'],
      title: data['judul'],
      thumbnail: data['thumbnail'],
      price: data['harga_jual'],
      categoryId: data['category_id'],
    );
  }
}

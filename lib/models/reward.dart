// @dart=2.9

class RewardModel {
  String id;
  String title;
  String description;
  String imageUrl;
  int poin;
  int poinPromo;
  int stock;
  String createdAt;

  RewardModel(
      {this.id,
      this.title,
      this.description,
      this.imageUrl,
      this.poin,
      this.poinPromo,
      this.stock,
      this.createdAt});

  factory RewardModel.fromJson(dynamic json) {
    return RewardModel(
        id: json['_id'],
        title: json['title'],
        description: json['description'],
        imageUrl: json['url_images'],
        poin: json['poin'],
        poinPromo: json['poin_promo'],
        stock: json['stock'],
        createdAt: json['created_at']);
  }
}

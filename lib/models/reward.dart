
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
      { required this.id,
      required this.title,
      required this.description,
      required this.imageUrl,
      required this.poin,
      required this.poinPromo,
      required this.stock,
      required this.createdAt});

  factory RewardModel.fromJson(dynamic json) {
    return RewardModel(
        id: json['_id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        imageUrl: json['url_images'] ?? '',
        poin: json['poin'] ?? 0,
        poinPromo: json['poin_promo'] ?? 0,
        stock: json['stock'] ?? 0,
        createdAt: json['created_at'] ?? '');
  }
}

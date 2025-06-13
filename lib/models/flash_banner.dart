// @dart=2.9

class FlashBannerModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String url;
  final String createdAt;
  final bool aktif;
  final int type;

  FlashBannerModel(
      {this.id,
      this.title,
      this.description,
      this.imageUrl,
      this.url,
      this.createdAt,
      this.aktif,
      this.type});

  factory FlashBannerModel.fromJson(Map<String, dynamic> data) {
    return FlashBannerModel(
        id: data['_id'],
        title: data['judul'],
        description: data['description'],
        imageUrl: data['url_image'],
        url: data['url_click'],
        createdAt: data['created_at'],
        aktif: data['aktif'],
        type: data['type']);
  }
}

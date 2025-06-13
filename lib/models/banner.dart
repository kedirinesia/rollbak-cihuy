// @dart=2.9

class BannerModel {
  String title;
  String cover;
  String url;
  String id;

  BannerModel({this.title, this.cover, this.id, this.url});

  BannerModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    id = json['_id'];
    cover = json['cover'] ?? '';
    url = json['url'];
  }
}

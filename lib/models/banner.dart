
class BannerModel {
  String title;
  String cover;
  String url;
  String id;

  BannerModel({required this.title, required this.cover, required this.id, required this.url});

  BannerModel.fromJson(Map<String, dynamic> json)
      : title = json['title'] ?? '',
        id = json['_id'] ?? '',
        cover = json['cover'] ?? '',
        url = json['url'] ?? '';
  }


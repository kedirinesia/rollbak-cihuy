
class InfoModel {
  String title;
  String description;
  String url;
  String icon;
  String content;
  String id;

  InfoModel(
      {required this.title,
      required this.description,
      required this.url,
      required this.icon,
      required this.content,
      required this.id});

  factory InfoModel.fromJson(dynamic json) {
    return InfoModel(
        id: json['_id'],
        title: json['judul'],
        description: json['description'],
        url: json['url'] ?? "",
        icon: json['icon'],
        content: json['content'] ?? "");
  }
}

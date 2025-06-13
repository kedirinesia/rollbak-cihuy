// @dart=2.9

class InfoModel {
  String title;
  String description;
  String url;
  String icon;
  String content;
  String id;

  InfoModel(
      {this.title,
      this.description,
      this.url,
      this.icon,
      this.content,
      this.id});

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

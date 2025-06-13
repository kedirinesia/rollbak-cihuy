// @dart=2.9

class MetodeBayarModel {
  final int type;
  final String id;
  final String title;
  final String code;
  final String icon;
  String description;
  Map<String, dynamic> admin;

  MetodeBayarModel(
      {this.id,
      this.type,
      this.title,
      this.code,
      this.icon,
      this.description,
      this.admin});

  factory MetodeBayarModel.fromJson(dynamic json) {
    return MetodeBayarModel(
      id: json['_id'] ?? '',
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      icon: json['icon'] ?? '',
      description: json['description'] ?? ' ',
      type: json['type'] ?? 0,
      admin: json['admin'] ?? null,
    );
  }
}

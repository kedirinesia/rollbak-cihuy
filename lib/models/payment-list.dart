// @dart=2.9

class PaymentModel {
  String id;
  int type;
  String title;
  String cover;
  String icon;
  String description;
  String channel;
  Map<String, dynamic> admin;
  Map<String, dynamic> admin_trx;

  PaymentModel(
      {this.title,
      this.cover,
      this.id,
      this.type,
      this.icon,
      this.description,
      this.channel,
      this.admin});

  PaymentModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    id = json['_id'];
    cover = json['cover'] ?? '';
    icon = json['icon'] ?? '';
    description = json['description'] ?? ' ';
    channel = json['channel'] ?? '';
    type = json['type'] ?? 0;
    admin = json['admin'];
    admin_trx = json['admin_trx'] ?? null;
  }
}

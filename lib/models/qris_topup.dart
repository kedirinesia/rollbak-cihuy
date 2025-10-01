
class QrisTopupModel {
  String channel;
  String displayName;
  String expired;
  String code;
  int nominal;
  int fee;
  int admin;
  int total;

  QrisTopupModel(
      {required this.channel,
      required this.displayName,
      required this.expired,
      required this.code,
      required this.nominal,
      required this.fee,
      required this.admin,
      required this.total});

  factory QrisTopupModel.fromJson(dynamic json) {
    return QrisTopupModel(
        channel: json['channel'] ?? '',
        displayName: json['displayName'] ?? '',
        expired: json['expired'] ?? '',
        code: json['va'] ?? '',
        nominal: json['nominal'] ?? 0,
        fee: json['fee'] ?? 0,
        admin: json['admin'] ?? 0,
        total: json['totalBayar'] ?? 0);
  }
}

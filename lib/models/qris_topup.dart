// @dart=2.9

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
      {this.channel,
      this.displayName,
      this.expired,
      this.code,
      this.nominal,
      this.fee,
      this.admin,
      this.total});

  factory QrisTopupModel.fromJson(dynamic json) {
    return QrisTopupModel(
        channel: json['channel'],
        displayName: json['displayName'],
        expired: json['expired'],
        code: json['va'],
        nominal: json['nominal'],
        fee: json['fee'],
        admin: json['admin'],
        total: json['totalBayar']);
  }
}

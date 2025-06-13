// @dart=2.9

class EwalletAccount {
  final String name;
  final String code;
  final String description;
  final String provider;
  final int fee;

  EwalletAccount(
      {this.name, this.code, this.description, this.provider, this.fee});

  factory EwalletAccount.fromJson(dynamic json) => EwalletAccount(
      name: json['ewallet_name'],
      code: json['ewallet_code'],
      description: json['desc'],
      provider: json['provider'],
      fee: json['admin']['nominal'] ?? 0);
}

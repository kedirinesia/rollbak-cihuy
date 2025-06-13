// @dart=2.9

class VirtualAccount {
  final String name;
  final String code;
  final String description;
  final String provider;
  final int fee;

  VirtualAccount(
      {this.name, this.code, this.description, this.provider, this.fee});

  factory VirtualAccount.fromJson(dynamic json) => VirtualAccount(
      name: json['vaname'],
      code: json['vacode'],
      description: json['desc'],
      provider: json['provider'],
      fee: json['fee'] ?? 0);
}

class VirtualAccountResponse {
  final String va;
  final String channel;
  final int fee;
  final int amount;
  final int totalAmount;
  final String name;
  final String description;
  final String expiredAt;

  VirtualAccountResponse(
      {this.va,
      this.channel,
      this.fee,
      this.amount,
      this.totalAmount,
      this.name,
      this.description,
      this.expiredAt});

  factory VirtualAccountResponse.fromJson(dynamic json) =>
      VirtualAccountResponse(
        va: json['va'],
        channel: json['channel'],
        fee: json['fee'] ?? 0,
        amount: json['nominal'] ?? 0,
        totalAmount: json['totalBayar'] ?? 0,
        name: json['displayName'] ?? '',
        description: json['keterangan'],
        expiredAt: json['expired'],
      );
}

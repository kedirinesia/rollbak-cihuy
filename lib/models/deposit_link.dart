// @dart=2.9

class DepositLink {
  String url;
  int nominal;
  int admin;
  int fee;
  int totalBayar;
  int saldoMasuk;

  DepositLink(
      {this.url,
      this.nominal,
      this.admin,
      this.fee,
      this.totalBayar,
      this.saldoMasuk});

  factory DepositLink.fromJson(dynamic json) {
    return DepositLink(
        url: json['url_payment'],
        nominal: json['nominal'],
        admin: json['admin'],
        fee: json['fee'],
        totalBayar: json['total_bayar'],
        saldoMasuk: json['saldo_masuk']);
  }
}


class DepositLink {
  String url;
  int nominal;
  int admin;
  int fee;
  int totalBayar;
  int saldoMasuk;

  DepositLink(
      {required this.url,
      required this.nominal,
      required this.admin,
      required this.fee,
      required this.totalBayar,
      required this.saldoMasuk});

  factory DepositLink.fromJson(dynamic json) {
    return DepositLink(
        url: json['url_payment'] ?? '',
        nominal: json['nominal'] ?? 0,
        admin: json['admin'] ?? 0,
        fee: json['fee'] ?? 0,
        totalBayar: json['total_bayar'] ?? 0,
        saldoMasuk: json['saldo_masuk'] ?? 0);
  }
}

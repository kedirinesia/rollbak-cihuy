// @dart=2.9

class VaTopup {
  String kode;
  String nama;
  int nominal;
  int fee;
  int total;
  String expiredDate;
  String keterangan;

  VaTopup(
      {this.kode,
      this.nama,
      this.nominal,
      this.fee,
      this.total,
      this.expiredDate,
      this.keterangan});

  factory VaTopup.fromJson(Map<String, dynamic> json) {
    return VaTopup(
        kode: json['kode_pembayaran'],
        nama: json['displayName'],
        nominal: json['nominal'],
        fee: json['fee'],
        total: json['totalBayar'],
        expiredDate: json['expired_at'],
        keterangan: json['keterangan'] ?? '');
  }
}

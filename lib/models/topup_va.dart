
class VaTopup {
  String kode;
  String nama;
  int nominal;
  int fee;
  int total;
  String expiredDate;
  String keterangan;

  VaTopup(
      {required this.kode,
      required this.nama,
      required this.nominal,
      required this.fee,
      required this.total,
      required this.expiredDate,
      required this.keterangan});

  factory VaTopup.fromJson(Map<String, dynamic> json) {
    return VaTopup(
        kode: json['kode_pembayaran'] ?? '',
        nama: json['displayName'] ?? '',
        nominal: json['nominal'] ?? 0,
        fee: json['fee'] ?? 0,
        total: json['totalBayar'] ?? 0,
        expiredDate: json['expired_at'] ?? '',
        keterangan: json['keterangan'] ?? '');
  }
}

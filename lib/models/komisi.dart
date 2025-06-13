// @dart=2.9

class Komisi {
  String id;
  String keterangan;
  String createdAt;
  int tipe;
  int jumlah;

  Komisi({this.id, this.jumlah, this.keterangan, this.tipe, this.createdAt});

  factory Komisi.fromJson(dynamic json) {
    return Komisi(
        id: json['_id'],
        jumlah: json['jumlah'] ?? 0,
        keterangan: json['keterangan'] ?? '-',
        tipe: json['type'] ?? 0,
        createdAt: json['created_at']);
  }
}

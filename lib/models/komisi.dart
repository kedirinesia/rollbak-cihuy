
class Komisi {
  String id;
  String keterangan;
  String createdAt;
  int tipe;
  int jumlah;

  Komisi({required this.id, required this.jumlah, required this.keterangan, required this.tipe, required this.createdAt});

  factory Komisi.fromJson(dynamic json) {
    return Komisi(
        id: json['_id'],
        jumlah: json['jumlah'] ?? 0,
        keterangan: json['keterangan'] ?? '-',
        tipe: json['type'] ?? 0,
        createdAt: json['created_at']);
  }
}


class MutasiModel {
  late String keterangan;
  late int jumlah;
  late String type;
  late int saldo_awal;
  late int saldo_akhir;
  late String ref_id;
  late String created_at;
  late String id;

  MutasiModel(
      {required this.keterangan,
      required this.jumlah,
      required this.id,
      required this.type,
      required this.saldo_awal,
      required this.saldo_akhir,
      required this.ref_id,
      required this.created_at});

  MutasiModel.fromJson(Map<String, dynamic> json) {
    keterangan = json['keterangan'] ?? '';
    id = json['_id'] ?? '';
    jumlah = json['jumlah'] ?? 0;
    type = json['type'] ?? 'UN';
    saldo_awal = json['saldo_awal'] ?? 0;
    saldo_akhir = json['saldo_akhir'] ?? 0;
      created_at = json['created_at'] ?? '';
    ref_id = json['ref_id'] ?? '';
  }
}

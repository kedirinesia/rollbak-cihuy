// @dart=2.9

class MutasiModel {
  String keterangan;
  int jumlah;
  String type;
  int saldo_awal;
  int saldo_akhir;
  String ref_id;
  String created_at;
  String id;

  MutasiModel(
      {this.keterangan,
      this.jumlah,
      this.id,
      this.type,
      this.saldo_awal,
      this.saldo_akhir,
      this.created_at});

  MutasiModel.fromJson(Map<String, dynamic> json) {
    keterangan = json['keterangan'];
    id = json['_id'];
    jumlah = json['jumlah'] ?? 0;
    type = json['type'] ?? 'UN';
    saldo_awal = json['saldo_awal'] ?? 0;
    saldo_akhir = json['saldo_akhir'] ?? 0;
    created_at = json['created_at'] ?? '';
  }
}

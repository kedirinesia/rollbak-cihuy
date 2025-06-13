// @dart=2.9

class TransferModel {
  String id;
  String userId;
  String keterangan;
  String type;
  int jumlah;
  int saldoAwal;
  int saldoAkhir;
  String createdAt;

  TransferModel(
      {this.id,
      this.userId,
      this.keterangan,
      this.type,
      this.jumlah,
      this.saldoAkhir,
      this.saldoAwal,
      this.createdAt});

  factory TransferModel.fromJson(dynamic json) {
    return TransferModel(
        id: json['_id'],
        userId: json['user_id'],
        keterangan: json['keterangan'],
        type: json['type'],
        jumlah: json['jumlah'],
        saldoAwal: json['saldo_awal'],
        saldoAkhir: json['saldo_akhir'],
        createdAt: json['created_at']);
  }
}

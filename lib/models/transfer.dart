
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
      {required this.id,
      required this.userId,
      required this.keterangan,
      required      this.type,
      required  this.jumlah,
      required this.saldoAkhir,
      required this.saldoAwal,
      required this.createdAt});

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

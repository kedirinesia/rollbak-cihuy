// @dart=2.9


class CountTrx {
  final int totalTrx;
  final int totalTrxPending;
  final int totalTrxSuccess;
  final int totalTrxGagal;
  final int totalVolumeTrx;

  CountTrx(
      {this.totalTrx,
      this.totalTrxPending,
      this.totalTrxSuccess,
      this.totalTrxGagal,
      this.totalVolumeTrx});

  factory CountTrx.fromJson(Map<String, dynamic> json) {
    return CountTrx(
        totalTrx: json['total_trx'],
        totalTrxPending: json['total_trx_pending'],
        totalTrxSuccess: json['total_trx_success'],
        totalTrxGagal: json['total_trx_gagal'],
        totalVolumeTrx: json['total_volume_trx']);
  }
}

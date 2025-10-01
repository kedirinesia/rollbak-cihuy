

class CountTrx {
  final int totalTrx;
  final int totalTrxPending;
  final int totalTrxSuccess;
  final int totalTrxGagal;
  final int totalVolumeTrx;

  CountTrx(
      {required this.totalTrx,
      required this.totalTrxPending,
      required this.totalTrxSuccess,
      required this.totalTrxGagal,
      required this.totalVolumeTrx});

  factory CountTrx.fromJson(Map<String, dynamic> json) {
    return CountTrx(
        totalTrx: json['total_trx'] ?? 0,
        totalTrxPending: json['total_trx_pending'] ?? 0,
        totalTrxSuccess: json['total_trx_success'] ?? 0,
        totalTrxGagal: json['total_trx_gagal'] ?? 0,
        totalVolumeTrx: json['total_volume_trx'] ?? 0);
  }
}

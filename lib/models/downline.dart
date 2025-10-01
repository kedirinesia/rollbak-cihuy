
class DownlineModel {
  String id;
  String nama;
  String nomor;
  String namaToko;
  int saldo;
  int point;
  int markup;
  int downlineTotal;
  bool verified;
  bool status;
  String registerAt;

  DownlineModel({
    required  this.id,
    required this.nama,
    required this.nomor,
    required this.namaToko,
    required    this.saldo,
    required this.point,
    required this.markup,
    required this.downlineTotal,
    required this.verified,
    required  this.status,
    required this.registerAt,
  });

  factory DownlineModel.fromJson(dynamic json) {
    return DownlineModel(
      id: json['_id'],
      nama: json['nama'],
      nomor: json['phone'] ?? '',
      namaToko: json['toko'] == null ? '-' : json['toko']['nama'],
      saldo: json['saldo'],
      point: json['poin'],
      markup: json['markup'],
      downlineTotal: json['total_downline'] ?? 0,
      verified: json['kycVerification'] ?? false,
      status: json['aktif'] ?? true,
      registerAt: json['created_at'],
    );
  }
}

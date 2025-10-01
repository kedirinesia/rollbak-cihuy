
class BankModel {
  String id;
  String namaBank;
  String namaRekening;
  String noRek;
  String urlImage;
  bool isGangguan;

  BankModel(
      {required     this.id,
      required this.namaBank,
      required this.namaRekening,
      required this.noRek,
      required this.isGangguan,
      required this.urlImage});

  factory BankModel.fromJson(dynamic json) {
    return BankModel(
        id: json['_id'] ?? '',
        namaBank: json['nama_bank'] ?? '',
        namaRekening: json['nama_rekening'] ?? '',
        noRek: json['no_rekening'] ?? '',
        isGangguan: json['is_gangguan'] ?? false,
        urlImage: json['url_image'] ?? '');
  }
}

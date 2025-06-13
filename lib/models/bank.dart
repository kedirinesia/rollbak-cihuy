// @dart=2.9

class BankModel {
  String id;
  String namaBank;
  String namaRekening;
  String noRek;
  String urlImage;
  bool isGangguan;

  BankModel(
      {this.id,
      this.namaBank,
      this.namaRekening,
      this.noRek,
      this.isGangguan,
      this.urlImage});

  factory BankModel.fromJson(dynamic json) {
    return BankModel(
        id: json['_id'],
        namaBank: json['nama_bank'],
        namaRekening: json['nama_rekening'],
        noRek: json['no_rekening'],
        isGangguan: json['is_gangguan'] ?? false,
        urlImage: json['url_image']);
  }
}


class DaftarTransferModel {
  String id;
  String kodeProduk;
  String namaBank;
  String namaRekening;
  String noTujuan;

  bool isFavorite;

  DaftarTransferModel({
    required this.id,
    required this.kodeProduk,
    required this.namaBank,
    required this.namaRekening,
    required this.noTujuan,
    required this.isFavorite,
  });

  factory DaftarTransferModel.create(DaftarTransferModel transfer) {
    return DaftarTransferModel(
      id: transfer.id,
      kodeProduk: transfer.kodeProduk,
      namaBank: transfer.namaBank,
      namaRekening: transfer.namaRekening,
      noTujuan: transfer.noTujuan,
      isFavorite: transfer.isFavorite,
    );
  }

  factory DaftarTransferModel.parse(dynamic map) {
    return DaftarTransferModel(
      id: map['id'],
      kodeProduk: map['kodeProduk'],
      namaBank: map['namaBank'],
      namaRekening: map['namaRekening'],
      noTujuan: map['noTujuan'],
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'kodeProduk': this.kodeProduk,
      'namaBank': this.namaBank,
      'namaRekening': this.namaRekening,
      'noTujuan': this.noTujuan,
      'isFavorite': this.isFavorite,
    };
  }
}

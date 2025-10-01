
class ListBankModel {
  String nama;
  String description;
  String kodeProduk;
  int admin;
  int hargaJual;

  ListBankModel(
      {required this.nama,
      required this.description,
      required this.kodeProduk,
      required this.admin,
      required this.hargaJual});

  factory ListBankModel.fromJson(dynamic json) {
    return ListBankModel(
        nama: json['nama'],
        description: json['description'],
        kodeProduk: json['kode_produk'],
        admin: json['admin'],
        hargaJual: json['harga_jual']);
  }
}

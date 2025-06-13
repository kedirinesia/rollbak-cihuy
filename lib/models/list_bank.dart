// @dart=2.9

class ListBankModel {
  String nama;
  String description;
  String kodeProduk;
  int admin;
  int hargaJual;

  ListBankModel(
      {this.nama,
      this.description,
      this.kodeProduk,
      this.admin,
      this.hargaJual});

  factory ListBankModel.fromJson(dynamic json) {
    return ListBankModel(
        nama: json['nama'],
        description: json['description'],
        kodeProduk: json['kode_produk'],
        admin: json['admin'],
        hargaJual: json['harga_jual']);
  }
}

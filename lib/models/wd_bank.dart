// @dart=2.9

class WithdrawBankModel {
  final String id;
  final String kodeProduk;
  final String nama;
  final String description;
  final int hargaJual;
  final int admin;
  final int cashback;

  WithdrawBankModel(
      {this.id,
      this.kodeProduk,
      this.nama,
      this.description,
      this.hargaJual,
      this.admin,
      this.cashback});

  factory WithdrawBankModel.fromJson(Map<String, dynamic> json) {
    return WithdrawBankModel(
        id: json['_id'],
        kodeProduk: json['kode_produk'],
        nama: json['nama'],
        description: json['description'],
        hargaJual: json['harga_jual'] ?? 0,
        admin: json['admin'] ?? 0,
        cashback: json['fee_member'] ?? 0);
  }
}

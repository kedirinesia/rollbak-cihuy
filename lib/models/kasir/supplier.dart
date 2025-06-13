// @dart=2.9

class SupplierModel {
  String id;
  String nama;
  String email;
  String telp;
  String alamat;
  bool aktif;
  int saldoHutang;
  String created_at;

  SupplierModel(
      {this.id,
      this.nama,
      this.email,
      this.telp,
      this.alamat,
      this.aktif,
      this.saldoHutang,
      this.created_at});

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
        id: json['_id'],
        nama: json['nama'],
        email: json['email'],
        telp: json['telp'],
        alamat: json['alamat'],
        saldoHutang: json['saldo_hutang'] != null ? json['saldo_hutang'] : 0,
        aktif: json['aktif'] ?? false,
        created_at: json['created_at']);
  }
}

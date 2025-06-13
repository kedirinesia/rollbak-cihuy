// @dart=2.9

class CustomerModel {
  String id;
  String nama;
  String email;
  String telp;
  String alamat;
  bool aktif;
  int saldoHutang;
  String created_at;

  CustomerModel(
      {this.id,
      this.nama,
      this.email,
      this.telp,
      this.alamat,
      this.aktif,
      this.saldoHutang,
      this.created_at});

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
        id: json['_id'],
        nama: json['nama'] != null ? json['nama'] : '-',
        email: json['email'] != null ? json['email'] : '-',
        telp: json['telp'] != null ? json['telp'] : '-',
        alamat: json['alamat'] != null ? json['alamat'] : '-',
        aktif: json['aktif'] ?? false,
        saldoHutang: json['saldo_hutang'] != null ? json['saldo_hutang'] : 0,
        created_at: json['created_at']);
  }
}

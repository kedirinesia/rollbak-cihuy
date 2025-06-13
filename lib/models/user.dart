// @dart=2.9

class UserModel {
  String nama;
  String phone;
  String email;
  String kode_merchant;
  int poin;
  int saldo;
  int komisi;
  bool kyc_verification;
  dynamic kyc;
  bool aktif;
  String id;
  String idProvinsi;
  String idKota;
  String idKecamatan;
  String alamat;
  String namaToko;
  String alamatToko;
  bool enableWithdraw;
  String inviteCode;

  UserModel({
    this.nama,
    this.phone,
    this.email,
    this.id,
    this.kyc_verification,
    this.kyc,
    this.kode_merchant,
    this.saldo,
    this.komisi,
    this.poin,
    this.idProvinsi,
    this.idKota,
    this.idKecamatan,
    this.alamat,
    this.namaToko,
    this.alamatToko,
    this.aktif,
    this.enableWithdraw,
    this.inviteCode,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    nama = json['nama'];
    phone = json['phone'];
    email = json['email'];
    id = json['_id'];
    kyc_verification = json['kyc_verification'];
    kyc = json['kyc'] ?? '';
    kode_merchant = json['kode_merchant'];
    saldo = json['saldo'] ?? 0;
    poin = json['poin'] ?? 0;
    komisi = json['komisi'] ?? 0;
    idProvinsi = json['id_propinsi'];
    idKota = json['id_kabupaten'];
    idKecamatan = json['id_kecamatan'];
    alamat = json['alamat'] ?? '-';
    namaToko = json['toko']['nama'] ?? '';
    alamatToko = json['toko']['alamat'] ?? '';
    aktif = json['aktif'] ?? true;
    enableWithdraw = json['enable_bank_transfer'] ?? false;
    inviteCode = json['invite_code'] ?? '';
  }

  factory UserModel.create({UserModel user}) {
    return UserModel(
      nama: user.nama,
      phone: user.phone,
      id: user.id,
      kyc_verification: user.kyc_verification,
      kyc: user.kyc ?? '',
      kode_merchant: user.kode_merchant,
      saldo: user.saldo ?? 0,
      poin: user.poin ?? 0,
      komisi: user.komisi ?? 0,
      idProvinsi: user.idProvinsi,
      idKota: user.idKota,
      idKecamatan: user.idKecamatan,
      alamat: user.alamat ?? '-',
      namaToko: user.namaToko ?? '',
      alamatToko: user.alamatToko ?? '',
      aktif: user.aktif ?? true,
      enableWithdraw: user.enableWithdraw ?? false,
      inviteCode: user.inviteCode ?? '',
    );
  }

  factory UserModel.parse(dynamic map) {
    return UserModel(
      nama: map['nama'],
      phone: map['phone'],
      id: map['id'],
      kyc_verification: map['kyc_verification'],
      kyc: map['kyc'] ?? '',
      kode_merchant: map['kode_merchant'] ?? '',
      saldo: map['saldo'] ?? 0,
      poin: map['poin'] ?? 0,
      komisi: map['komisi'] ?? 0,
      idProvinsi: map['id_propinsi'],
      idKota: map['id_kabupaten'],
      idKecamatan: map['id_kecamatan'],
      alamat: map['alamat'] ?? '-',
      namaToko: map['toko']['nama'] ?? '',
      alamatToko: map['toko']['alamat'] ?? '',
      aktif: map['aktif'] ?? true,
      enableWithdraw: map['enable_bank_transfer'] ?? false,
      inviteCode: map['invite_code'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': this.nama,
      'phone': this.phone,
      'id': this.id,
      'kyc_verification': this.kyc_verification,
      'kyc': this.kyc,
      'kode_merchant': this.kode_merchant,
      'saldo': this.saldo,
      'poin': this.poin,
      'komisi': this.komisi,
      'idProvinsi': this.idProvinsi,
      'idKota': this.idKota,
      'idKecamatan': this.idKecamatan,
      'alamat': this.alamat,
      'namaToko': this.namaToko,
      'alamatToko': this.alamatToko,
      'aktif': this.aktif,
      'enableWithdraw': this.enableWithdraw,
      'inviteCode': this.inviteCode,
    };
  }
}

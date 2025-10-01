
class UserModel {
  late String nama;
  late String phone;
  late String email;
  late String kode_merchant;
  late int poin;
  late int saldo;
  late int komisi;
  late bool kyc_verification;
  late dynamic kyc;
  late bool aktif;
  late String id;
  late String idProvinsi;
  late String idKota;
  late String idKecamatan;
  late String alamat;
  late String namaToko;
  late String alamatToko;
  late bool enableWithdraw;
  late String inviteCode;

  UserModel({
    String? nama,
    String? phone,
    String? email,
    String? id,
    bool? kyc_verification,
    dynamic kyc,
    String? kode_merchant,
    int? saldo,
    int? komisi,
    int? poin,
    String? idProvinsi,
    String? idKota,
    String? idKecamatan,
    String? alamat,
    String? namaToko,
    String? alamatToko,
    bool? aktif,
    bool? enableWithdraw,
    String? inviteCode,
  }) {
    this.nama = nama ?? '';
    this.phone = phone ?? '';
    this.email = email ?? '';
    this.id = id ?? '';
    this.kyc_verification = kyc_verification ?? false;
    this.kyc = kyc ?? '';
    this.kode_merchant = kode_merchant ?? '';
    this.saldo = saldo ?? 0;
    this.komisi = komisi ?? 0;
    this.poin = poin ?? 0;
    this.idProvinsi = idProvinsi ?? '';
    this.idKota = idKota ?? '';
    this.idKecamatan = idKecamatan ?? '';
    this.alamat = alamat ?? '';
    this.namaToko = namaToko ?? '';
    this.alamatToko = alamatToko ?? '';
    this.aktif = aktif ?? false;
    this.enableWithdraw = enableWithdraw ?? false;
    this.inviteCode = inviteCode ?? '';
  }

  UserModel.fromJson(Map<String, dynamic> json) {
    nama = json['nama'] ?? '';
    phone = json['phone'] ?? '';
    email = json['email'] ?? '';
    id = json['_id'] ?? '';
    kyc_verification = json['kyc_verification'] ?? false;
    kyc = json['kyc'] ?? '';
    kode_merchant = json['kode_merchant'] ?? '';
    saldo = json['saldo'] ?? 0;
    poin = json['poin'] ?? 0;
    komisi = json['komisi'] ?? 0;
    idProvinsi = json['id_propinsi'] ?? '';
    idKota = json['id_kabupaten'] ?? '';
    idKecamatan = json['id_kecamatan'] ?? '';
    alamat = json['alamat'] ?? '';
    namaToko = json['toko']?['nama'] ?? '';
    alamatToko = json['toko']?['alamat'] ?? '';
    aktif = json['aktif'] ?? false;
    enableWithdraw = json['enable_bank_transfer'] ?? false;
    inviteCode = json['invite_code'] ?? '';
  }

  factory UserModel.parse(dynamic map) {
    if (map == null) {
      return UserModel();
    }

    return UserModel(
      nama: map['nama'] ?? '',
      phone: map['phone'] ?? '',
      id: map['id'] ?? '',
      kyc_verification: map['kyc_verification'] ?? false,
      kyc: map['kyc'] ?? '',
      kode_merchant: map['kode_merchant'] ?? '',
      saldo: map['saldo'] ?? 0,
      poin: map['poin'] ?? 0,
      komisi: map['komisi'] ?? 0,
      idProvinsi: map['id_propinsi'] ?? '',
      idKota: map['id_kabupaten'] ?? '',
      idKecamatan: map['id_kecamatan'] ?? '',
      alamat: map['alamat'] ?? '',
      namaToko: map['toko']?['nama'] ?? '',
      alamatToko: map['toko']?['alamat'] ?? '',
      aktif: map['aktif'] ?? false,
      enableWithdraw: map['enable_bank_transfer'] ?? false,
      inviteCode: map['invite_code'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'phone': phone,
      'email': email,
      '_id': id,
      'kyc_verification': kyc_verification,
      'kyc': kyc,
      'kode_merchant': kode_merchant,
      'saldo': saldo,
      'poin': poin,
      'komisi': komisi,
      'id_propinsi': idProvinsi,
      'id_kabupaten': idKota,
      'id_kecamatan': idKecamatan,
      'alamat': alamat,
      'toko': {
        'nama': namaToko,
        'alamat': alamatToko,
      },
      'aktif': aktif,
      'enable_bank_transfer': enableWithdraw,
      'invite_code': inviteCode,
    };
  }
}

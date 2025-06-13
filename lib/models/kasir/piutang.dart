// @dart=2.9

import 'package:mobile/models/kasir/customer.dart';

class PiutangModel {
  String id;
  int type;
  String jatuhTempo;
  // int sisaBayar;
  List idTrx;
  String created_at;
  String updated_at;
  CustomerModel customerModel;

  PiutangModel({
    this.id,
    this.type,
    this.jatuhTempo,
    // this.sisaBayar,
    this.customerModel,
    this.created_at,
    this.updated_at,
    this.idTrx,
  });

  factory PiutangModel.fromJson(Map<String, dynamic> json) {
    return PiutangModel(
        id: json['_id'],
        type: json['type'],
        jatuhTempo: json['jatuhTempo'] != null ? json['jatuhTempo'] : '',
        // sisaBayar : json['sisaBayar'],
        idTrx: json['id_transaksi'],
        customerModel: json['id_customer'] != null
            ? CustomerModel.fromJson(json['id_customer'])
            : null,
        created_at: json['created_at'],
        updated_at: json['updated_at']);
  }
}

class MutasiPiutangModel {
  String id;
  int debet;
  int kredit;
  String keterangan;
  String created_at;
  String updated_at;

  MutasiPiutangModel({
    this.id,
    this.debet,
    this.kredit,
    this.keterangan,
    this.created_at,
    this.updated_at,
  });

  factory MutasiPiutangModel.fromJson(Map<String, dynamic> json) {
    return MutasiPiutangModel(
      id: json['_id'],
      debet: json['debet'],
      kredit: json['kredit'],
      keterangan: json['keterangan'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
    );
  }
}

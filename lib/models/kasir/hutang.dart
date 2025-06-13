// @dart=2.9

import 'package:mobile/models/kasir/supplier.dart';

class HutangModel {
  String id;
  int type;
  String jatuhTempo;
  // int sisaBayar;
  List idTrx;
  String created_at;
  String updated_at;
  SupplierModel supplierModel;

  HutangModel({
    this.id,
    this.type,
    this.jatuhTempo,
    // this.sisaBayar,
    this.supplierModel,
    this.created_at,
    this.updated_at,
    this.idTrx,
  });

  factory HutangModel.fromJson(Map<String, dynamic> json) {
    return HutangModel(
        id: json['_id'],
        type: json['type'],
        jatuhTempo: json['jatuhTempo'] != null ? json['jatuhTempo'] : '',
        // sisaBayar : json['sisaBayar'],
        idTrx: json['id_transaksi'],
        supplierModel: json['id_supplier'] != null
            ? SupplierModel.fromJson(json['id_supplier'])
            : null,
        created_at: json['created_at'],
        updated_at: json['updated_at']);
  }
}

class MutasiHutangModel {
  String id;
  int debet;
  int kredit;
  String keterangan;
  String created_at;
  String updated_at;

  MutasiHutangModel({
    this.id,
    this.debet,
    this.kredit,
    this.keterangan,
    this.created_at,
    this.updated_at,
  });

  factory MutasiHutangModel.fromJson(Map<String, dynamic> json) {
    return MutasiHutangModel(
      id: json['_id'],
      debet: json['debet'],
      kredit: json['kredit'],
      keterangan: json['keterangan'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
    );
  }
}

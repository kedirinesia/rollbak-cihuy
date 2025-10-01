
import 'package:mobile/models/kasir/supplier.dart';

class HutangModel {
  final String id;
  final int type;
  final String jatuhTempo;
  final List<String> idTrx;
  final String? created_at;
  final String? updated_at;
  final SupplierModel? supplierModel;

  const HutangModel({
    required this.id,
    required this.type,
    required this.jatuhTempo,
    required this.idTrx,
    this.created_at,
    this.updated_at,
    this.supplierModel,
  });

  factory HutangModel.fromJson(Map<String, dynamic> json) {
    return HutangModel(
      id: json['_id'] ?? '',
      type: json['type'] ?? 0,
      jatuhTempo: json['jatuhTempo'] ?? '',
      idTrx: json['id_transaksi'] ?? [],
      supplierModel: json['id_supplier'] != null
          ? SupplierModel.fromJson(json['id_supplier'])
          : null,
      created_at: json['created_at'],
      updated_at: json['updated_at'],
    );
  }
}

class MutasiHutangModel {
  final String id;
  final int debet;
  final int kredit;
  final String keterangan;
  final String created_at;
  final String updated_at;

  const MutasiHutangModel({
    required this.id,
    required this.debet,
    required this.kredit,
    required this.keterangan,
    required this.created_at,
    required this.updated_at,
  });

  factory MutasiHutangModel.fromJson(Map<String, dynamic> json) {
    return MutasiHutangModel(
      id: json['_id'] ?? '',
      debet: json['debet'] ?? 0,
      kredit: json['kredit'] ?? 0,
      keterangan: json['keterangan'] ?? '',
      created_at: json['created_at'] ?? '',
      updated_at: json['updated_at'] ?? '',
    );
  }
}

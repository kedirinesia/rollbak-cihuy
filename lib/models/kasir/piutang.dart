
import 'package:mobile/models/kasir/customer.dart';

class PiutangModel {
  final String? id;
  final int? type;
  final String? jatuhTempo;
  // int sisaBayar;
  final List<String>? idTrx;
  final String? created_at;
  final String? updated_at;
  final CustomerModel? customerModel;

  const PiutangModel({
    this.id = '',
    this.type = 0,
    this.jatuhTempo = '',
    // this.sisaBayar,
    this.customerModel = null,
    this.created_at = '',
    this.updated_at = '',
    this.idTrx = null,
  });

  factory PiutangModel.fromJson(Map<String, dynamic> json) {
    return PiutangModel(
      id: json['_id'],
      type: json['type'],
      jatuhTempo: json['jatuhTempo'] ?? '',
      // sisaBayar : json['sisaBayar'],
      idTrx: json['id_transaksi'],
      customerModel: json['id_customer'] != null
          ? CustomerModel.fromJson(json['id_customer'])
          : null,
      created_at: json['created_at'],
      updated_at: json['updated_at']
    );
  }
}

class MutasiPiutangModel {
  final String? id;
  final int? debet;
  final int? kredit;
  final String? keterangan;
  final String? created_at;
  final String? updated_at;

  const MutasiPiutangModel({
    this.id = '',
    this.debet = 0,
    this.kredit = 0,
    this.keterangan = '',
    this.created_at = '',
    this.updated_at = '',
  });

  factory MutasiPiutangModel.fromJson(Map<String, dynamic> json) {
    return MutasiPiutangModel(
      id: json['_id'],
      debet: json['debet'],
      kredit: json['kredit'],
      keterangan: json['keterangan'],
      created_at: json['created_at'],
      updated_at: json['updated_at']
    );
  }
}

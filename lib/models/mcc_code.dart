
import 'package:mobile/modules.dart';

class MccCode {
  String id;
  String kode;
  String nama;

  MccCode({required this.id, required this.kode, required this.nama});

  factory MccCode.fromJson(dynamic json) {
    return MccCode(
      id: json['_id'],
      kode: json['mcc_code'],
      nama: recapitalize(json['mcc_name']),
    );
  }
}

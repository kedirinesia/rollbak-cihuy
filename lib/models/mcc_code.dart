// @dart=2.9

import 'package:mobile/modules.dart';
import 'package:mobile/utils/debug_helper.dart';

class MccCode {
  String id;
  String kode;
  String nama;

  MccCode({this.id, this.kode, this.nama});

  factory MccCode.fromJson(dynamic json) {
    return MccCode(
      id: json['_id'],
      kode: json['mcc_code'],
      nama: recapitalize(json['mcc_name']),
    );
  }
}

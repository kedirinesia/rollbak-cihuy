// @dart=2.9

import 'package:mobile/modules.dart';

class Lokasi {
  String id;
  String nama;
  String kode;

  Lokasi({this.id, this.nama, this.kode});

  factory Lokasi.fromJson(dynamic json) {
    return Lokasi(
      id: json['_id'],
      nama: recapitalize(json['nama']),
      kode: json['id'],
    );
  }
}

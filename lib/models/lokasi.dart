
import 'package:mobile/modules.dart';

class Lokasi {
  String id;
  String nama;
  String kode;

  Lokasi({required this.id, required this.nama, required this.kode});

  factory Lokasi.fromJson(dynamic json) {
    return Lokasi(
      id: json['_id'],
      nama: recapitalize(json['nama']),
      kode: json['id'],
    );
  }
}

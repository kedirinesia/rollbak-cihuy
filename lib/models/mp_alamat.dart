
import 'package:mobile/models/mp_kecamatan.dart';
import 'package:mobile/models/mp_kota.dart';
import 'package:mobile/models/mp_provinsi.dart';

class AlamatModel {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String address1;
  final String address2;
  final String postalCode;
  final MarketplaceProvinsi provinsi;
  final MarketplaceKota kota;
  final MarketplaceKecamatan kecamatan;

  AlamatModel(
      {required this.id,
      required this.userId,
      required this.name,
      required    this.phone,
      required this.address1,
      required this.address2,
      required this.postalCode,
      required this.provinsi,
      required this.kota,
      required this.kecamatan});

  factory AlamatModel.fromJson(dynamic json) {
    return AlamatModel(
        id: json['_id'],
        userId: json['user_id'],
        name: json['name'],
        phone: json['no_hp'],
        address1: json['address1'],
        address2: json['address2'],
        postalCode: json['zipcode'],
        provinsi: MarketplaceProvinsi.fromJson(json['state']),
        kota: MarketplaceKota.fromJson(json['city']),
        kecamatan: MarketplaceKecamatan.fromJson(json['subdistrict']));
  }
}

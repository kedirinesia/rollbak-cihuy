// @dart=2.9

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
      {this.id,
      this.userId,
      this.name,
      this.phone,
      this.address1,
      this.address2,
      this.postalCode,
      this.provinsi,
      this.kota,
      this.kecamatan});

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

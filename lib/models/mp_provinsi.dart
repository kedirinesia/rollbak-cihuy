// @dart=2.9

class MarketplaceProvinsi {
  final String id;
  final String code;
  final String name;

  MarketplaceProvinsi({this.id, this.code, this.name});

  factory MarketplaceProvinsi.fromJson(dynamic json) {
    return MarketplaceProvinsi(
        id: json['_id'], code: json['province_id'], name: json['province']);
  }
}

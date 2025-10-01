
class MarketplaceProvinsi {
  final String id;
  final String code;
  final String name;

  MarketplaceProvinsi({required this.id, required this.code, required this.name});

  factory MarketplaceProvinsi.fromJson(dynamic json) {
    return MarketplaceProvinsi(
        id: json['_id'], code: json['province_id'], name: json['province']);
  }
}

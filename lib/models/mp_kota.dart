// @dart=2.9
class MarketplaceKota {
  final String id;
  final String code;
  final String type;
  final String name;
  final String postalCode;
  final String provinceCode;
  final String provinceName;

  MarketplaceKota(
      {this.id,
      this.code,
      this.type,
      this.name,
      this.postalCode,
      this.provinceCode,
      this.provinceName});

  factory MarketplaceKota.fromJson(dynamic json) {
    return MarketplaceKota(
        id: json['_id'],
        code: json['city_id'],
        type: json['type'],
        name: json['city_name'],
        postalCode: json['postal_code'],
        provinceCode: json['province_id'],
        provinceName: json['province']);
  }
}

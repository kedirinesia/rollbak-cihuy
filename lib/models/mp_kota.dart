class MarketplaceKota {
  final String id;
  final String code;
  final String type;
  final String name;
  final String postalCode;
  final String provinceCode;
  final String provinceName;

  MarketplaceKota(
      {required   this.id,
      required this.code,
      required this.type,
      required this.name,
      required this.postalCode,
      required this.provinceCode,
      required this.provinceName});

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

// @dart=2.9

class MarketplaceKecamatan {
  final String id;
  final String code;
  final String name;
  final String cityCode;
  final String cityName;
  final String cityType;
  final String provinceCode;
  final String provinceName;

  MarketplaceKecamatan(
      {this.id,
      this.code,
      this.name,
      this.cityCode,
      this.cityName,
      this.cityType,
      this.provinceCode,
      this.provinceName});

  factory MarketplaceKecamatan.fromJson(dynamic json) {
    return MarketplaceKecamatan(
        id: json['_id'],
        code: json['subdistrict_id'],
        name: json['subdistrict_name'],
        cityCode: json['city_id'],
        cityName: json['city_name'],
        cityType: json['type'],
        provinceCode: json['province_id'],
        provinceName: json['province']);
  }
}

// @dart=2.9

class FavoriteNumberModel {
  String type;
  String tujuan;
  String nama;

  FavoriteNumberModel({this.type, this.tujuan, this.nama});

  factory FavoriteNumberModel.fromJson(dynamic json) {
    return FavoriteNumberModel(
        type: json['type'], tujuan: json['tujuan'], nama: json['nama']);
  }
}

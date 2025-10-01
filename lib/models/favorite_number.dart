
class FavoriteNumberModel {
  String type;
  String tujuan;
  String nama;

  FavoriteNumberModel({required this.type, required this.tujuan, required this.nama});

  factory FavoriteNumberModel.fromJson(dynamic json) {
    return FavoriteNumberModel(
        type: json['type'], tujuan: json['tujuan'], nama: json['nama']);
  }
}

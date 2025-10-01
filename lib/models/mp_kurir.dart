
class MPKurir {
  final String id;
  final String name;
  final String description;
  final String thumbnail;
  final String code;
  final bool active;

  MPKurir(
      { required this.id,
     required this.name,
      required this.description,
      required this.thumbnail,
      required this.code,
      required this.active});

  factory MPKurir.fromJson(dynamic json) => MPKurir(
      id: json['_id'],
      name: json['judul'],
      description: json['description'],
      thumbnail: json['thumbnail'],
      code: json['kode_kurir'],
      active: json['aktif'] ?? false);
}

class MPKurirService {
  final String service;
  final String description;
  final int cost;
  final String estimate;

  MPKurirService({required this.service, required this.description, required this.cost, required this.estimate});

  factory MPKurirService.fromJson(dynamic json) => MPKurirService(
      service: json['service'],
      description: json['description'],
      cost: json['cost'],
      estimate: json['estimate']);
}

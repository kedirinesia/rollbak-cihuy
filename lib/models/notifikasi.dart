
class NotifikasiModel {
  String id;
  int status;
  String pesan;
  bool opened;
  String createdAt;

  NotifikasiModel(
      {required this.id, required this.status, required this.pesan, required this.opened, required this.createdAt});

  factory NotifikasiModel.fromJson(dynamic json) {
    return NotifikasiModel(
        id: json['_id'],
        status: json['status'],
        pesan: json['pesan'],
        opened: json['opened'] ?? false,
        createdAt: json['created_at']);
  }
}

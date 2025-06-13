// @dart=2.9

class NotifikasiModel {
  String id;
  int status;
  String pesan;
  bool opened;
  String createdAt;

  NotifikasiModel(
      {this.id, this.status, this.pesan, this.opened, this.createdAt});

  factory NotifikasiModel.fromJson(dynamic json) {
    return NotifikasiModel(
        id: json['_id'],
        status: json['status'],
        pesan: json['pesan'],
        opened: json['opened'] ?? false,
        createdAt: json['created_at']);
  }
}

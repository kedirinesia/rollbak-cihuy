// @dart=2.9

class MenuModel {
  String name;
  String description;
  int jenis;
  int type;
  String icon;
  String category_id;
  String id;
  String kodeProduk;
  bool isString;
  bool bebasNominal;
  int orderNumber;

  MenuModel({
    this.name,
    this.jenis,
    this.description,
    this.id,
    this.category_id,
    this.icon,
    this.type,
    this.kodeProduk,
    this.isString,
    this.bebasNominal,
    this.orderNumber,
  });

  MenuModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    jenis = json['jenis'] ?? 0;
    type = json['type'] ?? 0;
    icon = json['icon'] ?? '';
    description = json['description'] ?? '';
    category_id = json['category_id'] ?? '';
    kodeProduk = json['kode_produk'] ?? ''; // <--- fix biar konsisten ke field
    isString =
        (json['menu_input']?.toString()?.toLowerCase() ?? '') == 'string';
    bebasNominal = json['bebas_nominal'] ?? false;
    orderNumber = json['order_number'];
  }

  factory MenuModel.create({MenuModel menu}) {
    return MenuModel(
      id: menu.id,
      name: menu.name,
      jenis: menu.jenis,
      type: menu.type,
      icon: menu.icon,
      description: menu.description,
      category_id: menu.category_id,
      kodeProduk: menu.kodeProduk,
      isString: menu.isString,
      bebasNominal: menu.bebasNominal,
      orderNumber: menu.orderNumber, // <-- tambahkan ini
    );
  }

  factory MenuModel.parse(dynamic map) {
    return MenuModel(
      id: map['id'],
      name: map['name'],
      jenis: map['jenis'] ?? 0,
      type: map['type'] ?? 0,
      icon: map['icon'] ?? '',
      description: map['description'] ?? '',
      category_id: map['category_id'] ?? '',
      kodeProduk: map['kode_produk'] ?? '',
      isString:
          (map['menu_input']?.toString()?.toLowerCase() ?? '') == 'string',
      bebasNominal: map['bebas_nominal'] ?? false,
      orderNumber: map['order_number'], // <-- tambahkan ini juga
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'jenis': this.jenis,
      'type': this.type,
      'icon': this.icon,
      'description': this.description,
      'category_id': this.category_id,
      'kode_produk': this.kodeProduk, // <--- key JSON harus kode_produk
      'isString': this.isString,
      'bebasNominal': this.bebasNominal,
      'order_number': this.orderNumber, // <--- tambahkan agar toMap lengkap
    };
  }
}

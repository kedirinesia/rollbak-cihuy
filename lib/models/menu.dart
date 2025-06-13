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

  MenuModel(
      {this.name,
      this.jenis,
      this.description,
      this.id,
      this.category_id,
      this.icon,
      this.type,
      this.kodeProduk,
      this.isString,
      this.bebasNominal});

  MenuModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    jenis = json['jenis'] ?? 0;
    type = json['type'] ?? 0;
    icon = json['icon'] ?? '';
    description = json['description'] ?? '';
    category_id = json['category_id'] ?? '';
    kodeProduk = json['kode_produk'] ?? '';
    isString = (json['menu_input'] as String).toLowerCase() == 'string';
    bebasNominal = json['bebas_nominal'] ?? false;
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
      isString: (map['menu_input'] as String) == 'string',
      bebasNominal: map['bebas_nominal'] ?? false,
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
      'kodeProduk': this.kodeProduk,
      'isString': this.isString,
      'bebasNominal': this.bebasNominal,
    };
  }
}

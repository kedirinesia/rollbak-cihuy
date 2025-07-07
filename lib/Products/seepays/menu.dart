class MenuModel {
  String? id;
  String? name;
  String? description;
  int? jenis;
  int? type;
  String? icon;
  String? category_id;
  String? kodeProduk;
  bool? isString;
  bool? bebasNominal;
  int? order_number;

  MenuModel({
    this.id,
    this.name,
    this.description,
    this.jenis,
    this.type,
    this.icon,
    this.category_id,
    this.kodeProduk,
    this.isString,
    this.bebasNominal,
    this.order_number,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      jenis: json['jenis'],
      type: json['type'],
      icon: json['icon'],
      category_id: json['category_id'],
      kodeProduk: json['kode_produk'],
      isString: (json['menu_input'] as String?)?.toLowerCase() == 'string',
      bebasNominal: json['bebas_nominal'],
      order_number: json['order_number'],
    );
  }

  factory MenuModel.create({required MenuModel menu}) {
    return MenuModel(
      id: menu.id,
      name: menu.name,
      description: menu.description,
      jenis: menu.jenis,
      type: menu.type,
      icon: menu.icon,
      category_id: menu.category_id,
      kodeProduk: menu.kodeProduk,
      isString: menu.isString,
      bebasNominal: menu.bebasNominal,
      order_number: menu.order_number,
    );
  }

  factory MenuModel.parse(dynamic map) {
    return MenuModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      jenis: map['jenis'],
      type: map['type'],
      icon: map['icon'],
      category_id: map['category_id'],
      kodeProduk: map['kode_produk'],
      isString: (map['menu_input'] as String?)?.toLowerCase() == 'string',
      bebasNominal: map['bebas_nominal'],
      order_number: map['order_number'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'jenis': jenis,
      'type': type,
      'icon': icon,
      'category_id': category_id,
      'kodeProduk': kodeProduk,
      'isString': isString,
      'bebasNominal': bebasNominal,
      'order_number': order_number,
    };
  }
}


class ListProductModel {
  String id;
  String id_barang;
  String sku;
  String namaBarang;
  String id_kategori;
  String id_satuan;
  int stock;
  int hargaBeli;
  int hargaJual;
  int qty;
  String created_at;

  ListProductModel({
    required  this.id,
    required this.id_barang,
    required this.sku,
    required this.namaBarang,
    required this.stock,
    required this.qty,
    required this.hargaBeli,
    required this.hargaJual,
    required this.id_kategori,
    required this.id_satuan,
    required this.created_at,
  });

  factory ListProductModel.fromJson(Map<String, dynamic> json) {
    return ListProductModel(
      id: json['_id'],
      id_barang: json['id_barang'],
      sku: json['sku'],
      namaBarang: json['nama_barang'],
      stock: json['stock'],
      hargaBeli: json['harga_beli'],
      hargaJual: json['harga_jual'],
      id_kategori: json['id_kategori'],
      id_satuan: json['id_satuan'],
      created_at: json['created_at'] != null ? json['created_at'] : '-',
      qty: 0,
    );
  }
}

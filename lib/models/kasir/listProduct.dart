// @dart=2.9

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
    this.id,
    this.id_barang,
    this.sku,
    this.namaBarang,
    this.stock,
    this.qty,
    this.hargaBeli,
    this.hargaJual,
    this.id_kategori,
    this.id_satuan,
    this.created_at,
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

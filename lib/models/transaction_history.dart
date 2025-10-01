
import 'trx.dart';

class TransactionHistoryModel extends TrxModel {
  ProdukId? produkId;

  TransactionHistoryModel({
    required String id,
    required int harga_jual,
    required int admin,
    required int status,
    required String created_at,
    required String updated_at,
    required TrxStatus statusModel,
    required Map<String, dynamic> produk,
    required String sn,
    required int counter,
    required String tujuan,
    required String keterangan,
    required  int point,
    required  String paymentBy,
    required String paymentID,
    required TrxPaymentDetail? paymentDetail,
    required List<dynamic> print,
    required this.produkId,
  }) : super(
          id: id,
          harga_jual: harga_jual,
          admin: admin,
          status: status,
          created_at: created_at,
          updated_at: updated_at,
          statusModel: statusModel,
          produk: produk,
          sn: sn,
          counter: counter,
          tujuan: tujuan,
          keterangan: keterangan,
          point: point,
          paymentBy: paymentBy,
          paymentID: paymentID,
          paymentDetail: paymentDetail,
          print: print,
        );

  factory TransactionHistoryModel.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryModel(
      id: json['_id'],
      harga_jual: json['harga_jual'] ?? 0,
      admin: json['admin'] ?? 0,
      status: json['status'] ?? 0,
      point: json['poin'] ?? 0,
      keterangan: json['keterangan'] ?? '-',
      counter: json['counter'] ?? 1,
      created_at: json['created_at'] ?? '',
      updated_at: json['updated_at'] ?? '',
      produk: json['produk_id'],
      statusModel: TrxStatus.parsing(json['status'] ?? 0),
      sn: json['sn'] ?? 'N/A',
      tujuan: json['tujuan'] ?? '-',
      paymentBy: json['payment_by'] ?? '',
      paymentID: json['payment_id'] ?? '',
      paymentDetail: json['payment_detail'] != null
          ? TrxPaymentDetail.fromJson(json['payment_detail'])
          : null,
      print: json['print'] ?? [],
      produkId: json['produk_id'] != null 
          ? ProdukId.fromJson(json['produk_id'])
          : null,
    );
  }
}

class ProdukId {
  String id;
  String kodeProduk;
  String name;
  int type;
  String description;
  KategoriId? kategoriId;

  ProdukId({
    required    this.id,
    required this.kodeProduk,
    required this.name,
    required this.type,
    required this.description,
    required this.kategoriId,
  });

  factory ProdukId.fromJson(Map<String, dynamic> json) {
    return ProdukId(
      id: json['_id'],
      kodeProduk: json['kode_produk'] ?? '',
      name: json['nama'] ?? '',
      type: json['type'] ?? 0,
      description: json['description'] ?? '',
      kategoriId: json['kategori_id'] != null 
          ? KategoriId.fromJson(json['kategori_id'])
          : null,
    );
  }
}

class KategoriId {
  String id;
  String urlImage;

  KategoriId({
    required this.id,
    required this.urlImage,
  });

  factory KategoriId.fromJson(Map<String, dynamic> json) {
    return KategoriId(
      id: json['_id'],
      urlImage: json['url_image'] ?? '',
    );
  }
}

 
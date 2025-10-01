
import 'package:mobile/models/kasir/customer.dart';
import 'package:mobile/models/kasir/supplier.dart';

class KasirPrintModel {
  final String? id;
  final String? noFaktur;
  final String? jenis;
  final bool? lunas;
  final String? termin;
  final int? totalQty;
  final int? totalBeli;
  final int? totalJual;
  final int? terbayar;
  final String? created_at;
  final String? updated_at;
  final List<Map<String, dynamic>>? detailTrx;
  final CustomerModel? customerModel;
  final SupplierModel? supplierModel;
  final Map<String, dynamic>? userID;

  KasirPrintModel({
    this.id = '',
    this.noFaktur = '',
    this.jenis = '',
    this.lunas = false,
    this.termin = '',
    this.totalQty = 0,
    this.totalBeli = 0,
    this.totalJual = 0,
    this.terbayar = 0,
    this.created_at = '',
    this.updated_at = '',
    this.detailTrx = null,
    this.customerModel = null,
    this.supplierModel = null,
    this.userID = null,
  });

  factory KasirPrintModel.fromJson(Map<String, dynamic> json) {
    return KasirPrintModel(
      id: json['_id'],
      noFaktur: json['no_faktur'],
      jenis: json['jenis'],
      lunas: json['lunas'],
      termin: json['termin'],
      totalQty: json['total_qty'],
      totalBeli: json['total_beli'],
      totalJual: json['total_jual'],
      terbayar: json['terbayar'],
      detailTrx: json['detail_trx'],
      customerModel: json['id_customer'] != null
          ? CustomerModel.fromJson(json['id_customer'])
          : null,
      supplierModel: json['id_supplier'] != null
          ? SupplierModel.fromJson(json['id_supplier'])
          : null,
      userID: json['user_id'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
    );
  }
}

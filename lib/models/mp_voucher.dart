
class VoucherMarket {
  final String id;
  final String title;
  final String description;
  final String voucherCode;
  final int minNominal;
  final int maxClaimed;
  final int nominalVoucher;
  final int minShop;
  final String startDate;
  final String endDate;
  final String categoryID;
  final bool active;
  VProductMarket? vproduk;

  VoucherMarket(
      {required   this.id,
      required this.title,
      required this.description,
      required this.voucherCode,
      required this.minNominal,
      required this.maxClaimed,
      required this.nominalVoucher,
      required this.minShop,
      required this.startDate,
      required this.endDate,
      required this.categoryID,
      required this.active,
      required this.vproduk});

  factory VoucherMarket.fromJson(dynamic json) {
    return VoucherMarket(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      voucherCode: json['voucher_code'],
      minNominal: json['min_nominal'] ?? 0,
      maxClaimed: json['max_claimed'],
      nominalVoucher: json['nominal_voucher'],
      minShop: json['min_shop'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      categoryID: json['category_id'],
      vproduk: json['produk'] != null
          ? VProductMarket.fromJson(json['produk'])
          : null,
      active: json['active'],
    );
  }
}

class VProductMarket {
  final String id;
  final int hargaBeli;
  final int hargaJual;

  VProductMarket({
    required this.id,
    required this.hargaBeli,
    required this.hargaJual,
  });

  factory VProductMarket.fromJson(dynamic json) {
    return VProductMarket(
        id: json['_id'],
        hargaBeli: json['harga_beli'],
        hargaJual: json['harga_jual']);
  }
}

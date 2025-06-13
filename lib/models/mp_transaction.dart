// @dart=2.9

import 'package:flutter/material.dart';

class MPTransaksi {
  final String id;
  final int hargaJual;
  final int ongkosKirim;
  final int totalHargaJual;
  final int totalHargaBeli;
  final String createdAt;
  final String updatedAt;
  final String paymentExpiredAt;
  final String resi;
  final int paymentType;
  final MPTransaksiStatus status;
  final MPTransaksiKurir kurir;
  final MPTransaksiShipping shipping;
  final MPTransaksiVocuher voucher;
  final List<MPTransaksiProduk> products;

  MPTransaksi(
      {this.id,
      this.hargaJual,
      this.ongkosKirim,
      this.totalHargaJual,
      this.totalHargaBeli,
      this.createdAt,
      this.updatedAt,
      this.paymentExpiredAt,
      this.resi,
      this.paymentType,
      this.status,
      this.kurir,
      this.shipping,
      this.voucher,
      this.products});

  factory MPTransaksi.fromJson(dynamic json) {
    List<MPTransaksiProduk> items = [];
    json['products'].forEach((e) => items.add(MPTransaksiProduk.fromJson(e)));
    return MPTransaksi(
      id: json['_id'],
      hargaJual: json['harga_jual'],
      ongkosKirim: json['shipping_cost'],
      totalHargaJual: json['total_harga_jual'],
      totalHargaBeli: json['total_harga_beli'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      paymentExpiredAt: json['expired_payment_at'],
      resi: json['tracking'] != null
          ? (json['tracking']['number_resi'] ?? null)
          : null,
      paymentType: json['payment_type'],
      status: MPTransaksiStatus.parse(json['status']),
      kurir: MPTransaksiKurir.fromJson(json['kurir']),
      shipping: MPTransaksiShipping.fromJson(json['shipping']),
      voucher: json['voucher_id'] != null
          ? MPTransaksiVocuher.fromJson(json['voucher_id'])
          : null,
      products: items,
    );
  }
}

class MPTransaksiVocuher {
  final String id;
  final int nominal;

  MPTransaksiVocuher({this.id, this.nominal});

  factory MPTransaksiVocuher.fromJson(dynamic json) {
    return MPTransaksiVocuher(
      id: json['id'],
      nominal: json['nominal'],
    );
  }
}

class MPTransaksiKurir {
  final String id;
  final String name;
  final String code;
  final String service;

  MPTransaksiKurir({this.id, this.name, this.code, this.service});

  factory MPTransaksiKurir.fromJson(dynamic json) {
    String id;
    String name;
    String code;

    if (json['id'] != null) {
      id = json['id']['_id'];
      name = json['id']['judul'];
      code = json['kode_kurir'];
    }

    return MPTransaksiKurir(
      id: id ?? '',
      name: name ?? '',
      code: code ?? 'cod',
      service: json['service'] ?? '',
    );
  }
}

class MPTransaksiShipping {
  final String name;
  final String phone;
  final String province;
  final String city;
  final String subdistrict;
  final String address;
  final String zipcode;

  MPTransaksiShipping(
      {this.name,
      this.phone,
      this.province,
      this.city,
      this.subdistrict,
      this.address,
      this.zipcode});

  factory MPTransaksiShipping.fromJson(dynamic json) {
    return MPTransaksiShipping(
        name: json['name'],
        phone: json['no_hp'],
        province: json['state']['province'],
        city: json['city']['city_name'],
        subdistrict: json['subdistrict']['subdistrict_name'],
        address: json['address'],
        zipcode: json['zipcode']);
  }
}

class MPTransaksiProduk {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final int weight;
  final int totalWeight;
  final int buyPrice;
  final int totalBuyPrice;
  final int sellPrice;
  final int totalSellPrice;
  final int quantity;

  MPTransaksiProduk(
      {this.id,
      this.productId,
      this.productName,
      this.productImage,
      this.weight,
      this.totalWeight,
      this.buyPrice,
      this.totalBuyPrice,
      this.sellPrice,
      this.totalSellPrice,
      this.quantity});

  factory MPTransaksiProduk.fromJson(dynamic json) {
    String productId;
    String productName;
    String productImage;

    if (json['product_id'] != null) {
      productId = json['product_id']['_id'];
      productName = json['product_id']['judul'];
      productImage = json['product_id']['thumbnail'];
    }

    return MPTransaksiProduk(
        id: json['_id'],
        productId: productId,
        productName: productName,
        productImage: productImage,
        weight: json['berat'],
        totalWeight: json['total_berat'],
        buyPrice: json['harga_beli'],
        totalBuyPrice: json['total_harga_beli'],
        sellPrice: json['harga_jual'],
        totalSellPrice: json['total_harga_jual'],
        quantity: json['qty']);
  }
}

class MPTransaksiStatus {
  final int code;
  final String label;
  final IconData icon;
  final MaterialColor color;

  MPTransaksiStatus({this.code, this.label, this.icon, this.color});

  factory MPTransaksiStatus.parse(int status) {
    switch (status) {
      case 1:
        return MPTransaksiStatus(
          code: status,
          label: 'Sedang diproses',
          icon: Icons.schedule,
          color: Colors.grey,
        );
        break;
      case 2:
        return MPTransaksiStatus(
          code: status,
          label: 'Dikirim',
          icon: Icons.local_shipping,
          color: Colors.red,
        );
        break;
      case 3:
        return MPTransaksiStatus(
          code: status,
          label: 'Diterima',
          icon: Icons.archive,
          color: Colors.orange,
        );
        break;
      case 4:
        return MPTransaksiStatus(
          code: status,
          label: 'Selesai',
          icon: Icons.check,
          color: Colors.green,
        );
        break;
      case 5:
        return MPTransaksiStatus(
          code: status,
          label: 'Dibatalkan',
          icon: Icons.close,
          color: Colors.red,
        );
        break;
      default:
        return MPTransaksiStatus(
          code: 0,
          label: 'Menunggu pembayaran',
          icon: Icons.account_balance_wallet,
          color: Colors.blue,
        );
    }
  }
}

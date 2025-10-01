
import 'package:flutter/material.dart';
import 'mutasi.dart';
import '../utils/debug_helper.dart';

class DepositModel {
  late int nominal;
  late MutasiModel? mutasi;
  late String created_at;
  late String expired_at;
  late String id;
  late int status;
  late int type;
  late int paymentId;
  late int? admin;
  late String kodePembayaran;
  late String nama;
  late String vaname;
  late String keterangan;
  late String url_payment;
  late DepositStatus statusModel;

  DepositModel(
      {required this.id,
      required this.nominal,
      this.mutasi,
      required this.status,
      required this.created_at,
      required this.expired_at,
      required this.type,
      required this.paymentId,
      this.admin,
      required this.kodePembayaran,
      required this.nama,
      required this.vaname,
      required this.keterangan,
      required this.url_payment,
      required this.statusModel}) {
    DebugHelper.debugPrint('🔍 [DEPOSIT MODEL] DepositModel constructor called');
    DebugHelper.debugPrint('🔍 [DEPOSIT MODEL] ID: $id, Nominal: $nominal, Status: $status');
    DebugHelper.debugPrint('🔍 [DEPOSIT MODEL] Created at: $created_at, Expired at: $expired_at');
    DebugHelper.debugPrint('🔍 [DEPOSIT MODEL] Type: $type, Payment ID: $paymentId');
    DebugHelper.debugPrint('🔍 [DEPOSIT MODEL] Customer name: $nama, VA name: $vaname');
  }

  DepositModel.fromJson(Map<String, dynamic> json) {
    DebugHelper.debugPrint('🔍 [DEPOSIT MODEL] fromJson called with FULL JSON PAYLOAD:');
    DebugHelper.debugPrint('🔍 [DEPOSIT MODEL] $json');
    
    id = json['_id'] ?? '';
    nominal = json['nominal'] ?? 0;
    status = json['status'] ?? 3;
    mutasi = json['mutasi_id'] != null
        ? MutasiModel.fromJson(json['mutasi_id'] as Map<String, dynamic>)
        : null;
    created_at = json['created_at'] ?? '';
    expired_at = json['expired_at'] ?? '';
    type = json['type'] ?? 0;
    paymentId = json['payment_id'] ?? 0;
    admin = json['admin'];
    kodePembayaran = json['kode_pembayaran'] ?? '';
    nama = json['nama_customer'] ?? '';
    vaname = json['vaname'] ?? '';
    keterangan = json['keterangan'] ?? '';
    url_payment = json['url_payment'] ?? '';

    DebugHelper.debugPrint('🔍 [DEPOSIT MODEL] Parsed values - ID: $id, Nominal: $nominal, Status: $status');
    DebugHelper.debugPrint('🔍 [DEPOSIT MODEL] Created: $created_at, Expired: $expired_at');
    DebugHelper.debugPrint('🔍 [DEPOSIT MODEL] Customer: $nama, VA: $vaname, Payment code: $kodePembayaran');

    statusModel = DepositStatus.parsing(json['status'] ?? 3);
    DebugHelper.debugPrint('🔍 [DEPOSIT MODEL] Status model created: ${statusModel.statusText}');
  }
}

class DepositBank {}

class DepositStatus {
  int status;
  Color color;
  String statusText;
  String icon;

  DepositStatus({required this.status, required this.color, required this.statusText, required this.icon}) {
    DebugHelper.debugPrint('🔍 [DEPOSIT STATUS] DepositStatus constructor called');
    DebugHelper.debugPrint('🔍 [DEPOSIT STATUS] Status: $status, Text: $statusText, Color: $color, Icon: $icon');
  }

  factory DepositStatus.parsing(int st) {
    DebugHelper.debugPrint('🔍 [DEPOSIT STATUS] Parsing status: $st');

    if (st == 0) {
      DebugHelper.debugPrint('🔍 [DEPOSIT STATUS] Status set to PENDING');
      return DepositStatus(
        status: st,
        statusText: 'Pending',
        color: const Color(0XFF253536),
        icon: 'assets/depositPending.PNG',
      );
    } else if (st == 1) {
      DebugHelper.debugPrint('🔍 [DEPOSIT STATUS] Status set to SUCCESS');
      return DepositStatus(
        status: st,
        statusText: 'Sukses',
        color: const Color(0XFF007C21),
        icon: 'assets/depositBerhasil.PNG',
      );
    } else {
      DebugHelper.debugPrint('🔍 [DEPOSIT STATUS] Status set to FAILED');
      return DepositStatus(
        status: st,
        statusText: 'Gagal',
        color: const Color(0XFFA70C00),
        icon: 'assets/depositGagal.PNG',
      );
    }
  }
}

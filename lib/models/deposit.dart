// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/models/mutasi.dart';
import 'package:mobile/utils/debug_helper.dart';

class DepositModel {
  int nominal;
  MutasiModel mutasi;
  String created_at;
  String expired_at;
  String id;
  int status;
  int type;
  int paymentId;
  int admin;
  String kodePembayaran;
  String nama;
  String vaname;
  String keterangan;
  String url_payment;
  DepositStatus statusModel;

  DepositModel(
      {this.id,
      this.nominal,
      this.mutasi,
      this.status,
      this.created_at,
      this.expired_at,
      this.type,
      this.paymentId,
      this.admin,
      this.kodePembayaran,
      this.nama,
      this.vaname,
      this.keterangan,
      this.statusModel}) {
    DebugHelper.debugPrint('🔍 [DEPOSIT MODEL] DepositModel constructor called');
    DebugHelper.debugPrint('🔍 [DEPOSIT MODEL] ID: $id, Nominal: $nominal, Status: $status');
    DebugHelper.debugPrint('🔍 [DEPOSIT MODEL] Created at: $created_at, Expired at: $expired_at');
    DebugHelper.debugPrint('🔍 [DEPOSIT MODEL] Type: $type, Payment ID: $paymentId');
    DebugHelper.debugPrint('🔍 [DEPOSIT MODEL] Customer name: $nama, VA name: $vaname');
  }

  DepositModel.fromJson(Map<String, dynamic> json) {
    DebugHelper.debugPrint('🔍 [DEPOSIT MODEL] fromJson called with FULL JSON PAYLOAD:');
    DebugHelper.debugPrint('🔍 [DEPOSIT MODEL] ${json.toString()}');
    
    id = json['_id'];
    nominal = json['nominal'] ?? 0;
    status = json['status'] ?? 3;
    mutasi = json['mutasi_id'] != null
        ? MutasiModel.fromJson(json['mutasi_id'])
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

  DepositStatus({this.status, this.color, this.statusText, this.icon}) {
    DebugHelper.debugPrint('🔍 [DEPOSIT STATUS] DepositStatus constructor called');
    DebugHelper.debugPrint('🔍 [DEPOSIT STATUS] Status: $status, Text: $statusText, Color: $color, Icon: $icon');
  }

  DepositStatus.parsing(int st) {
    DebugHelper.debugPrint('🔍 [DEPOSIT STATUS] Parsing status: $st');
    
    if (st == 0) {
      statusText = 'Pending';
      color = Color(0XFF253536);
      status = st;
      icon = 'assets/depositPending.PNG';
      DebugHelper.debugPrint('🔍 [DEPOSIT STATUS] Status set to PENDING');
    } else if (st == 1) {
      statusText = 'Sukses';
      color = Color(0XFF007C21);
      status = st;
      icon = 'assets/depositBerhasil.PNG';
      DebugHelper.debugPrint('🔍 [DEPOSIT STATUS] Status set to SUCCESS');
    } else {
      statusText = 'Gagal';
      color = Color(0XFFA70C00);
      status = st;
      icon = 'assets/depositGagal.PNG';
      DebugHelper.debugPrint('🔍 [DEPOSIT STATUS] Status set to FAILED');
    }
    
    DebugHelper.debugPrint('🔍 [DEPOSIT STATUS] Final status - Text: $statusText, Color: $color, Icon: $icon');
  }
}

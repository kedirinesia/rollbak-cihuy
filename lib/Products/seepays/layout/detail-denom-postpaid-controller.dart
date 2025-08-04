// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/Products/seepays/layout/detail-denom-postpaid.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Bloc.dart' show bloc;
import 'package:mobile/bloc/Api.dart' show apiUrl;
import 'package:package_info_plus/package_info_plus.dart';

abstract class SeepaysDetailDenomPostpaidController extends State<SeepaysDetailDenomPostpaid>
    with TickerProviderStateMixin {
  List<dynamic> listDenom = [];
  String menuLogo = '';
  bool loading = true;
  bool failed = false;
  dynamic selectedDenom;
  TextEditingController tujuan = TextEditingController();
  String packageName = '';

  @override
  void initState() {
    super.initState();
    _getPackageName();
    analitycs.pageView('/menu/transaksi/' + widget.menu.kodeProduk, {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Buka Menu ' + widget.menu.name
    });
    getData();
  }

  Future<void> _getPackageName() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      packageName = info.packageName;
    });
  }

  getData() async {
    http.Response response = await http.get(
        Uri.parse('$apiUrl/product/${widget.menu.kodeProduk}'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<dynamic> lm = (jsonDecode(response.body)['data'] as List);

      // SET MENU LOGO
      menuLogo = json.decode(response.body)['url_image'] ?? '';

      setState(() {
        listDenom = lm;
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
        listDenom = [];
      });
    }
  }

  onTapDenom(denom) {
    if (denom['note'] == 'gangguan') {
      ScaffoldMessenger.of(context).showSnackBar(
        Alert(
          'Produk sedang mengalami gangguan',
          isError: true,
        ),
      );
      return;
    }
    if (denom != null) {
      setState(() {
        selectedDenom = denom;
      });
    }
  }

  inquiryPostpaid(String kodeProduk, String tujuan) async {
    setState(() {
      loading = true;
    });

    try {
      http.Response response = await http.post(
        Uri.parse('$apiUrl/trx/postpaid/inquiry'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bloc.token.valueWrapper?.value,
        },
        body: json.encode({
          'kode_produk': kodeProduk,
          'tujuan': tujuan,
          'counter': 1,
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body)['data'];
        setState(() {
          selectedDenom = data;
          loading = false;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tagihan berhasil ditemukan'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        String message = json.decode(response.body)['message'] ?? 
            'Terjadi kesalahan saat mengambil data tagihan';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        loading = false;
      });
    }
  }
} 
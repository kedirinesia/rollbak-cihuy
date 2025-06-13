// @dart=2.9

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/alert.dart';
import 'dart:convert';

import 'package:mobile/models/count_trx.dart';
import 'package:mobile/modules.dart';

class Count extends StatefulWidget {
  const Count({key}) : super(key: key);

  @override
  _CountState createState() => _CountState();
}

class _CountState extends State<Count> {
  DateTime selectedStartDate;
  DateTime selectedEndDate;

  CountTrx countTrx;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectDateRange(context);
    });
  }

  Future<void> selectDateRange(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime pickedStartDate = await showDatePicker(
      context: context,
      initialDate: selectedStartDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
    );

    if (pickedStartDate != null && pickedStartDate != selectedStartDate)
      setState(() {
        selectedStartDate = pickedStartDate;
      });

    final DateTime pickedEndDate = await showDatePicker(
      context: context,
      initialDate: selectedEndDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
    );

    if (pickedEndDate != null && pickedEndDate != selectedEndDate)
      setState(() {
        selectedEndDate = pickedEndDate;
      });

    if (selectedStartDate != null && selectedEndDate != null) {
      getCountTrx();
    }
  }

  String formatDate(DateTime date) {
    return '${date.day}-${date.month}-${date.year}';
  }

  Future<void> getCountTrx() async {
    final String url =
        '$apiUrl/trx/countTransaction?tgl_awal=${formatDate(selectedStartDate)}&tgl_akhir=${formatDate(selectedEndDate)}';

    http.Response response = await http.get(Uri.parse(url), headers: {
      'Authorization': bloc.token.valueWrapper?.value,
    });
    CountTrx trxData = CountTrx.fromJson(json.decode(response.body)['data']);
    bloc.todayTrxCount.add(trxData);
    print(response.body);

    if (response.statusCode == 200) {
      setState(() {
        countTrx = CountTrx.fromJson(json.decode(response.body)['data']);
      });
    } else {
      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan saat mengambil data';
      ScaffoldMessenger.of(context).showSnackBar(Alert(
        message,
        isError: true,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Jumlah Transaksi: ${countTrx?.totalTrx ?? ''}'),
          Text('Transaksi Sukses: ${countTrx?.totalTrxSuccess ?? ''}'),
          Text('Transaksi Gagal: ${countTrx?.totalTrxGagal ?? ''}'),
          Text('Transaksi Pending: ${countTrx?.totalTrxPending ?? ''}'),
          Text(
              'Total Transaksi: ${formatRupiah(countTrx?.totalVolumeTrx ?? '')}'),
        ],
      ),
    );
  }
}

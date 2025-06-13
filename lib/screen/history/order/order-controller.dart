// @dart=2.9

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/models/mp_transaction.dart';
import 'dart:convert';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screen/history/order.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import '../../../bloc/Bloc.dart' show bloc;
import '../../../bloc/Api.dart' show apiUrl;

abstract class OrderController extends State<HistoryOrderPage> {
  bool loadingNewPage = false;
  bool loading = true;
  bool isEdge = false;
  int currentPage = 0;
  DateTime startDate;
  DateTime endDate;
  int status;
  String tujuan;
  bool isExpanded = false;
  bool filtered = false;

  List<MPTransaksi> listTransaksi = [];
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  TextEditingController startDateText = TextEditingController();
  TextEditingController endDateText = TextEditingController();

  final List<DropdownMenuItem> statusList = [
    DropdownMenuItem(child: Text('Menunggu Pembayaran'), value: 0),
    DropdownMenuItem(child: Text('Di Proses'), value: 1),
    DropdownMenuItem(child: Text('Dikirim'), value: 2),
    DropdownMenuItem(child: Text('Sudah Sampai'), value: 3),
    DropdownMenuItem(child: Text('Selesai'), value: 4),
    DropdownMenuItem(child: Text('Refund'), value: 5),
    DropdownMenuItem(child: Text('Semua Status'), value: 6),
  ];

  @override
  void initState() {
    super.initState();
    analitycs.pageView('/history/orders', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'History Order Marketplace'
    });
    if (configAppBloc.autoReload.valueWrapper?.value) {
      Timer.periodic(new Duration(seconds: 1), (timer) => getData());
    } else {
      getData();
    }
    startDate = getCurrentDate();
    endDate = getCurrentDate();
    startDateText.text = formatDate(startDate.toIso8601String(), 'd MMM y');
    endDateText.text = formatDate(endDate.toIso8601String(), 'd MMM y');
  }

  @override
  void dispose() {
    startDateText.dispose();
    endDateText.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    Map<String, dynamic> params = {};
    if (filtered) {
      params['tgl_awal'] = formatDate(startDate.toIso8601String(), 'd-M-y');
      params['tgl_akhir'] = formatDate(endDate.toIso8601String(), 'd-M-y');
      if (status != null && status != 6) params['status'] = status.toString();
    }
    params['page'] = currentPage;

    List<String> listOfParams = [];
    params.forEach((key, value) {
      listOfParams.add('$key=$value');
    });
    String parameters = listOfParams.join('&');
    String url = '$apiUrl/market/order/list?$parameters';

    print(url);
    print(bloc.token.valueWrapper?.value);

    // if (isEdge) return;
    http.Response response = await http.get(Uri.parse(url),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      print(response.body);
      List<dynamic> datas = json.decode(response.body)['data'];
      if (datas.length == 0) isEdge = true;
      listTransaksi.addAll(datas.map((e) => MPTransaksi.fromJson(e)).toList());
      currentPage++;
    } else {
      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan saat mengambil data';
      ScaffoldMessenger.of(context).showSnackBar(Alert(
        message,
        isError: true,
      ));
    }

    if (this.mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  void resetFilter() {
    setState(() {
      filtered = false;
      currentPage = 0;
      isEdge = false;
      listTransaksi.clear();
      loading = true;
      startDate = getCurrentDate();
      endDate = getCurrentDate();
      startDateText.text = formatDate(startDate.toIso8601String(), 'd MMM y');
      endDateText.text = formatDate(endDate.toIso8601String(), 'd MMM y');
      status = null;

      isExpanded = false;
    });

    getData();
  }

  void setFilter() async {
    setState(() {
      filtered = true;
      isExpanded = false;
      currentPage = 0;
      listTransaksi.clear();
      isEdge = false;
      loading = true;
    });

    getData();
  }

  Future<void> setStartDate() async {
    DateTime newDate = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(1970, 1, 1),
      lastDate: getCurrentDate(),
      currentDate: getCurrentDate(),
      locale: Locale('id'),
      confirmText: 'PILIH',
      cancelText: 'BATAL',
      helpText: 'Tanggal Awal',
    );

    if (newDate == null) return;
    setState(() {
      startDate = newDate;
      startDateText.text = formatDate(startDate.toIso8601String(), 'd MMM y');
    });
  }

  Future<void> setEndDate() async {
    DateTime newDate = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: startDate,
      lastDate: getCurrentDate(),
      currentDate: getCurrentDate(),
      locale: Locale('id'),
      confirmText: 'PILIH',
      cancelText: 'BATAL',
      helpText: 'Tanggal Akhir',
    );

    if (newDate == null) return;
    setState(() {
      endDate = newDate;
      endDateText.text = formatDate(endDate.toIso8601String(), 'd MMM y');
    });
  }
}

// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/count_trx.dart';
import 'package:mobile/models/trx.dart';
import 'package:mobile/modules.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screen/transaksi/detail_transaksi.dart';
import 'package:nav/nav.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class ReportPage extends StatefulWidget {
  // const ReportPage({super.key});
  const ReportPage({key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  int _currentPage = 0;
  bool _isLoading = true;
  bool _isEdge = false;

  List<TrxModel> _trxs = [];
  CountTrx _countTrx;

  String _searchTujuan = '';
  DateTime _startDate;
  DateTime _endDate;
  int _selectedDateFilter = 0;
  List<String> _dateFilters = [
    'Semua',
    'Bulan lalu',
    'Bulan ini',
    'Hari ini',
    'Minggu ini',
  ];
  int _selectedStatus = 999;
  Map<dynamic, String> _statuses = {
    999: 'Semua',
    2: 'Sukses',
    3: 'Gagal',
    1: 'Pending',
  };

  @override
  void initState() {
    _getData();
    _getTrxCount();
    super.initState();
  }

  Future<void> _getData({reset = false}) async {
    try {
      if (!reset && _isEdge) return;

      if (reset) {
        _currentPage = 0;
        _isEdge = false;
        _trxs.clear();
      }

      Map<String, dynamic> params = {
        'page': _currentPage,
      };

      if (_startDate != null) {
        params['tgl_awal'] =
            formatDate(_startDate.toIso8601String(), 'dd-MM-yyyy');
      }
      if (_endDate != null) {
        params['tgl_akhir'] =
            formatDate(_endDate.toIso8601String(), 'dd-MM-yyyy');
      }
      if (_searchTujuan.trim().isNotEmpty) {
        params['tujuan'] = _searchTujuan.trim();
      }
      if (_selectedStatus != 999) {
        params['status'] = _selectedStatus;
      }

      List<String> paramsArr = [];
      params.forEach((key, value) => paramsArr.add('$key=$value'));
      String strParams = paramsArr.join('&');
      String url = '$apiUrl/trx/list?$strParams';
      print(url);

      http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': bloc.token.valueWrapper?.value ?? '',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> datas = json.decode(response.body)['data'];
        if (datas.isEmpty) _isEdge = true;
        _trxs.addAll(datas.map((e) => TrxModel.fromJson(e)));
        _trxs.sort((a, b) {
          try {
            DateTime dateTimeA = DateTime.parse(a.created_at);
            DateTime dateTimeB = DateTime.parse(b.created_at);
            return dateTimeB.compareTo(dateTimeA);
          } catch (e) {
            print('Error while parsing date: $e');
            return 0;
          }
        });
        _currentPage++;
      } else {
        String message = json.decode(response.body)['message'] ??
            'Terjadi kesalahan saat mengambil data';
        ScaffoldMessenger.of(context).showSnackBar(
          Alert(
            message,
            isError: true,
          ),
        );
      }
    } catch (e) {
      print('ERROR GET TRX LIST: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getTrxCount() async {
    try {
      String startDate = 'all';
      String endDate = 'all';

      if (_startDate != null) {
        startDate = formatDate(_startDate.toIso8601String(), 'dd-MM-yyyy');
      }
      if (_endDate != null) {
        endDate = formatDate(_endDate.toIso8601String(), 'dd-MM-yyyy');
      }

      http.Response response = await http.get(
        Uri.parse(
            '$apiUrl/trx/countTransaction?tgl_awal=$startDate&tgl_akhir=$endDate'),
        headers: {
          'Authorization': bloc.token.valueWrapper?.value ?? '',
        },
      );

      if (response.statusCode == 200) {
        CountTrx trxData =
            CountTrx.fromJson(json.decode(response.body)['data']);
        bloc.allTrxCount.add(trxData);

        setState(() {
          _countTrx = trxData;
        });
      } else {
        String message = json.decode(response.body)['message'] ??
            'Terjadi kesalahan saat mengambil data';
        ScaffoldMessenger.of(context).showSnackBar(
          Alert(
            message,
            isError: true,
          ),
        );
      }
    } catch (e) {
      print('ERROR GET TRX COUNT: $e');
    }
  }

  void _changeDateFilter(int type) {
    DateTime now = DateTime.now();

    switch (type) {
      case 0:
        _startDate = null;
        _endDate = null;
        break;
      case 1:
        _startDate = DateTime(now.year, now.month - 1, 1);
        _endDate = DateTime(now.year, now.month, 0);
        break;
      case 2:
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 3:
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 4:
        _startDate = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        _endDate = _startDate.add(Duration(days: 7));
        break;
      default:
        _startDate = null;
        _endDate = null;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan Transaksi'),
        backgroundColor: packageName == 'com.lariz.mobile'
            ? Theme.of(context).secondaryHeaderColor
            : Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 58,
            child: ListView.separated(
              padding: EdgeInsets.all(15),
              scrollDirection: Axis.horizontal,
              itemCount: _dateFilters.length,
              separatorBuilder: (_, __) => SizedBox(width: 10),
              itemBuilder: (_, i) {
                bool selected = _selectedDateFilter == i;
                Color fgColor = selected ? Colors.white : Colors.grey.shade600;
                Color bgColor = selected
                    ? packageName == 'com.lariz.mobile'
                        ? Theme.of(context).secondaryHeaderColor
                        : Theme.of(context).primaryColor
                    : Colors.grey.shade200;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDateFilter = i;
                      _isLoading = true;
                    });

                    _changeDateFilter(i);
                    _getTrxCount();
                    _getData(reset: true);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Text(
                      _dateFilters[i],
                      style: TextStyle(
                        color: fgColor,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            margin: EdgeInsets.all(15).copyWith(top: 0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(.25),
                  offset: Offset(3, 3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            formatNumber(_countTrx?.totalTrx ?? 0),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Total Transaksi',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: .8,
                      height: 40,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            formatNumber(_countTrx?.totalTrxSuccess ?? 0),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Total Transaksi Sukses',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(),
                SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      'Total Pembelian',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        formatRupiah(_countTrx?.totalVolumeTrx ?? 0),
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    height: 40,
                    child: TextField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                        labelText: 'Cari Transaksi',
                        labelStyle: TextStyle(
                          color: Colors.black.withOpacity(.5),
                        ),
                        hintText: 'Nomor Tujuan',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                          ),
                        ),
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          _searchTujuan = value.trim();
                          _isLoading = true;
                        });

                        _getTrxCount();
                        _getData(reset: true);
                      },
                    ),
                  ),
                ),
                SizedBox(width: 5),
                SizedBox(
                  height: 40,
                  child: FittedBox(
                    fit: BoxFit.fitHeight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.all(10),
                        backgroundColor: Colors.grey.shade100,
                        side: BorderSide(
                          color: Colors.grey.shade200,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: () async {
                        int status = await showDialog(
                            context: context,
                            builder: (ctx) {
                              return SimpleDialog(
                                title: Text('Filter Status'),
                                children: _statuses.keys.map((status) {
                                  return SimpleDialogOption(
                                    child: Text(_statuses[status]),
                                    onPressed: () =>
                                        Navigator.of(ctx, rootNavigator: true)
                                            .pop(status),
                                  );
                                }).toList(),
                              );
                            });

                        if (status == null) return;

                        setState(() {
                          _selectedStatus = status;
                          _isLoading = true;
                        });

                        await _getData(reset: true);
                        await _getTrxCount();
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.filter_list_rounded,
                            size: 18,
                            color: Colors.black,
                          ),
                          Text(
                            _statuses[_selectedStatus],
                            style: TextStyle(fontSize: 10, color: Colors.black),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          Expanded(
            child: _isLoading
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: EdgeInsets.all(15),
                    child: Center(
                      child: SpinKitThreeBounce(
                        color: packageName == 'com.lariz.mobile'
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).primaryColor,
                        size: 30,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      _trxs.isEmpty
                          ? Expanded(
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/img/empty.svg',
                                    width:
                                        MediaQuery.of(context).size.width * .35,
                                  ),
                                ),
                              ),
                            )
                          : Expanded(
                              child: SmartRefresher(
                                controller: refreshController,
                                enablePullUp: true,
                                enablePullDown: true,
                                onRefresh: () async {
                                  await _getData(reset: true);
                                  await _getTrxCount();
                                  refreshController.refreshCompleted();
                                },
                                onLoading: () async {
                                  print("Before increment: $_currentPage");
                                  _currentPage += 1;
                                  print("After increment: $_currentPage");
                                  await _getData(reset: false);
                                  refreshController.loadComplete();
                                },
                                child: GroupedListView<dynamic, String>(
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  elements: _trxs,
                                  sort: false,
                                  groupBy: (element) {
                                    DateTime dateTime =
                                        DateTime.parse(element.created_at);
                                    return formatDate(
                                        dateTime.toIso8601String(),
                                        'dd MMMM yyyy');
                                  },
                                  groupSeparatorBuilder:
                                      (String groupByValue) => Container(
                                    decoration: BoxDecoration(
                                      color: packageName == 'com.lariz.mobile'
                                          ? Theme.of(context)
                                              .secondaryHeaderColor
                                              .withOpacity(.3)
                                          : Theme.of(context)
                                              .primaryColor
                                              .withOpacity(.3),
                                    ),
                                    width: double.infinity,
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Row(
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 10),
                                                  child: Text(
                                                    groupByValue,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  itemBuilder: (context, element) {
                                    var trx = element as TrxModel;
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: BorderDirectional(
                                          bottom: BorderSide(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                      ),
                                      child: ListTile(
                                        onTap: () =>
                                            Nav.push(DetailTransaksi(trx)),
                                        leading: CircleAvatar(
                                          foregroundColor: packageName ==
                                                  'com.lariz.mobile'
                                              ? Theme.of(context)
                                                  .secondaryHeaderColor
                                              : Theme.of(context).primaryColor,
                                          backgroundColor: trx.statusModel.color
                                              .withOpacity(.1),
                                          child: CachedNetworkImage(
                                            imageUrl: trx.statusModel.icon,
                                            width: 20,
                                          ),
                                        ),
                                        title: Text(
                                          trx.tujuan,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        subtitle: Text(
                                          trx.produk == null
                                              ? '-'
                                              : trx.produk['nama'],
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        trailing: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Hero(
                                              tag: 'harga-${trx.id}',
                                              child: Text(
                                                formatRupiah(trx.harga_jual),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              trx.statusModel.statusText,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: trx.statusModel.color,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  useStickyGroupSeparators: true,
                                  floatingHeader: true,
                                ),
                              ),
                            ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

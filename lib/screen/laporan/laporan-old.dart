// @dart=2.9

import 'dart:async';
import 'dart:ffi';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/models/count_trx.dart';
import 'package:mobile/models/trx.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/modules.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/laporan/history_trx.dart';
import 'package:mobile/screen/transaksi/detail_transaksi.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:rxdart/rxdart.dart';

class MyNewPage extends StatefulWidget {
  const MyNewPage({key}) : super(key: key);
  @override
  _MyNewPageState createState() => _MyNewPageState();
}

class _MyNewPageState extends State<MyNewPage> {
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  DateTime startDate;
  DateTime endDate;
  int status;
  int currentPage = 0;
  String tujuan;
  bool isEdge = false;
  bool loading = true;
  bool isExpanded = false;
  bool filtered = false;
  bool isInSearchMode = false;
  List<TrxModel> listTrx = [];
  List<TrxModel> searchResult = [];
  List<TrxModel> filteredTrx = [];
  TextEditingController searchQuery = TextEditingController();
  int selectedButton = 0;
  String dropdownValue = 'Terbaru';
  String selectedStatus;
  int selectedFilterDay;
  CountTrx countTrx;

  @override
  void initState() {
    super.initState();
    init();
    filteredTrx = listTrx;
  }

  @override
  void dispose() {
    searchQuery.dispose();
    super.dispose();
  }

  void init() {
    analitycs.pageView(
      '/history/transaksi',
      {
        'userId': bloc.userId.valueWrapper?.value,
        'title': 'History Transaksi',
      },
    );

    startDate = getCurrentDate();
    endDate = getCurrentDate();
    getData();
    getCountTrx();
    // getCountTrx(isToday: false);
  }

  Future<void> getCountTrx(
      {String tglAwal = 'all', String tglAkhir = 'all'}) async {
    String url =
        '$apiUrl/trx/countTransaction?tgl_awal=$tglAwal&tgl_akhir=$tglAkhir';

    http.Response response = await http.get(Uri.parse(url), headers: {
      'Authorization': bloc.token.valueWrapper?.value,
    });
    CountTrx trxData = CountTrx.fromJson(json.decode(response.body)['data']);
    bloc.allTrxCount.add(trxData);
    print("DISINI!");
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
    setState(() {
      loading = false;
    });
  }

  Future<void> getData({String tujuanSearch}) async {
    Map<String, dynamic> params = {};
    if (filtered) {
      params['tgl_akhir'] = formatDate(endDate.toIso8601String(), 'd-M-y');
      params['tgl_awal'] = formatDate(startDate.toIso8601String(), 'd-M-y');
      if (status != null && status != 4) params['status'] = status.toString();
      if (tujuan != null && tujuan.isNotEmpty) params['tujuan'] = tujuan;
    }

    if (tujuanSearch != null && tujuanSearch.isNotEmpty) {
      params['tujuan'] = tujuanSearch;
    }

    params['page'] = currentPage;

    List<String> listOfParams = [];
    params.forEach((key, value) {
      listOfParams.add('$key=$value');
    });
    String parameters = listOfParams.join('&');
    String url = '$apiUrl/trx/list?$parameters';
    print(url);

    http.Response response = await http.get(Uri.parse(url), headers: {
      'Authorization': bloc.token.valueWrapper?.value,
    });

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      // print("DATA TRX");
      // print(datas);
      if (datas.length == 0) isEdge = true;

      List<TrxModel> newTrx = datas.map((e) => TrxModel.fromJson(e)).toList();

      newTrx.sort((a, b) {
        try {
          DateTime dateTimeA = DateTime.parse(a.created_at);
          DateTime dateTimeB = DateTime.parse(b.created_at);
          return dateTimeB.compareTo(dateTimeA);
        } catch (e) {
          print('Error when parsing date: $e');
          return 0;
        }
      });

      print('sampai sini' + datas.toString());

      listTrx.addAll(newTrx);
      searchResult.addAll(newTrx);

      // print(newTrx.map((trx) => trx.created_at).toList());

      currentPage++;
    } else {
      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan saat mengambil data';
      ScaffoldMessenger.of(context).showSnackBar(Alert(
        message,
        isError: true,
      ));
    }
    // print(response.body);

    setState(() {
      loading = false;
    });
  }

  List<TrxModel> filterByDate(int filterType) {
    DateTime now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (filterType) {
      case 0: // Semua
        getCountTrx(tglAwal: 'all', tglAkhir: 'all');
        return listTrx;
      case 1: // Bulan lalu
        startDate = DateTime(now.year, now.month - 1, 1);
        endDate = DateTime(now.year, now.month, 0);
        break;
      case 2: // Bulan ini
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 3: // Hari ini
        startDate = DateTime(now.year, now.month, now.day);
        endDate =
            startDate.add(Duration(days: 1)).subtract(Duration(seconds: 1));
        break;
      case 4: // Minggu ini
        startDate = now.subtract(Duration(days: now.weekday - 1));
        endDate =
            startDate.add(Duration(days: 7)).subtract(Duration(seconds: 1));
        break;
    }

    getCountTrx(
        tglAwal: DateFormat('dd-MM-yyyy').format(startDate),
        tglAkhir: DateFormat('dd-MM-yyyy').format(endDate));

    return listTrx.where((trx) {
      DateTime trxDate = DateTime.parse(trx.created_at);
      return trxDate.isAfter(startDate) && trxDate.isBefore(endDate);
    }).toList();
  }

  List<TrxModel> filterTransactions() {
    List<TrxModel> transactions = isInSearchMode ? searchResult : filteredTrx;

    if (selectedStatus == null || selectedStatus == 'Semua') {
      return transactions;
    } else {
      return transactions
          .where((trx) => trx.statusModel.statusText == selectedStatus)
          .toList();
    }
  }

  bool shouldDisplayEmptyState() {
    if (isInSearchMode) {
      return searchResult.isEmpty;
    } else if (selectedStatus != null && selectedStatus != 'Semua') {
      return filterTransactions().isEmpty;
    }
    return filteredTrx.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan Transaksi'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              height: 40,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  vertical: 5,
                ),
                children: <Widget>[
                  for (var i = 0; i < 5; i++) ...[
                    InkWell(
                      onTap: () {
                        setState(() {
                          selectedFilterDay = i;
                          selectedButton = i;
                          filteredTrx = filterByDate(i);
                        });
                        currentPage = 0;
                        listTrx.clear();
                        searchResult.clear();
                        // filteredTrx.clear();
                        getData(tujuanSearch: searchQuery.text.trim());
                      },
                      child: Container(
                        height: 15,
                        decoration: BoxDecoration(
                          color: selectedButton == i
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade100,
                          border: Border.all(
                              color: selectedButton == i
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade200,
                              width: 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Center(
                          child: Text(
                            [
                              'Semua',
                              'Bulan lalu',
                              'Bulan ini',
                              'Hari ini',
                              'Minggu ini'
                            ][i],
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: selectedButton == i
                                    ? Colors.white
                                    : Colors.grey.shade800),
                          ),
                        ),
                      ),
                    ),
                    if (i != 4) SizedBox(width: 10),
                  ]
                ],
              ),
            ),
          ),
          ListView(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.0),
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(.1),
                          offset: Offset(0, 0),
                          blurRadius: 5.0),
                    ]),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                bloc.allTrxCount.valueWrapper?.value != null
                                    ? formatNumber(bloc.allTrxCount.valueWrapper
                                        ?.value.totalTrx)
                                    : '',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                'Total Transaksi',
                                style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.black.withOpacity(.5)),
                              ),
                              Divider(color: Colors.black.withOpacity(.1)),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 20),
                          height: 35,
                          width: 0.6,
                          color: Colors.black.withOpacity(.1),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                bloc.allTrxCount.valueWrapper?.value != null
                                    ? formatNumber(bloc.allTrxCount.valueWrapper
                                        ?.value.totalTrxSuccess)
                                    : '',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                'Total Transaksi Sukses',
                                style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.black.withOpacity(.5)),
                              ),
                              Divider(color: Colors.black.withOpacity(.1)),
                            ],
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Total Pembelian",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          bloc.allTrxCount.valueWrapper?.value != null
                              ? formatRupiah(bloc.allTrxCount.valueWrapper
                                  ?.value.totalVolumeTrx)
                              : '',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    height: 40,
                    child: TextField(
                      controller: searchQuery,
                      onSubmitted: (value) {
                        setState(() {
                          filteredTrx = filterByDate(selectedFilterDay);
                        });
                        currentPage = 0;
                        listTrx.clear();
                        searchResult.clear();
                        getData(tujuanSearch: value);
                      },
                      // onChanged: (value) {
                      //   print("Search field value: $value");
                      //   if (value.isNotEmpty) {
                      //     isInSearchMode = true;
                      //     searchResult = listTrx
                      //         .where((el) => el.tujuan.contains(value))
                      //         .toList();
                      //   } else {
                      //     isInSearchMode = false;
                      //   }
                      //   print("Is in search mode: $isInSearchMode");
                      //   print("Search results count: ${searchResult.length}");
                      //   setState(() {});
                      // },
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                          labelText: "Cari Transaksi",
                          labelStyle:
                              TextStyle(color: Colors.black.withOpacity(.5)),
                          hintText: "Nomor Tujuan",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200))),
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  flex: 1,
                  child: SizedBox(
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
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SimpleDialog(
                                  title: const Text('Filter'),
                                  children: <SimpleDialogOption>[
                                    SimpleDialogOption(
                                      child: const Text('Semua'),
                                      onPressed: () {
                                        setState(() {
                                          dropdownValue = 'Semua';
                                          selectedStatus = null;
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                                    SimpleDialogOption(
                                      child: const Text('Sukses'),
                                      onPressed: () {
                                        setState(() {
                                          dropdownValue = 'Sukses';
                                          selectedStatus = 'Sukses';
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                                    SimpleDialogOption(
                                      child: const Text('Gagal'),
                                      onPressed: () {
                                        setState(() {
                                          dropdownValue = 'Gagal';
                                          selectedStatus = 'Gagal';
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                                    SimpleDialogOption(
                                      child: const Text('Pending'),
                                      onPressed: () {
                                        setState(() {
                                          dropdownValue = 'Pending';
                                          selectedStatus = 'Pending';
                                        });
                                        print('Anjog Mene');
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              });
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
                              'Filter',
                              style:
                                  TextStyle(fontSize: 10, color: Colors.black),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: EdgeInsets.all(15),
                    child: Center(
                      child: SpinKitThreeBounce(
                        color: Theme.of(context).primaryColor,
                        size: 30,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      shouldDisplayEmptyState()
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
                                  currentPage = 0;
                                  isEdge = false;
                                  listTrx.clear();
                                  await getData();
                                  refreshController.refreshCompleted();
                                },
                                onLoading: () async {
                                  await getData();
                                  refreshController.loadComplete();
                                },
                                child: GroupedListView<dynamic, String>(
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  elements: isInSearchMode
                                      ? searchResult
                                      : filterTransactions(),
                                  sort: false,
                                  groupBy: (element) {
                                    DateTime dateTime =
                                        DateTime.parse(element.created_at);
                                    return DateFormat('dd MMMM yyyy')
                                        .format(dateTime);
                                  },
                                  groupSeparatorBuilder:
                                      (String groupByValue) => Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
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
                                                  margin: EdgeInsets.only(
                                                      left: 10, right: 10),
                                                  child: Text(
                                                    groupByValue,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
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
                                                  color:
                                                      Colors.grey.shade200))),
                                      child: ListTile(
                                        onTap: () {
                                          return Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  DetailTransaksi(trx),
                                            ),
                                          );
                                        },
                                        leading: CircleAvatar(
                                          foregroundColor:
                                              Theme.of(context).primaryColor,
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
                            )
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

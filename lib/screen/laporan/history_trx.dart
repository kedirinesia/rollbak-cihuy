// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/models/trx.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/transaksi/detail_transaksi.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:grouped_list/grouped_list.dart';

class HistoryTrx extends StatefulWidget {
  const HistoryTrx({key}) : super(key: key);

  @override
  _HistoryTrxState createState() => _HistoryTrxState();
}

class _HistoryTrxState extends State<HistoryTrx> {
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  TextEditingController startDateText = TextEditingController();
  TextEditingController endDateText = TextEditingController();
  TextEditingController tujuanText = TextEditingController();
  final List<DropdownMenuItem> statusList = [
    DropdownMenuItem(child: Text('Pending'), value: 0),
    DropdownMenuItem(child: Text('Sukses'), value: 2),
    DropdownMenuItem(child: Text('Gagal'), value: 3),
    DropdownMenuItem(child: Text('Semua Status'), value: 4),
  ];
  DateTime startDate;
  DateTime endDate;
  int status;
  int currentPage = 0;
  String tujuan;
  bool isEdge = false;
  bool loading = true;
  bool isExpanded = false;
  bool filtered = false;
  List<TrxModel> listTrx = [];
  Map<String, List<TrxModel>> groupedData = {};

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    startDateText.dispose();
    endDateText.dispose();
    tujuanText.dispose();
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
    startDateText.text = formatDate(startDate.toIso8601String(), 'd MMM y');
    endDateText.text = formatDate(endDate.toIso8601String(), 'd MMM y');
    getData();
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
    print(bloc.token.valueWrapper?.value);

    http.Response response = await http.get(Uri.parse(url), headers: {
      'Authorization': bloc.token.valueWrapper?.value,
    });

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
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

      listTrx.addAll(newTrx);

      print(newTrx.map((trx) => trx.created_at).toList());

      currentPage++;
    } else {
      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan saat mengambil data';
      ScaffoldMessenger.of(context).showSnackBar(Alert(
        message,
        isError: true,
      ));
    }
    print(response.body);

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
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
              listTrx.isNotEmpty
                  ? Expanded(
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
                          elements: listTrx,
                          sort: false,
                          groupBy: (element) {
                            DateTime dateTime =
                                DateTime.parse(element.created_at);
                            return DateFormat('dd MMMM yyyy').format(dateTime);
                          },
                          groupSeparatorBuilder: (String groupByValue) =>
                              Container(
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
                                                fontWeight: FontWeight.bold),
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
                                          color: Colors.grey.shade200))),
                              child: ListTile(
                                onTap: () {
                                  return Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => DetailTransaksi(trx),
                                    ),
                                  );
                                },
                                leading: CircleAvatar(
                                  foregroundColor:
                                      Theme.of(context).primaryColor,
                                  backgroundColor:
                                      trx.statusModel.color.withOpacity(.1),
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
                                  trx.produk == null ? '-' : trx.produk['nama'],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                          // order: GroupedListOrder.DESC,
                        ),
                      ),
                    )
                  : Expanded(
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/img/empty.svg',
                            width: MediaQuery.of(context).size.width * .35,
                          ),
                        ),
                      ),
                    ),
            ],
          );
  }
}

// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/trx.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/transaksi/detail_transaksi.dart';
import 'package:nav/nav.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class HistoryTransaksi extends StatefulWidget {
  const HistoryTransaksi({key}) : super(key: key);

  @override
  _HistoryTransaksiState createState() => _HistoryTransaksiState();
}

class _HistoryTransaksiState extends State<HistoryTransaksi> {
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
    // FIREBASE ANALYTICS
    analitycs.pageView(
      '/history/transaksi',
      {
        'userId': bloc.userId.valueWrapper?.value,
        'title': 'History Transaksi',
      },
    );
    // FIREBASE ANALYTICS

    startDate = getCurrentDate();
    endDate = getCurrentDate();
    startDateText.text = formatDate(startDate.toIso8601String(), 'd MMM y');
    endDateText.text = formatDate(endDate.toIso8601String(), 'd MMM y');
    getData();
  }

  Future<void> getData({reset = true}) async {
    try {
      if (!reset && isEdge) return;

      if (reset) {
        currentPage = 0;
        isEdge = false;
        listTrx.clear();
      }

      Map<String, dynamic> params = {};
      if (filtered) {
        params['tgl_akhir'] = formatDate(endDate.toIso8601String(), 'd-M-y');
        params['tgl_awal'] = formatDate(startDate.toIso8601String(), 'd-M-y');
        if (status != null && status != 4) params['status'] = status.toString();
        if (tujuan != null && tujuan.isNotEmpty) params['tujuan'] = tujuan;
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
        print(response.body);
        List<dynamic> datas = json.decode(response.body)['data'];
        if (datas.length == 0) isEdge = true;
        listTrx.addAll(datas.map((e) => TrxModel.fromJson(e)));
        listTrx.sort((a, b) {
          try {
            DateTime dateTimeA = DateTime.parse(a.created_at);
            DateTime dateTimeB = DateTime.parse(b.created_at);
            return dateTimeB.compareTo(dateTimeA);
          } catch (e) {
            print('Error while parsing date: $e');
            return 0;
          }
        });
        currentPage++;
      } else {
        String message = json.decode(response.body)['message'] ??
            'Terjadi kesalahan saat mengambil data';
        ScaffoldMessenger.of(context).showSnackBar(Alert(
          message,
          isError: true,
        ));
      }
    } catch (e) {
      print('ERROR GET TRX LIST: $e');
    } finally {
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
      listTrx.clear();
      loading = true;
      startDate = getCurrentDate();
      endDate = getCurrentDate();
      startDateText.text = formatDate(startDate.toIso8601String(), 'd MMM y');
      endDateText.text = formatDate(endDate.toIso8601String(), 'd MMM y');
      status = null;
      tujuan = null;
      tujuanText.clear();

      isExpanded = false;
    });

    getData();
  }

  void setFilter() {
    setState(() {
      filtered = true;
      tujuan = tujuanText.text;
      isExpanded = false;
      currentPage = 0;
      listTrx.clear();
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

  @override
  Widget build(BuildContext context) {
    return loading
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
              ExpansionPanelList(
                elevation: 0,
                children: [
                  ExpansionPanel(
                    headerBuilder: (_, expanded) => Container(
                      padding: EdgeInsets.all(15),
                      child: Text(
                        'Filter Transaksi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: packageName == 'com.lariz.mobile'
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    body: Container(
                      padding: EdgeInsets.all(10),
                      color: packageName == 'com.lariz.mobile'
                          ? Theme.of(context)
                              .secondaryHeaderColor
                              .withOpacity(.05)
                          : Theme.of(context).primaryColor.withOpacity(.05),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButtonFormField(
                            items: statusList,
                            value: status,
                            decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 15,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: packageName == 'com.lariz.mobile'
                                        ? Theme.of(context).secondaryHeaderColor
                                        : Theme.of(context).primaryColor,
                                    width: 1,
                                  ),
                                ),
                                hintText: 'Status Transaksi',
                                hintStyle: packageName == 'com.lariz.mobile'
                                    ? TextStyle(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor)
                                    : null),
                            onChanged: (val) => setState(() {
                              status = val;
                            }),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: startDateText,
                                  readOnly: true,
                                  textAlign: TextAlign.center,
                                  onTap: setStartDate,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 15,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: packageName == 'com.lariz.mobile'
                                            ? Theme.of(context)
                                                .secondaryHeaderColor
                                            : Theme.of(context).primaryColor,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                '  -  ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: endDateText,
                                  readOnly: true,
                                  textAlign: TextAlign.center,
                                  onTap: setEndDate,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 15,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: packageName == 'com.lariz.mobile'
                                            ? Theme.of(context)
                                                .secondaryHeaderColor
                                            : Theme.of(context).primaryColor,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: tujuanText,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 15,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: packageName == 'com.lariz.mobile'
                                        ? Theme.of(context).secondaryHeaderColor
                                        : Theme.of(context).primaryColor,
                                    width: 1,
                                  ),
                                ),
                                hintText: 'Nomor Tujuan',
                                hintStyle: packageName == 'com.lariz.mobile'
                                    ? TextStyle(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor)
                                    : null),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  child: Text(
                                    'ATUR ULANG',
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  onPressed: resetFilter,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  child: Text(
                                    'ATUR FILTER',
                                    style: TextStyle(
                                      color: packageName == 'com.lariz.mobile'
                                          ? Theme.of(context)
                                              .secondaryHeaderColor
                                          : Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: setFilter,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    isExpanded: isExpanded,
                    canTapOnHeader: true,
                  ),
                ],
                expansionCallback: (_, __) {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
              ),
              listTrx.isNotEmpty
                  ? Expanded(
                      child: SmartRefresher(
                          controller: refreshController,
                          enablePullUp: true,
                          enablePullDown: true,
                          onRefresh: () async {
                            await getData(reset: true);
                            refreshController.refreshCompleted();
                          },
                          onLoading: () async {
                            // currentPage += 1;
                            await getData(reset: false);
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
                              return formatDate(
                                  dateTime.toIso8601String(), 'dd MMM yyy');
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
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text(
                                              groupByValue,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
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
                                  onTap: () => Nav.push(DetailTransaksi(trx)),
                                  leading: CircleAvatar(
                                    foregroundColor:
                                        Theme.of(context).primaryColor,
                                    backgroundColor:
                                        trx.statusModel.color.withOpacity(.1),
                                    child: Image.network(trx.statusModel.icon,
                                        width: 20),
                                  ),
                                  title: Text(
                                    '${trx.produk['kode_produk']}.${trx.tujuan}',
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
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                            useStickyGroupSeparators: true,
                            floatingHeader: true,
                          )

                          // child: ListView.separated(
                          //   shrinkWrap: true,
                          //   physics: ScrollPhysics(),
                          //   padding: EdgeInsets.symmetric(vertical: 10),
                          //   itemCount: listTrx.length,
                          //   separatorBuilder: (_, __) => SizedBox(height: 10),
                          //   itemBuilder: (_, i) {
                          //     TrxModel trx = listTrx[i];

                          //     return Container(
                          //       margin: EdgeInsets.symmetric(horizontal: 10),
                          //       decoration: BoxDecoration(
                          //           color: Colors.white,
                          //           borderRadius: BorderRadius.circular(10),
                          //           boxShadow: [
                          //             BoxShadow(
                          //                 color: Colors.grey.withOpacity(.5),
                          //                 offset: Offset(3, 3),
                          //                 blurRadius: 15)
                          //           ]),
                          //       child: ListTile(
                          //         onTap: () {
                          //           return Navigator.of(context).push(
                          //             MaterialPageRoute(
                          //               builder: (_) => DetailTransaksi(trx),
                          //             ),
                          //           );
                          //         },

                          //         leading: CircleAvatar(
                          //           foregroundColor: packageName ==
                          //                   'com.lariz.mobile'
                          //               ? Theme.of(context).secondaryHeaderColor
                          //               : Theme.of(context).primaryColor,
                          //           backgroundColor:
                          //               trx.statusModel.color.withOpacity(.1),
                          //           child: CachedNetworkImage(
                          //             imageUrl: trx.statusModel.icon,
                          //             width: 20,
                          //           ),
                          //         ),
                          //         title: Text(
                          //           trx.tujuan,
                          //           style: TextStyle(
                          //             fontSize: 12,
                          //             fontWeight: FontWeight.bold,
                          //             color: Colors.grey.shade700,
                          //           ),
                          //         ),
                          //         subtitle: Text(
                          //           trx.produk == null ? '-' : trx.produk['nama'],
                          //           overflow: TextOverflow.ellipsis,
                          //           maxLines: 1,
                          //           style: TextStyle(
                          //             fontSize: 10.0,
                          //             color: Colors.grey.shade700,
                          //           ),
                          //         ),
                          //         trailing: Column(
                          //           crossAxisAlignment: CrossAxisAlignment.end,
                          //           mainAxisAlignment: MainAxisAlignment.center,
                          //           children: <Widget>[
                          //             Hero(
                          //               tag: 'harga-${trx.id}',
                          //               child: Text(
                          //                 formatRupiah(trx.harga_jual),
                          //                 style: TextStyle(
                          //                   fontWeight: FontWeight.bold,
                          //                   color: Colors.green,
                          //                   fontSize: 12,
                          //                 ),
                          //               ),
                          //             ),
                          //             SizedBox(height: 5),
                          //             Text(
                          //               trx.statusModel.statusText,
                          //               style: TextStyle(
                          //                 fontWeight: FontWeight.bold,
                          //                 color: trx.statusModel.color,
                          //                 fontSize: 10,
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //     );
                          //   },
                          // ),
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

// @dart=2.9

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/models/mutasi.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/transaksi/detail_mutasi.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:http/http.dart' as http;

class MutasiPage extends StatefulWidget {
  const MutasiPage({Key key}) : super(key: key);

  @override
  State<MutasiPage> createState() => _MutasiPageState();
}

class _MutasiPageState extends State<MutasiPage> {
  bool loadingNewPage = false;
  bool loading = true;
  bool isEdge = false;
  int currentPage = 0;
  DateTime startDate;
  DateTime endDate;
  String type;
  String tujuan;
  bool isExpanded = false;
  bool filtered = false;

  List<MutasiModel> listMutasi = [];
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  TextEditingController startDateText = TextEditingController();
  TextEditingController endDateText = TextEditingController();

  final List<DropdownMenuItem> typeList = [
    DropdownMenuItem(child: Text('Transaksi'), value: 'T'),
    DropdownMenuItem(child: Text('Deposit'), value: 'D'),
    DropdownMenuItem(child: Text('Transfer Saldo'), value: 'KS'),
    DropdownMenuItem(child: Text('Pemotongan Saldo'), value: 'P'),
    DropdownMenuItem(child: Text('Cashback'), value: 'C'),
    DropdownMenuItem(child: Text('Gagal'), value: 'G'),
    DropdownMenuItem(child: Text('Manual'), value: 'M'),
    DropdownMenuItem(child: Text('Semua Tipe'), value: 'ST'),
  ];

  @override
  void initState() {
    super.initState();
    analitycs.pageView('/history/mutasi',
        {'userId': bloc.userId.valueWrapper?.value, 'title': 'History Mutasi'});
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
      if (type != null && type != 'ST') params['type'] = type;
    }
    params['page'] = currentPage;

    List<String> listOfParams = [];
    params.forEach((key, value) {
      listOfParams.add('$key=$value');
    });
    String parameters = listOfParams.join('&');
    String url = '$apiUrl/mutasi/list?$parameters';

    print(url);

    if (isEdge) return;
    http.Response response = await http.get(Uri.parse(url),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<dynamic> list = jsonDecode(response.body)['data'] as List;
      if (list.length == 0) isEdge = true;
      list.forEach((item) => listMutasi.add(MutasiModel.fromJson(item)));
      currentPage++;
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
      listMutasi.clear();
      loading = true;
      startDate = getCurrentDate();
      endDate = getCurrentDate();
      startDateText.text = formatDate(startDate.toIso8601String(), 'd MMM y');
      endDateText.text = formatDate(endDate.toIso8601String(), 'd MMM y');
      type = null;
      tujuan = null;

      isExpanded = false;
    });

    getData();
  }

  void setFilter() async {
    setState(() {
      filtered = true;
      isExpanded = false;
      currentPage = 0;
      listMutasi.clear();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Mutasi'),
        centerTitle: true,
        elevation: 0,
      ),
      body: loading
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
                ExpansionPanelList(
                  elevation: 0,
                  children: [
                    ExpansionPanel(
                      headerBuilder: (_, expanded) => Container(
                        padding: EdgeInsets.all(15),
                        child: Text(
                          'Filter Mutasi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      body: Container(
                        padding: EdgeInsets.all(10),
                        color: Theme.of(context).primaryColor.withOpacity(.05),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DropdownButtonFormField(
                              items: typeList,
                              value: type,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 15,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 1,
                                  ),
                                ),
                                hintText: 'Tipe Mutasi',
                              ),
                              onChanged: (val) => setState(() {
                                type = val;
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
                                          color: Theme.of(context).primaryColor,
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
                                          color: Theme.of(context).primaryColor,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                                        color: Theme.of(context).primaryColor,
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
                listMutasi.isNotEmpty
                    ? Expanded(
                        child: SmartRefresher(
                          controller: refreshController,
                          enablePullUp: true,
                          enablePullDown: true,
                          onRefresh: () async {
                            currentPage = 0;
                            isEdge = false;
                            listMutasi.clear();
                            await getData();
                            refreshController.refreshCompleted();
                          },
                          onLoading: () async {
                            await getData();
                            refreshController.loadComplete();
                          },
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            padding: EdgeInsets.symmetric(vertical: 10),
                            itemCount: listMutasi.length,
                            separatorBuilder: (_, i) => SizedBox(height: 10),
                            itemBuilder: (_, int index) {
                              MutasiModel m = listMutasi[index];
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(.5),
                                          offset: Offset(3, 3),
                                          blurRadius: 15)
                                    ]),
                                child: ListTile(
                                  onTap: () {
                                    return Navigator.of(context).push(
                                        PageTransition(
                                            child: DetailMutasi(m),
                                            type:
                                                PageTransitionType.rippleMiddle,
                                            duration:
                                                Duration(milliseconds: 350)));
                                  },
                                  leading: CircleAvatar(
                                    foregroundColor:
                                        Theme.of(context).primaryColor,
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(.1),
                                    child: Icon(Icons.list),
                                  ),
                                  title: Text(m.keterangan,
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700,
                                      )),
                                  subtitle: Text(
                                      formatDate(m.created_at,
                                              "dd MMMM yyyy HH:mm:ss") ??
                                          ' ',
                                      style: TextStyle(
                                          fontSize: 10.0,
                                          color: Colors.grey.shade700)),
                                  trailing: Text(formatRupiah(m.jumlah),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: m.jumlah < 0
                                              ? Colors.red
                                              : Colors.green)),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : Expanded(
                        child: Container(
                          child: Center(
                            child: SvgPicture.asset('assets/img/empty.svg',
                                width: MediaQuery.of(context).size.width * .35),
                          ),
                        ),
                      ),
              ],
            ),
    );
  }
}

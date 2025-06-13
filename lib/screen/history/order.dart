// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/mp_transaction.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/history/order/order-controller.dart';
import 'package:mobile/screen/marketplace/detail_pesanan.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class HistoryOrderPage extends StatefulWidget {
  @override
  _HistoryOrderPageState createState() => _HistoryOrderPageState();
}

class _HistoryOrderPageState extends OrderController with TickerProviderStateMixin {

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
                      'Filter Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: packageName == 'com.lariz.mobile' || packageName == 'com.eralink.mobileapk'
                          ? Theme.of(context).secondaryHeaderColor
                          : Theme.of(context).primaryColor
                      ),
                    ),
                  ),
                  body: Container(
                    padding: EdgeInsets.all(10),
                    color: packageName == 'com.lariz.mobile'
                      ? Theme.of(context).secondaryHeaderColor.withOpacity(.05)
                      : Theme.of(context).primaryColor.withOpacity(.05),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        packageName == 'com.eralink.mobileapk'
                          ? DropdownButtonFormField(
                              iconEnabledColor: Theme.of(context).primaryColor,
                              items: statusList,
                              value: status,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 15,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                ),
                                hintText: 'Tipe Status',
                                hintStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor)
                              ),
                              onChanged: (val) => setState(() {
                                status = val;
                              }),
                            )
                          : DropdownButtonFormField(
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
                                hintText: 'Tipe Status',
                                hintStyle: packageName == 'com.lariz.mobile'
                                  ? TextStyle(color: Theme.of(context).secondaryHeaderColor)
                                  : null,
                              ),
                              onChanged: (val) => setState(() {
                                status = val;
                              }),
                            ),
                        SizedBox(height: 10),
                        Row(
                            children: [
                              Expanded(
                                child: packageName == 'com.eralink.mobileapk'
                                  ? TextField(
                                      style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
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
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                        )
                                      ),
                                    )
                                  : TextField(
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
                                  color: packageName == 'com.eralink.mobileapk'
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey
                                ),
                              ),
                              Expanded(
                                child: packageName == 'com.eralink.mobileapk'
                                  ? TextField(
                                      style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
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
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                        )
                                      ),
                                    )
                                  : TextField(
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
                          Row(
                            children: [
                              Expanded(
                                child: packageName == 'com.eralink.mobileapk'
                                  ? OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: Theme.of(context).primaryColor
                                        )
                                      ),
                                      child: Text(
                                        'ATUR ULANG',
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                      onPressed: resetFilter,
                                    )
                                  : OutlinedButton(
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
                                child: packageName == 'com.eralink.mobileapk'
                                  ? OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: Theme.of(context).primaryColor
                                        )
                                      ),
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
                                    )
                                  : OutlinedButton(
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
            listTransaksi.isNotEmpty
              ? Expanded(
                  child: SmartRefresher(
                    controller: refreshController,
                    enablePullUp: true,
                    enablePullDown: true,
                    onRefresh: () async {
                      currentPage = 0;
                      isEdge = false;
                      listTransaksi.clear();
                      await getData();
                      refreshController.refreshCompleted();
                    },
                    onLoading: () async {
                      await getData();
                      refreshController.loadComplete();
                    },
                    child: ListView.builder(
                    itemCount: listTransaksi.length,
                    itemBuilder: (ctx, i) {
                      MPTransaksi item = listTransaksi[i];

                      return ListTile(
                        dense: true,
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => DetailPesananPage(item))),
                        title: Text(
                            item.products.last.productName ?? 'Produk Dihapus',
                            overflow: TextOverflow.ellipsis),
                        subtitle: Text(
                            formatDate(item.createdAt, 'd MMMM yyyy HH:mm:ss'),
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                        leading: CircleAvatar(
                          backgroundColor: item.status.color.withOpacity(.15),
                          child:
                              Icon(item.status.icon, color: item.status.color),
                        ),
                        trailing: Text(formatRupiah(item.totalHargaJual),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: packageName == 'com.lariz.mobile'
                                  ? Theme.of(context).secondaryHeaderColor
                                  : Theme.of(context).primaryColor,
                            )),
                      );
                    },
                  ),
                    // child: ListView.separated(
                    //   shrinkWrap: true,
                    //   physics: ScrollPhysics(),
                    //   padding: EdgeInsets.symmetric(vertical: 10),
                    //   itemCount: listTransaksi.length,
                    //   separatorBuilder: (_, i) => SizedBox(height: 10),
                    //   itemBuilder: (_, int index) {
                    //     MPTransaksi m = listTransaksi[index];
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
                    //               PageTransition(
                    //                   child: DetailPesananPage(m),
                    //                   type: PageTransitionType.rippleMiddle,
                    //                   duration:
                    //                       Duration(milliseconds: 350)));
                    //         },
                    //         leading: CircleAvatar(
                    //           backgroundColor: m.status.color.withOpacity(.15),
                    //           child: Icon(m.status.icon, color: m.status.color),
                    //         ),
                    //         title: Text(
                    //           m.products.last.productName ?? 'Produk Dihapus',
                    //           overflow: TextOverflow.ellipsis,
                    //         ),
                    //         subtitle: Text(
                    //           formatDate(m.createdAt, 'd MMMM yyyy HH:mm:ss'),
                    //           style: TextStyle(fontSize: 11, color: Colors.grey),
                    //         ),
                    //         trailing: Text(formatRupiah(m.totalHargaJual),
                    //           style: TextStyle(
                    //             fontWeight: FontWeight.bold,
                    //             color: packageName == 'com.lariz.mobile'
                    //               ? Theme.of(context).secondaryHeaderColor
                    //               : Theme.of(context).primaryColor
                    //           ),
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // ),
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
        );
  }
}

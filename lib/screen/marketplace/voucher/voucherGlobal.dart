// @dart=2.9

import 'dart:convert';
import 'package:flutter/material.dart';

// PACKAGE NPM
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

// BLOC
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';

// MODEL
import 'package:mobile/models/mp_voucher.dart';

import 'package:mobile/screen/marketplace/voucher/detailVoucher.dart';

class VoucherGlobal extends StatefulWidget {
  @override
  createState() => VoucherGlobalState();
}

class VoucherGlobalState extends State<VoucherGlobal> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  bool loading = true;
  List<VoucherMarket> vouchers = [];
  @override
  initState() {
    super.initState();
    analitycs.pageView('/voucher/global', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Vocuher GLobal',
    });
    getList();
  }

  Future<void> getList() async {
    try {
      vouchers.clear();
      http.Response response =
          await http.get(Uri.parse('$apiUrl/market/voucher/global'), headers: {
        'authorization': bloc.token.valueWrapper?.value,
      });

      String message = json.decode(response.body)['message'] ??
          'Terjadi kesalahan saat mengambil data dari server';
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<dynamic> datas = responseData['data'];

        datas.forEach((data) {
          vouchers.add(VoucherMarket.fromJson(data));
        });
      }
    } catch (err) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Gagal'),
                content: Text(
                    'Terjadi kesalahan saat mengambil data dari server. ${err.toString()}'),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ));
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> onTapVoucher(VoucherMarket voucher) async {
    dynamic response = await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => DetailVoucher(voucher),
    ));

    await getList();
    print('response -> $response');
    if (response != null) {
      Navigator.of(context).pop(voucher);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? buildLoading()
          : vouchers.length == 0
              ? buildEmpty()
              : Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: SmartRefresher(
                      controller: _refreshController,
                      enablePullUp: true,
                      enablePullDown: true,
                      onRefresh: () async {
                        await getList();
                        _refreshController.refreshCompleted();
                      },
                      onLoading: () async {
                        await getList();
                        _refreshController.loadComplete();
                      },
                      child: ListView.separated(
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          padding: EdgeInsets.all(10.0),
                          itemCount: vouchers.length,
                          separatorBuilder: (_, i) => SizedBox(height: 10),
                          itemBuilder: (ctx, i) {
                            VoucherMarket voucher = vouchers[i];
                            return buildVoucher(voucher);
                          })),
                ),
    );
  }

  Widget buildVoucher(VoucherMarket voucher) {
    return InkWell(
        onTap: () => onTapVoucher(voucher),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.withOpacity(.3), width: 1),
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(.4),
                    offset: Offset(4, 4),
                    blurRadius: 10)
              ]),
          child: ListTile(
            dense: true,
            leading: CircleAvatar(
              foregroundColor: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(.1),
              child: Icon(Icons.list),
            ),
            title: Text(
              voucher.title,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5.0),
                Text(
                  voucher.description,
                  style: TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
            trailing: Icon(Icons.navigate_next,
                color: Theme.of(context).primaryColor),
          ),
        ));
  }

  Widget buildLoading() {
    return Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
            child: SpinKitThreeBounce(
                color: Theme.of(context).primaryColor, size: 25)));
  }

  Widget buildEmpty() {
    return Center(
      child: SvgPicture.asset('assets/img/empty.svg',
          width: MediaQuery.of(context).size.width * .45),
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}

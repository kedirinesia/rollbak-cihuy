// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/history_reward.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Bloc.dart' show bloc;
import 'package:mobile/provider/analitycs.dart';

import 'package:mobile/bloc/Api.dart';
import 'package:mobile/modules.dart';

class HistoryReward extends StatefulWidget {
  @override
  _HistoryRewardState createState() => _HistoryRewardState();
}

class _HistoryRewardState extends HistoryRewardController {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Penukaran'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).secondaryHeaderColor,
      ),
      body: loading ? loadingWidget() : listWidget(),
    );
  }
}

abstract class HistoryRewardController extends State<HistoryReward> {
  bool loading = true;
  List<HistoryRewardModel> histories = [];

  @override
  void initState() {
    getData();
    super.initState();
    analitycs.pageView('/history/reward', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Riwayat Penukaran Reward',
    });
  }

  void getData() async {
    http.Response response = await http.get(Uri.parse('$apiUrl/reward/history'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});
    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      histories.clear();
      datas.forEach((item) {
        histories.add(HistoryRewardModel.fromJson(item));
      });
    }

    setState(() {
      loading = false;
    });
  }

  Widget loadingWidget() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
          child: SpinKitThreeBounce(
              color: Theme.of(context).secondaryHeaderColor, size: 35)),
    );
  }

  Widget listWidget() {
    if (histories.length == 0) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
            child: SvgPicture.asset('assets/img/reward.svg',
                width: MediaQuery.of(context).size.width * .45)),
      );
    } else {
      return Container(
        width: double.infinity,
        height: double.infinity,
        child: ListView.separated(
          padding: EdgeInsets.all(15),
          itemCount: histories.length,
          separatorBuilder: (context, i) => SizedBox(height: 15),
          itemBuilder: (context, i) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(.1),
                        offset: Offset(5, 10.0),
                        blurRadius: 20)
                  ]),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(histories[i].reward.title,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(histories[i].status == 0 ? 'PENDING' : 'SUKSES',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: histories[i].status == 0
                                      ? Colors.grey
                                      : Colors.green)),
                        ]),
                    SizedBox(height: 10),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                              '${NumberFormat.decimalPattern('id').format(histories[i].reward.poin)} Poin',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 11)),
                          Text(
                              formatDate(histories[i].updatedAt,
                                  'd MMMM yyyy HH:mm:ss'),
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 11)),
                        ])
                  ]),
            );
          },
        ),
      );
    }
  }
}

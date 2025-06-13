// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/Products/lariz/layout/reward/history_reward.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/models/reward.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Bloc.dart' show bloc;

class ListReward extends StatefulWidget {
  @override
  _ListRewardState createState() => _ListRewardState();
}

class _ListRewardState extends ListRewardController {
  @override
  void initState() {
    super.initState();
    analitycs.pageView('/list/reward', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'List Reward',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Daftar Reward'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.history),
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => HistoryReward())))
          ]),
      body: loading ? loadingWidget() : listWidget(),
    );
  }
}

abstract class ListRewardController extends State<ListReward> {
  bool loading = true;
  List<RewardModel> rewards = [];

  @override
  void initState() {
    getData();
    super.initState();
  }

  void getData() async {
    http.Response response = await http.get(Uri.parse('$apiUrl/reward/list'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];

      rewards.clear();
      datas.forEach((item) {
        rewards.add(RewardModel.fromJson(item));
      });
    }

    setState(() {
      loading = false;
    });
  }

  void tukarReward(String id) async {
    http.Response response = await http.post(Uri.parse('$apiUrl/reward/tukar'),
        headers: {
          'Authorization': bloc.token.valueWrapper?.value,
          'Content-Type': 'application/json'
        },
        body: json.encode({'id': id}));

    String message = json.decode(response.body)['message'];
    if (response.statusCode == 200) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
                title: Text('Penukaran Berhasil'),
                content: Text(message),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                    ),
                    onPressed: () =>
                        Navigator.of(ctx, rootNavigator: true).pop(),
                  ),
                ],
              ));
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
                title: Text('Penukaran Gagal'),
                content: Text(message),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'TUTUP',
                      style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                    ),
                    onPressed: () =>
                        Navigator.of(ctx, rootNavigator: true).pop(),
                  ),
                ],
              ));
    }
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
    if (rewards.length == 0) {
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
          child: GridView.builder(
              padding: EdgeInsets.all(15),
              physics: ScrollPhysics(),
              itemCount: rewards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 3 / 4),
              itemBuilder: (context, i) {
                return InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) => AlertDialog(
                                  title: Text('Tukar Reward'),
                                  content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('Nama',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 11)),
                                        SizedBox(height: 5),
                                        Text(rewards[i].title),
                                        SizedBox(height: 10),
                                        Text('Deskripsi',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 11)),
                                        SizedBox(height: 5),
                                        Text(rewards[i].description),
                                        SizedBox(height: 10),
                                        Text('Poin Dibutuhkan',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 11)),
                                        SizedBox(height: 5),
                                        Text(
                                            '${NumberFormat.decimalPattern('id').format(rewards[i].poin)} Poin'),
                                        SizedBox(height: 10)
                                      ]),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(
                                        'TUKARKAN',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                      ),
                                      onPressed: () =>
                                          tukarReward(rewards[i].id),
                                    ),
                                    TextButton(
                                      child: Text(
                                        'TUTUP',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                      ),
                                      onPressed: () =>
                                          Navigator.of(ctx, rootNavigator: true)
                                              .pop(),
                                    ),
                                  ]));
                    },
                    child: CachedNetworkImage(
                        imageUrl: rewards[i].imageUrl,
                        fit: BoxFit.cover,
                        imageBuilder: (context, provider) {
                          return Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(.1),
                                      offset: Offset(5, 10.0),
                                      blurRadius: 20)
                                ],
                                image: DecorationImage(image: provider)),
                          );
                        }));
              }));
    }
  }
}

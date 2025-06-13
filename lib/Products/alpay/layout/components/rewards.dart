// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/models/reward.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Bloc.dart' show bloc;
import 'package:shimmer/shimmer.dart';

class RewardComponent extends StatefulWidget {
  final double width;
  final double height;
  final double aspectRatio;
  final double marginBottom;

  RewardComponent(
      {this.width = double.infinity,
      this.height,
      this.aspectRatio = 29 / 30,
      this.marginBottom = 10.0});

  @override
  _RewardComponentState createState() => _RewardComponentState();
}

class _RewardComponentState extends State<RewardComponent> {
  bool loading = true;
  List<RewardModel> rewards = [];
  List<Widget> rewardsWidget = [];

  @override
  void initState() {
    getData();
    super.initState();
  }

  void getData() async {
    try {
      http.Response response = await http.get(Uri.parse('$apiUrl/reward/list'),
          headers: {'Authorization': bloc.token.valueWrapper?.value});

      if (response.statusCode == 200) {
        List<dynamic> datas = json.decode(response.body)['data'];
        rewards.clear();
        datas.forEach((item) {
          rewards.add(RewardModel.fromJson(item));
        });
        setState(() {
          loading = false;
        });
      } else {
        String message = json.decode(response.body)['message'] ??
            'Terjadi kesalahan pada server';
        final snackBar = Alert(message, isError: true);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print(e);
    }
  }

  void tukarReward(String id) async {
    http.Response response = await http.post(Uri.parse('$apiUrl/reward/tukar'),
        headers: {
          'Authorization': bloc.token.valueWrapper?.value,
          'Content-Type': 'application/json'
        },
        body: json.encode({'id': id}));

    print(response.body);
    String message = json.decode(response.body)['message'];
    if (response.statusCode == 200) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
                title: Text('Penukaran Berhasil'),
                content: Text(message),
                actions: <Widget>[
                  TextButton(
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop())
                ],
              ));
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
                title: Text('Penukaran Gagal'),
                content: Text(message),
                actions: <Widget>[
                  TextButton(
                      child: Text(
                        'TUTUP',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop())
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? rewardsLoading()
        : rewards.length == 0
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                              left: 18.0, right: 18.0, top: 18.0, bottom: 2.0),
                          child: Text(
                            'Hadiah Menarik ALPAY',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              left: 18.0, right: 18.0, top: 2.0, bottom: 18.0),
                          child: Text(
                            'Kumpulkan poin lalu tukarkan hadiah',
                            style: TextStyle(
                              fontSize: 13,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      padding: EdgeInsets.symmetric(vertical: 50.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Hadiah Menarik Belum Tersedia',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                padding: EdgeInsets.only(bottom: 18.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                              left: 18.0, right: 18.0, top: 18.0, bottom: 2.0),
                          child: Text(
                            'Hadiah Menarik ALPAY',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              left: 18.0, right: 18.0, top: 2.0, bottom: 18.0),
                          child: Text(
                            'Kumpulkan poin lalu tukarkan hadiah',
                            style: TextStyle(
                              fontSize: 13,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.0),
                    Container(
                      margin: EdgeInsets.only(bottom: widget.marginBottom),
                      child: Container(
                        height: 135,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              RewardModel reward = rewards[index];
                              return InkWell(
                                onTap: () {
                                  return showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (ctx) => AlertDialog(
                                      title: Text('Tukar Reward'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'Nama',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(reward.title),
                                          SizedBox(height: 10),
                                          Text(
                                            'Deskripsi',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(reward.description),
                                          SizedBox(height: 10),
                                          Text(
                                            'Poin Dibutuhkan',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            '${NumberFormat.decimalPattern('id').format(reward.poin)} Poin',
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text(
                                            'TUKARKAN',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                          onPressed: () =>
                                              tukarReward(reward.id),
                                        ),
                                        TextButton(
                                          child: Text(
                                            'TUTUP',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                          onPressed: () => Navigator.of(ctx,
                                                  rootNavigator: true)
                                              .pop(),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: AspectRatio(
                                  aspectRatio: widget.aspectRatio,
                                  child: Container(
                                    margin: EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade300,
                                          offset: const Offset(0.0, 1.1),
                                          blurRadius: 1.0,
                                          spreadRadius: 0.2,
                                        ),
                                        BoxShadow(
                                          color: Colors.grey.shade300,
                                          offset: const Offset(-0.1, -0.1),
                                          blurRadius: 1.0,
                                          spreadRadius: 0.2,
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: CachedNetworkImage(
                                        imageUrl: reward.imageUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const SizedBox(width: 8),
                            itemCount: rewards.length),
                      ),
                    ),
                  ],
                ),
              );
  }

  Widget rewardsLoading() {
    return Container(
      padding: EdgeInsets.only(bottom: 18.0),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(
                    left: 18.0, right: 18.0, top: 18.0, bottom: 2.0),
                child: Text(
                  'Hadiah Menarik ALPAY',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                    left: 18.0, right: 18.0, top: 2.0, bottom: 18.0),
                child: Text(
                  'Kumpulkan poin lalu tukarkan hadiah',
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(bottom: widget.marginBottom),
            child: Column(
              children: [
                Container(
                  height: 135,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        return AspectRatio(
                          aspectRatio: widget.aspectRatio,
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white),
                              child: Container(),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(width: 8),
                      itemCount: 4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

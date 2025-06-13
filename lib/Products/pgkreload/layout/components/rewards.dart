// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/models/reward.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Bloc.dart' show bloc;
import 'package:shimmer/shimmer.dart';

class RewardComponent extends StatefulWidget {
  final double width;
  final double height;
  final double aspectRatio;
  final double viewportFraction;
  RewardComponent(
      {this.width = double.infinity,
      this.height,
      this.viewportFraction = .3,
      this.aspectRatio = 25 / 10});

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
        ? Container(
            padding: EdgeInsets.only(bottom: 30.0),
            decoration: BoxDecoration(color: Colors.white),
            child: Container(
              padding: EdgeInsets.only(top: 15.0, left: 18, right: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dapatkan Hadiah Menarik',
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.7,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  CarouselSlider.builder(
                    itemCount: rewards.length,
                    options: CarouselOptions(
                      autoPlay: true,
                      aspectRatio: widget.aspectRatio,
                      enlargeCenterPage: true,
                      viewportFraction: widget.viewportFraction,
                    ),
                    itemBuilder: (_, i, __) {
                      return Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.5),
                              color: Colors.white,
                            ),
                            child: Container(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          )
        : rewards.length == 0
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        top: 15.0,
                        left: 18,
                        right: 18,
                      ),
                      child: Text(
                        'Dapatkan Hadiah Menarik',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 50.0),
                      child: Center(
                        child: Text(
                          'Hadiah Menarik Belum Tersedia',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                padding: EdgeInsets.only(bottom: 30.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Container(
                  padding: EdgeInsets.only(
                    top: 15.0,
                    left: 18,
                    right: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dapatkan Hadiah Menarik',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.7,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      CarouselSlider.builder(
                        itemCount: rewards.length,
                        options: CarouselOptions(
                          autoPlay: true,
                          aspectRatio: widget.aspectRatio,
                          enlargeCenterPage: true,
                          viewportFraction: widget.viewportFraction,
                        ),
                        itemBuilder: (_, i, __) {
                          RewardModel item = rewards[i];

                          return InkWell(
                            child: Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12.5),
                                image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                        item.imageUrl,
                                        scale: .1),
                                    fit: BoxFit.cover),
                              ),
                            ),
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
                                      Text(item.title),
                                      SizedBox(height: 10),
                                      Text(
                                        'Deskripsi',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(item.description),
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
                                        '${NumberFormat.decimalPattern('id').format(item.poin)} Poin',
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(
                                        'TUKARKAN',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      onPressed: () => tukarReward(item.id),
                                    ),
                                    TextButton(
                                      child: Text(
                                        'TUTUP',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      onPressed: () =>
                                          Navigator.of(ctx, rootNavigator: true)
                                              .pop(),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
  }
}

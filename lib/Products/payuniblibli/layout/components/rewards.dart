// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/reward.dart';
import 'package:mobile/modules.dart';

class RewardComponent extends StatefulWidget {
  final double aspectRatio;
  final double viewportFraction;
  RewardComponent({this.aspectRatio = 2.5, this.viewportFraction = .3});

  @override
  _RewardComponentState createState() => _RewardComponentState();
}

class _RewardComponentState extends State<RewardComponent> {
  Future<List<RewardModel>> rewards() async {
    List<RewardModel> items = [];

    http.Response response = await http.get(
      Uri.parse('$apiUrl/reward/list'),
      headers: {'Authorization': bloc.token.valueWrapper?.value},
    );

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      items = datas.map((e) => RewardModel.fromJson(e)).toList();
    }

    return items;
  }

  Future<void> tukarDialog(RewardModel item) async {
    bool status = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: Text('Tukar Reward'),
            content: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Text('Nama',
                    style: TextStyle(color: Colors.grey, fontSize: 11)),
                SizedBox(height: 5),
                Text(item.title),
                SizedBox(height: 10),
                Text('Deskripsi',
                    style: TextStyle(color: Colors.grey, fontSize: 11)),
                SizedBox(height: 5),
                Text(item.description),
                SizedBox(height: 10),
                Text('Poin Dibutuhkan',
                    style: TextStyle(color: Colors.grey, fontSize: 11)),
                SizedBox(height: 5),
                Text('${formatNumber(item.poin)} Poin'),
                SizedBox(height: 10),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('TUKARKAN'),
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
              TextButton(
                child: Text('TUTUP'),
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
            ],
          ),
        ) ??
        false;

    if (!status) return;
    await tukar(item.id);
  }

  Future<void> tukar(String id) async {
    http.Response response = await http.post(
      Uri.parse('$apiUrl/reward/tukar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': bloc.token.valueWrapper?.value,
      },
      body: json.encode(
        {'id': id},
      ),
    );

    if (response.statusCode == 200) {
      showToast(context, 'Penukaran hadiah berhasil');
    } else {
      showToast(context, 'Gagal menukarkan hadiah');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RewardModel>>(
      future: rewards(),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData)
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 1,
                valueColor:
                    AlwaysStoppedAnimation(Theme.of(context).primaryColor),
              ),
            ),
          );

        if (snapshot.data.length == 0)
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            child: Center(
              child: Text(
                'Tidak ada Hadiah',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          );

        return CarouselSlider.builder(
            options: CarouselOptions(
              autoPlay: true,
              aspectRatio: widget.aspectRatio,
              viewportFraction: widget.viewportFraction,
              enlargeCenterPage: true,
            ),
            itemCount: snapshot.data.length,
            itemBuilder: (ctx, i, _) {
              RewardModel reward = snapshot.data[i];

              return InkWell(
                onTap: () => tukarDialog(reward),
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12.5),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        reward.imageUrl,
                        scale: .1,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            });
      },
    );
  }
}

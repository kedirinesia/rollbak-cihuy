// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/Products/payku/layout/dialog-popup/custom_dialog_box.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/models/reward.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Bloc.dart' show bloc;
import 'package:quickalert/quickalert.dart';

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
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Registrasi Berhasil',
        text: message,
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
        },
      );
    } else {
      String message = json.decode(response.body)['message'];
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Registrasi Gagal',
        text: message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Container()
        : Container(
            margin: EdgeInsets.only(bottom: 10),
            width: widget.width,
            height: widget.height,
            child: rewards.length == 0
                ? Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Text(
                        'Tidak ada hadiah',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  )
                : CarouselSlider.builder(
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
                                image: CachedNetworkImageProvider(item.imageUrl,
                                    scale: .1),
                                fit: BoxFit.cover),
                          ),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) => CustomDialogBox(
                              title: 'Tukar Reward',
                              nama: item.title,
                              descriptions: item.description,
                              poin:
                                  '${NumberFormat.decimalPattern('id').format(item.poin)} Poin',
                              text1: 'TUKARKAN',
                              text2: 'BATAL',
                              id: item.id,
                            ),
                            // builder: (ctx) => AlertDialog(
                            //   title: Text('Tukar Reward'),
                            //   content: Column(
                            //     mainAxisSize: MainAxisSize.min,
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: <Widget>[
                            //       Text(
                            //         'Nama',
                            //         style: TextStyle(
                            //           color: Colors.grey,
                            //           fontSize: 11,
                            //         ),
                            //       ),
                            //       SizedBox(height: 5),
                            //       Text(item.title),
                            //       SizedBox(height: 10),
                            //       Text(
                            //         'Deskripsi',
                            //         style: TextStyle(
                            //           color: Colors.grey,
                            //           fontSize: 11,
                            //         ),
                            //       ),
                            //       SizedBox(height: 5),
                            //       Text(item.description),
                            //       SizedBox(height: 10),
                            //       Text(
                            //         'Poin Dibutuhkan',
                            //         style: TextStyle(
                            //           color: Colors.grey,
                            //           fontSize: 11,
                            //         ),
                            //       ),
                            //       SizedBox(height: 5),
                            //       Text(
                            //         '${NumberFormat.decimalPattern('id').format(item.poin)} Poin',
                            //       ),
                            //       SizedBox(height: 10),
                            //     ],
                            //   ),
                            //   actions: <Widget>[
                            //     TextButton(
                            //       child: Text(
                            //         'TUKARKAN',
                            //         style: TextStyle(
                            //           color: Theme.of(context).primaryColor,
                            //         ),
                            //       ),
                            //       onPressed: () => tukarReward(item.id),
                            //     ),
                            //     TextButton(
                            //       child: Text(
                            //         'TUTUP',
                            //         style: TextStyle(
                            //           color: Theme.of(context).primaryColor,
                            //         ),
                            //       ),
                            //       onPressed: () =>
                            //           Navigator.of(ctx, rootNavigator: true)
                            //               .pop(),
                            //     ),
                            //   ],
                            // ),
                          );
                          print(item);
                        },
                      );
                    },
                  ),
          );
  }
}

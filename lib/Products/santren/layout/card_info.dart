// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/info.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screen/info/info.dart';
import 'package:mobile/utils/debug_helper.dart';

class CardInfo extends StatefulWidget {
  @override
  _CardInfoState createState() => _CardInfoState();
}

class _CardInfoState extends State<CardInfo> {
  Future<List<InfoModel>> getInfo() async {
    List<InfoModel> infos = [];
    http.Response response = await http.get(Uri.parse('$apiUrl/info/list'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      infos.clear();
      datas.forEach((el) => infos.add(InfoModel.fromJson(el)));
    }

    return infos;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<InfoModel>>(
        future: getInfo(),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) return Container();
          return SizedBox(
            height: 170.0,
            child: CarouselSlider.builder(
              itemCount: snapshot.data.length,
              options: CarouselOptions(
                autoPlay: true,
                aspectRatio: 2.5,
                enlargeCenterPage: false,
                viewportFraction: 0.8,
                autoPlayInterval: Duration(milliseconds: 5000),
              ),
              itemBuilder: (_, i, __) {
                InfoModel info = snapshot.data[i];

                return InkWell(
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => InfoPage(info))),
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(info.icon),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.9),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                ),
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      info.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      info.description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }
}

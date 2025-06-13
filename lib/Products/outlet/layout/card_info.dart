// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/info.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screen/info/info.dart';

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
          print("SUKSESSS");
          return ListView(
            children: snapshot.data.map((d) {
              InfoModel info = d;

              return Container(
                width: 10,
                height: 160,
                margin: EdgeInsets.all(10),
                child: InkWell(
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => InfoPage(info))),
                // child: Text("SUKSES"),
                  child: Container(
                    width: double.infinity,
                    // margin: EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        border: Border.all(
                            color: Colors.grey.withOpacity(.5), width: 1),
                        borderRadius: BorderRadius.circular(12.5),
                        image: DecorationImage(
                            image: CachedNetworkImageProvider(info.icon),
                            fit: BoxFit.cover)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12.5),
                              bottomRight: Radius.circular(12.5),
                            ),
                          ),
                          child: Text(
                            info.title,
                            textAlign: TextAlign.justify,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            // options: CarouselOptions(viewportFraction: .65, aspectRatio: 3),
          );
        });
  }
}

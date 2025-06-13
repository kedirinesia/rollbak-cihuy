// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/info.dart';
import 'package:mobile/provider/api.dart';
import 'package:mobile/screen/info/info.dart';

class CardInfo extends StatefulWidget {
  @override
  _CardInfoState createState() => _CardInfoState();
}

class _CardInfoState extends State<CardInfo> {
  Future<List<InfoModel>> getInfo() async {
    List<dynamic> datas = await api.get('/info/list', cache: true);
    return datas.map((e) => InfoModel.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<InfoModel>>(
        future: getInfo(),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) return Container();
          return CarouselSlider.builder(
            itemCount: snapshot.data.length,
            options: CarouselOptions(
              autoPlay: false,
              viewportFraction: 1,
              aspectRatio: 3.9,
            ),
            itemBuilder: (_, i, index) {
              InfoModel info = snapshot.data[i];

              return InkWell(
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => InfoPage(info))),
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(7.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        offset: Offset(0, 0),
                        blurRadius: 5,
                      ),
                    ],
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(info.icon),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7.5),
                    child: CachedNetworkImage(
                      imageUrl: info.icon,
                      fit: BoxFit.cover,
                      repeat: ImageRepeat.noRepeat,
                    ),
                  ),
                ),
              );
            },
          );
        });
  }
}

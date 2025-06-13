// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/webview.dart';
import 'package:mobile/models/banner.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/provider/api.dart';

class BannerComponent extends StatefulWidget {
  @override
  _BannerComponentState createState() => _BannerComponentState();
}

class _BannerComponentState extends State<BannerComponent> {
  int _index = 0;

  Future<List<BannerModel>> banners() async {
    List<dynamic> datas = await api.get('/banner/list', cache: true);
    return datas.map((e) => BannerModel.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BannerModel>>(
      future: banners(),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData)
          return AspectRatio(
            aspectRatio: 1.33,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey.shade200,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                ),
              ),
            ),
          );

        if (snapshot.hasError)
          return AspectRatio(
            aspectRatio: 1.33,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey.shade200,
              child: Center(
                child: Text(
                  'TERJADI KESALAHAN',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );

        if (snapshot.hasData && snapshot.data.length == 0)
          return AspectRatio(
            aspectRatio: 1.33,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey.shade200,
              child: Center(
                child: Text(
                  'TIDAK ADA PROMO',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );

        return Stack(
          alignment: Alignment.bottomLeft,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                aspectRatio: 1.33,
                viewportFraction: 1.0,
                initialPage: _index,
              ),
              items: snapshot.data.map((d) {
                BannerModel banner = d;

                return InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) =>
                            Webview(banner.title, banner.url)),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: banner.cover,
                    fit: BoxFit.fitWidth,
                  ),
                );
              }).toList(),
            ),
            Container(
              margin: EdgeInsets.only(left: 15, bottom: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(snapshot.data.length, (i) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(
                      color: i == _index
                          ? Theme.of(context).primaryColor
                          : Colors.grey.withOpacity(.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}

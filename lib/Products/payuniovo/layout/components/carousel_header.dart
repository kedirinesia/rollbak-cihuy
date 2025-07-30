// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/banner.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/provider/api.dart';
import 'package:mobile/screen/detail-denom/detail-denom.dart';
import 'package:mobile/screen/list-grid-menu/list-grid-menu.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class CarouselHeader extends StatefulWidget {
  final double viewportFraction;
  final double aspectRatio;

  CarouselHeader({this.viewportFraction = 1.0, this.aspectRatio = 2.0});

  @override
  _CarouselHeaderState createState() => _CarouselHeaderState();
}

class _CarouselHeaderState extends State<CarouselHeader> {
  List<BannerModel> bannerInfo = [];
  bool loading = true;
  int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  void initState() {
    super.initState();
    fetchBanner();
  }

  @override
  void dispose() {
    super.dispose();
  }

  fetchBanner() async {
    String path = '/banner/list?limit=3';

    if (packageName == 'com.onetronic.mobile') {
      path = '/banner/list';
    }

    try {
      List<dynamic> datas = await api.get(path, cache: true);
      bannerInfo = datas.map((e) => BannerModel.fromJson(e)).toList();
      setState(() {
        loading = false;
      });
    } catch (_) {
      setState(() {
        loading = false;
      });
    }
  }

  dynamic showBanner(BannerModel banner) {
    List<String> urls = banner.url.split('/');
    if (urls[0] == 'menu') {
      MenuModel menu = MenuModel(
        id: urls[1],
        name: banner.title,
        icon: '',
      );

      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ListGridMenu(menu),
        ),
      );
    } else if (urls[0] == 'prepaid') {
      MenuModel menu = MenuModel(
        id: banner.id,
        name: banner.title,
        category_id: urls[1],
        icon: '',
      );

      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DetailDenom(menu),
        ),
      );
    } else {
      // return Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder: (context) => Webview(banner.title, banner.url),
      //   ),
      // );
      return launch(banner.url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    if (bannerInfo.length == 0) return Container();

    return loading
        ? loadingBanner()
        : CarouselSlider.builder(
            itemCount: bannerInfo.length,
            options: CarouselOptions(
              height: height,
              autoPlay: true,
              enlargeCenterPage: false,
              viewportFraction: .9,
              aspectRatio: widget.aspectRatio,
              initialPage: 2,
              pauseAutoPlayOnTouch: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              },
            ),
            itemBuilder: (_, i, __) {
              BannerModel banner = bannerInfo[i];

              return InkWell(
                onTap: () => showBanner(banner),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: banner.cover,
                      fit: BoxFit.cover,
                      height: height,
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget loadingBanner() {
    final double height = MediaQuery.of(context).size.height;

    return Container(
      child: CarouselSlider(
        options: CarouselOptions(
          height: height,
          autoPlay: true,
          enlargeCenterPage: false,
          viewportFraction: widget.viewportFraction,
          aspectRatio: widget.aspectRatio,
          initialPage: 2,
          pauseAutoPlayOnTouch: true,
        ),
        items: List.generate(3, (i) {
          return Builder(
            builder: (BuildContext context) {
              return InkWell(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade400,
                  highlightColor: Colors.grey.shade200,
                  period: Duration(seconds: 2),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                    ),
                    child: Container(),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

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

class CarouselDepan extends StatefulWidget {
  final double viewportFraction;
  final double aspectRatio;
  final double marginBottom;

  CarouselDepan(
      {this.viewportFraction = .8,
      this.aspectRatio = 25 / 10,
      this.marginBottom = 10.0});

  @override
  _CarouselDepanState createState() => _CarouselDepanState();
}

class _CarouselDepanState extends State<CarouselDepan> {
  List<BannerModel> banner = [];
  bool loading = true;
  int _current = 0;

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

    if (packageName == 'com.onetronic.mobile' ||
        packageName == 'com.santrenpay.mobile') {
      path = '/banner/list';
    }

    try {
      List<dynamic> datas = await api.get(path, cache: true);
      banner = datas.map((e) => BannerModel.fromJson(e)).toList();
      setState(() {
        loading = false;
      });
    } catch (_) {
      setState(() {
        loading = false;
      });
    }
  }

  dynamic onClickBanner(BannerModel banner) {
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
      return launch(banner.url);
      // return Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder: (context) => Webview(banner.title, banner.url),
      //   ),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (banner.length == 0) return Container();
    return loading
        ? loadingBanner()
        : Container(
            margin: EdgeInsets.only(bottom: widget.marginBottom),
            child: CarouselSlider.builder(
              itemCount: banner.length,
              options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: widget.viewportFraction,
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
                BannerModel bannerInfo = banner[i];

                return InkWell(
                  onTap: () => onClickBanner(bannerInfo),
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.5),
                      child: CachedNetworkImage(
                        imageUrl: bannerInfo.cover,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
            // child: CarouselSlider(
            //   options: CarouselOptions(
            //     autoPlay: true,
            //     aspectRatio: widget.aspectRatio,
            //     enlargeCenterPage: true,
            //     viewportFraction: widget.viewportFraction,
            //     pauseAutoPlayOnManualNavigate: true,
            //     initialPage: 2,
            //     onPageChanged: (index, reason) {
            //       setState(() {
            //         _current = index;
            //       });
            //     },
            //   ),
            //   items: banner.map((i) {
            //     return Builder(
            //       builder: (BuildContext context) {
            //         return InkWell(
            //           onTap: () => onClickBanner(i),
            //           child: Container(
            //             width: double.infinity,
            //             margin: EdgeInsets.symmetric(horizontal: 5.0),
            //             decoration: BoxDecoration(
            //               color: Colors.grey.shade200,
            //               borderRadius: BorderRadius.circular(12.5),
            //             ),
            //             child: ClipRRect(
            //               borderRadius: BorderRadius.circular(12.5),
            //               child: i.cover != null // Pengecekan apakah cover tidak null
            //                   ? CachedNetworkImage(
            //                       imageUrl: i.cover,
            //                       fit: BoxFit.cover,
            //                     )
            //                   : Container(),
            //             ),
            //           ),
            //         );
            //       },
            //     );
            //   }).toList(),
            // ),
          );
  }

  Widget loadingBanner() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: CarouselSlider(
        options: CarouselOptions(autoPlay: true),
        items: List.generate(3, (i) {
          return Builder(
            builder: (BuildContext context) {
              return InkWell(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade400,
                  highlightColor: Colors.grey,
                  period: Duration(seconds: 2),
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12.5)),
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

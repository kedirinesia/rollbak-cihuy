import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mobile/component/webview.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/banner.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/provider/api.dart';
import 'package:mobile/screen/detail-denom/detail-denom.dart';
import 'package:mobile/screen/list-grid-menu/list-grid-menu.dart';
import 'package:shimmer/shimmer.dart';

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
      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Webview(banner.title, banner.url),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    if (bannerInfo.length == 0) return Container();

    return Stack(
      children: [
        loading
            ? loadingBanner()
            : CarouselSlider(
                options: CarouselOptions(
                  height: height,
                  autoPlay: true,
                  enlargeCenterPage: false,
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
                items: bannerInfo.map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return InkWell(
                        onTap: () => showBanner(i),
                        child: Container(
                          width: double.infinity,
                          child: CachedNetworkImage(
                            imageUrl: i.cover,
                            fit: BoxFit.cover,
                            height: height,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
        Positioned(
          bottom: 40,
          left: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: bannerInfo.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => _controller.animateToPage(entry.key),
                child: Container(
                  width: 7.0,
                  height: 7.0,
                  margin: EdgeInsets.only(top: 20.0, left: 4.0, right: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.white)
                        .withOpacity(_current == entry.key ? 0.9 : 0.4),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
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

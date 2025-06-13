import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/info.dart';
import 'package:mobile/provider/api.dart';
import 'package:mobile/screen/info/info.dart';
import 'package:shimmer/shimmer.dart';

class CarouselDepan extends StatefulWidget {
  final double viewportFraction;
  final double aspectRatio;
  final double marginBottom;

  CarouselDepan(
      {this.viewportFraction = .8,
      this.aspectRatio = 25 / 9,
      this.marginBottom = 10.0});

  @override
  _CarouselDepanState createState() => _CarouselDepanState();
}

class _CarouselDepanState extends State<CarouselDepan> {
  List<InfoModel> bannerInfo = [];
  bool loading = true;
  int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  void initState() {
    super.initState();
    fetchBannerInfo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  fetchBannerInfo() async {
    String path = '/info/list';

    if (packageName == 'com.onetronic.mobile') {
      path = '/info/list';
    }

    try {
      List<dynamic> datas = await api.get(path, cache: true);
      bannerInfo = datas.map((e) => InfoModel.fromJson(e)).toList();
      setState(() {
        loading = false;
      });
    } catch (_) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? loadingBannerInfo()
        : bannerInfo.length == 0
            ? Container(
                decoration: BoxDecoration(color: Colors.white),
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
                        'Info Dan Promo Spesial',
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
                          'Banner Dan Info Belum Tersedia',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                padding: EdgeInsets.only(bottom: 10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 15.0, left: 18, right: 18),
                      child: Text(
                        'Info Dan Promo Spesial',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      margin: EdgeInsets.only(bottom: widget.marginBottom),
                      child: Column(
                        children: [
                          CarouselSlider(
                            options: CarouselOptions(
                              autoPlay: true,
                              // height: MediaQuery.of(context).size.height / 6.3,
                              aspectRatio: widget.aspectRatio,
                              enlargeCenterPage: true,
                              viewportFraction: widget.viewportFraction,
                              pauseAutoPlayOnManualNavigate: true,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _current = index;
                                });
                              },
                            ),
                            carouselController: _controller,
                            items: bannerInfo.map((i) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return InkWell(
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => InfoPage(i),
                                      ),
                                    ),
                                    child: Container(
                                      width: double.infinity,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 5.0),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius:
                                            BorderRadius.circular(12.5),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12.5),
                                        child: CachedNetworkImage(
                                          imageUrl: i.icon,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: bannerInfo.asMap().entries.map((entry) {
                              return GestureDetector(
                                onTap: () =>
                                    _controller.animateToPage(entry.key),
                                child: Container(
                                  width: 7.0,
                                  height: 7.0,
                                  margin: EdgeInsets.only(
                                      top: 20.0, left: 4.0, right: 4.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Theme.of(context).primaryColor)
                                        .withOpacity(
                                            _current == entry.key ? 0.9 : 0.4),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
  }

  Widget loadingBannerInfo() {
    return Container(
      padding: EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(color: Colors.white),
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
              'Info Dan Promo Spesial',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.7,
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Container(
            margin: EdgeInsets.only(bottom: widget.marginBottom),
            child: Column(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: true,
                    aspectRatio: widget.aspectRatio,
                    enlargeCenterPage: false,
                    viewportFraction: widget.viewportFraction,
                    pauseAutoPlayOnManualNavigate: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                      });
                    },
                  ),
                  carouselController: _controller,
                  items: bannerInfo.map((i) {
                    return Builder(builder: (BuildContext context) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        period: Duration(seconds: 2),
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12.5)),
                          child: Container(),
                        ),
                      );
                    });
                  }).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: bannerInfo.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap: () => _controller.animateToPage(entry.key),
                      child: Container(
                        width: 8.0,
                        height: 8.0,
                        margin:
                            EdgeInsets.only(top: 20.0, left: 4.0, right: 4.0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.grey.shade400)
                                    .withOpacity(
                                        _current == entry.key ? 0.9 : 0.4)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

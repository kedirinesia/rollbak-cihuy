import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/banner.dart';
import 'package:mobile/provider/api.dart';

class BannerTransaction extends StatefulWidget {
  @override
  _BannerTransactionState createState() => _BannerTransactionState();
}

class _BannerTransactionState extends State<BannerTransaction> {
  int _index = 0;
  List<BannerModel> banners = [];
  double _aspectRatio = 2;

  @override
  void initState() {
    super.initState();
    getBanners();
  }

  Future<void> getBanners() async {
    List<dynamic> datas = await api.get('/banner/list', cache: true);
    setState(() {
      banners = datas.map((e) => BannerModel.fromJson(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _aspectRatio,
      child: Stack(
        fit: StackFit.loose,
        children: [
          Container(
            height: 100,
            color: Theme.of(context).primaryColor,
          ),
          banners.length == 0
              ? CarouselSlider.builder(
                  options: CarouselOptions(
                    aspectRatio: _aspectRatio,
                    viewportFraction: .95,
                    onPageChanged: (i, _) {
                      setState(() {
                        _index = i;
                      });
                    },
                  ),
                  itemCount: 5,
                  itemBuilder: (_, i, index) {
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 2.5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  },
                )
              : CarouselSlider.builder(
                  options: CarouselOptions(
                    aspectRatio: _aspectRatio,
                    viewportFraction: .95,
                    onPageChanged: (i, _) {
                      setState(() {
                        _index = i;
                      });
                    },
                  ),
                  itemCount: banners.length,
                  itemBuilder: (_, i, index) {
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 2.5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                            banners.elementAt(i).cover,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              margin: EdgeInsets.only(left: 30, bottom: 15),
              child: Row(
                children: List.generate(
                    banners.length == 0 ? 5 : banners.length, (i) {
                  return Container(
                    width: i == _index ? 15 : 8,
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
          ),
        ],
      ),
    );
  }
}

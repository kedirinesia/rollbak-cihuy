// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/payuniblibli/layout/list_banner.dart';
import 'package:mobile/component/webview.dart';
import 'package:mobile/models/banner.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/provider/api.dart';
import 'package:mobile/screen/detail-denom/detail-denom.dart';
import 'package:mobile/screen/list-grid-menu/list-grid-menu.dart';

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
      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Webview(banner.title, banner.url),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BannerModel>>(
      future: banners(),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData)
          return AspectRatio(
            aspectRatio: 1.134,
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
            aspectRatio: 1.134,
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
            aspectRatio: 1.134,
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
            CarouselSlider.builder(
              options: CarouselOptions(
                autoPlay: true,
                aspectRatio: 1.134,
                viewportFraction: 1.0,
                initialPage: _index,
                onPageChanged: (index, _) {
                  setState(() {
                    _index = index;
                  });
                },
              ),
              itemCount: snapshot.data.length,
              itemBuilder: (ctx, i, _) {
                BannerModel banner = snapshot.data[i];

                return InkWell(
                  onTap: () => onClickBanner(banner),
                  child: CachedNetworkImage(
                    imageUrl: banner.cover,
                    fit: BoxFit.fitHeight,
                  ),
                );
              },
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(7.5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(.5),
                      offset: Offset(2, 2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                transform: Matrix4.translationValues(0, -10, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(snapshot.data.length, (i) {
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
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      child: InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ListBannerPage(),
                          ),
                        ),
                        child: Text(
                          'Lihat semua',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

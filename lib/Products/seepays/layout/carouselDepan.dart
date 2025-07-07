// @dart=2.9

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mobile/component/webview.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/banner.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/screen/detail-denom/detail-denom.dart';
import 'package:mobile/screen/list-grid-menu/list-grid-menu.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CarouselDepan extends StatefulWidget {
  final double viewportFraction;
  final double aspectRatio;
  final double marginBottom;

  CarouselDepan({
    this.viewportFraction = 0.80, // lebih lebar, tapi tetap nampak kanan kirinya
    this.aspectRatio = 16 / 7,   // sedikit lebih tinggi
    this.marginBottom = 16.0,
  });

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

  Future<void> fetchBanner() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        setState(() => loading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('https://app.payuni.co.id/api/v1/banner/list?limit=3'),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        final jsonResp = json.decode(response.body);
        final datas = jsonResp['data'] ?? [];
        banner = datas.map<BannerModel>((e) => BannerModel.fromJson(e)).toList();
      }
    } catch (_) {}
    setState(() => loading = false);
  }

  dynamic onClickBanner(BannerModel banner) {
    List<String> urls = banner.url?.split('/') ?? [];
    if (urls.length > 1 && urls[0] == 'menu') {
      MenuModel menu = MenuModel(id: urls[1], name: banner.title, icon: '');
      return Navigator.of(context).push(MaterialPageRoute(builder: (_) => ListGridMenu(menu)));
    } else if (urls.length > 1 && urls[0] == 'prepaid') {
      MenuModel menu = MenuModel(id: banner.id, name: banner.title, category_id: urls[1], icon: '');
      return Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailDenom(menu)));
    } else if (banner.url != null && banner.url.isNotEmpty) {
      return launch(banner.url);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return loadingBanner();

    if (banner.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text('Banner Tidak Ditemukan', style: TextStyle(color: Colors.grey)),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: widget.marginBottom),
      child: CarouselSlider.builder(
        itemCount: banner.length,
        options: CarouselOptions(
          height: 160,
          autoPlay: true,
          enlargeCenterPage: true,
          enlargeStrategy: CenterPageEnlargeStrategy.height,
          viewportFraction: widget.viewportFraction,
          aspectRatio: widget.aspectRatio,
          onPageChanged: (index, reason) => setState(() => _current = index),
        ),
        itemBuilder: (_, i, __) {
          final isCenter = i == _current;

          return InkWell(
            onTap: () => onClickBanner(banner[i]),
            child: AnimatedScale(
              scale: isCenter ? 1.05 : 0.95,
              duration: Duration(milliseconds: 300),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: CachedNetworkImage(
                    imageUrl: banner[i].cover,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (ctx, url) => Center(child: CircularProgressIndicator()),
                    errorWidget: (_, __, ___) => Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget loadingBanner() {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.marginBottom),
      child: CarouselSlider.builder(
        itemCount: 3,
        options: CarouselOptions(
          height: 200,
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: widget.viewportFraction,
          aspectRatio: widget.aspectRatio,
        ),
        itemBuilder: (_, i, __) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade300,
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade400,
              highlightColor: Colors.grey[200],
              period: Duration(seconds: 2),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

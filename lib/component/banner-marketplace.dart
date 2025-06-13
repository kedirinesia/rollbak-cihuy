// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mobile/component/webview.dart';
import 'package:mobile/models/banner.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Bloc.dart' show bloc;
import 'package:mobile/bloc/Api.dart' show apiUrl;
import 'package:shimmer/shimmer.dart';

class BannerMarketplace extends StatefulWidget {
  final double viewportFraction;
  final double aspectRatio;
  final double marginBottom;

  BannerMarketplace(
      {this.viewportFraction = .8,
      this.aspectRatio = 25 / 10,
      this.marginBottom = 10.0});

  @override
  _BannerMarketplaceState createState() => _BannerMarketplaceState();
}

class _BannerMarketplaceState extends State<BannerMarketplace> {
  List<BannerModel> banner = [];
  bool loading = true;

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
    try {
      http.Response response = await http.get(
          Uri.parse('$apiUrl/market/banner'),
          headers: {'Authorization': bloc.token.valueWrapper?.value});
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        List<BannerModel> lb = (body['data'] as List)
            .map((f) => new BannerModel.fromJson(f))
            .toList();

        banner = lb;
      } else {
        banner = [];
      }
    } catch (_) {}

    if (mounted)
      setState(() {
        loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? loadingBanner()
        : banner.length == 0
            ? Container()
            : Container(
                margin: EdgeInsets.only(bottom: widget.marginBottom),
                child: CarouselSlider(
                  options: CarouselOptions(
                      autoPlay: true,
                      aspectRatio: widget.aspectRatio,
                      enlargeCenterPage: true,
                      viewportFraction: widget.viewportFraction,
                      pauseAutoPlayOnTouch: true),
                  items: banner.map((i) {
                    return Builder(
                      builder: (BuildContext context) {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Webview(i.title, i.url)));
                          },
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
                                imageUrl: i.cover,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              );
  }

  Widget loadingBanner() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: CarouselSlider(
        options: CarouselOptions(
          autoPlay: true,
          aspectRatio: 25 / 10,
        ),
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

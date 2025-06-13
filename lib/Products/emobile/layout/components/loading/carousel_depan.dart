// @dart=2.9

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingCarouselDepan extends StatelessWidget {
  final aspectRatio;
  final viewportFraction;
  const LoadingCarouselDepan(this.aspectRatio, this.viewportFraction, {Key key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: CarouselSlider(
        options: CarouselOptions(
          autoPlay: true,
          aspectRatio: this.aspectRatio,
          viewportFraction: this.viewportFraction,
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

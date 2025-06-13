// @dart=2.9

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingRewardComponent extends StatelessWidget {
  final aspectRatio;
  final viewportFraction;
  const LoadingRewardComponent(this.aspectRatio, this.viewportFraction,
      {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 30.0),
      child: Container(
        padding: EdgeInsets.only(top: 15.0, left: 18, right: 18),
        child: CarouselSlider.builder(
          itemCount: 3,
          options: CarouselOptions(
            autoPlay: true,
            aspectRatio: this.aspectRatio,
            enlargeCenterPage: true,
            viewportFraction: viewportFraction,
          ),
          itemBuilder: (_, i, __) {
            return Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade400,
                highlightColor: Colors.grey.shade200,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.5),
                    color: Colors.white,
                  ),
                  child: Container(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

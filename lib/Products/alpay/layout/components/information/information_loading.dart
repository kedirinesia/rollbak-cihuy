// @dart=2.9

import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/alpay/layout/components/information/information_label.dart';
import 'package:mobile/Products/alpay/layout/components/information/information_loading.style.dart';
import 'package:shimmer/shimmer.dart';

class InformationLoading extends StatelessWidget {
  const InformationLoading({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 18.0),
      decoration: BoxDecoration(color: Colors.white),
      height: 360,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InformationLabel(),
          Expanded(
            child: Container(
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 6,
                        ),
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return AspectRatio(
                            aspectRatio: 1.15,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    offset: const Offset(0.0, 1.1),
                                    blurRadius: 1.0,
                                    spreadRadius: 0.2,
                                  ),
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    offset: const Offset(-0.1, -0.1),
                                    blurRadius: 1.0,
                                    spreadRadius: 0.2,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    period: Duration(seconds: 2),
                                    child: Parent(
                                      style: InformationLoadingStyle.cardImage,
                                      child: Container(),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 18),
                                        Container(
                                          child: Shimmer.fromColors(
                                            baseColor: Colors.grey.shade300,
                                            highlightColor:
                                                Colors.grey.shade100,
                                            period: Duration(seconds: 2),
                                            child: Parent(
                                              style: InformationLoadingStyle
                                                  .cardTextLine,
                                              child: Container(),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Container(
                                          child: Shimmer.fromColors(
                                            baseColor: Colors.grey.shade300,
                                            highlightColor:
                                                Colors.grey.shade100,
                                            period: Duration(seconds: 2),
                                            child: Parent(
                                                style: InformationLoadingStyle
                                                    .cardTextLine
                                                    .clone()
                                                  ..width(200),
                                                child: Container()),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(width: 15),
                        itemCount: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

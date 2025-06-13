// @dart=2.9

import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/ualreload/layout/components/product_of_choice/product_of_choice_label.dart';
import 'package:shimmer/shimmer.dart';

class ProductOfChoiceLoading extends StatelessWidget {
  const ProductOfChoiceLoading({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductOfChoiceLabel(),
          Container(
            padding: EdgeInsets.only(top: 2, bottom: 10, left: 7.0, right: 7),
            color: Colors.white,
            child: GridView.builder(
              padding: EdgeInsets.all(5),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: .62,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Container(
                  padding:
                      EdgeInsets.only(top: 10, right: 10, bottom: 15, left: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(7)),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    period: Duration(seconds: 2),
                                    child: Parent(
                                      style: ParentStyle()
                                        ..height(160)
                                        ..background.color(Colors.grey.shade400)
                                        ..borderRadius(
                                            topLeft: 12.5, topRight: 12.5),
                                      child: Container(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15.0),
                            Container(
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                period: Duration(seconds: 2),
                                child: Parent(
                                  style: ParentStyle()
                                    ..height(20)
                                    ..width(130)
                                    ..background.color(Colors.grey.shade400)
                                    ..borderRadius(all: 6),
                                  child: Container(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                period: Duration(seconds: 2),
                                child: Parent(
                                  style: ParentStyle()
                                    ..height(20)
                                    ..width(90)
                                    ..background.color(Colors.grey.shade400)
                                    ..borderRadius(all: 6),
                                  child: Container(),
                                ),
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Container(
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                period: Duration(seconds: 2),
                                child: Parent(
                                  style: ParentStyle()
                                    ..height(20)
                                    ..width(110)
                                    ..background.color(Colors.grey.shade400)
                                    ..borderRadius(all: 6),
                                  child: Container(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

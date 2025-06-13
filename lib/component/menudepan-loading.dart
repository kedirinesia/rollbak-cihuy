// @dart=2.9

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingMenuDepan extends StatelessWidget {
  final int grid;
  final int baris;

  LoadingMenuDepan(this.grid, {this.baris});

  @override
  Widget build(BuildContext context) {
    int totalBaris = baris ?? 3;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: GridView.count(
        crossAxisCount: grid,
        crossAxisSpacing: 5,
        mainAxisSpacing: 10.0,
        shrinkWrap: true,
        children: List.generate(grid * totalBaris, (i) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Shimmer.fromColors(
                baseColor: Colors.grey.shade400,
                highlightColor: Colors.grey.shade200,
                child: Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white),
                  child: Container(),
                ),
              ),
              SizedBox(height: 10.0),
              Shimmer.fromColors(
                baseColor: Colors.grey.shade400,
                highlightColor: Colors.grey.shade200,
                child: Container(
                  width: 50.0,
                  height: 10.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white),
                  child: Container(),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

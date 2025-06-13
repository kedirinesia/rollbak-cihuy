import 'package:flutter/material.dart';
import 'package:mobile/component/card_info.dart';
import 'package:mobile/component/carousel-depan.dart';
import 'package:mobile/component/menudepan.dart';
import 'package:mobile/component/rewards.dart';
import 'package:mobile/screen/home/home_model.dart';

class HomeApp extends StatefulWidget {
  @override
  _HomeAppState createState() => _HomeAppState();
}

class _HomeAppState extends HomeModel {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 170,
            child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.5),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment(0.8, 0.0),
                      tileMode: TileMode.clamp,
                      colors: <Color>[
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(.3)
                      ],
                    )),
                height: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    balanceInfo(),
                    Expanded(
                      child: cardButton(),
                    )
                  ],
                )),
          ),
          MenuDepan(grid: 5),
          CarouselDepan(),
          CardInfo(),
          RewardComponent()
        ],
      ),
    );
  }
}

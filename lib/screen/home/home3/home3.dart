import 'package:flutter/material.dart';
import 'package:mobile/component/card_info.dart';
import 'package:mobile/component/carousel-depan.dart';
import 'package:mobile/component/menudepan.dart';
import 'package:mobile/component/rewards.dart';
import './home3_model.dart';

class Home3App extends StatefulWidget {
  @override
  _Home3AppState createState() => _Home3AppState();
}

class _Home3AppState extends Home3Model {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          SizedBox(height: 20.0),
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

import 'package:flutter/material.dart';
import 'package:mobile/component/card_info.dart';
import 'package:mobile/component/carousel-depan.dart';
import 'package:mobile/component/menudepan.dart';
import 'package:mobile/config.dart';

import './home5_model.dart';

class Home5App extends StatefulWidget {
  @override
  _Home5AppState createState() => _Home5AppState();
}

class _Home5AppState extends Home5Model {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          width: double.infinity,
          height: 300.0,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(.4)
          ])),
        ),
        CustomScrollView(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              title: Text(appName, style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(),
            ),
            SliverFillViewport(
                delegate: SliverChildListDelegate([
              Container(
                margin: EdgeInsets.only(top: 50.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0)),
                child: ListView(
                  physics: ScrollPhysics(),
                  children: <Widget>[
                    MenuDepan(grid: 5),
                    CarouselDepan(),
                    CardInfo(),
                  ],
                ),
              )
            ]))
          ],
        )
      ],
    );
  }
}

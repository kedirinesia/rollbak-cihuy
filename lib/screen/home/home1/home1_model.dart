// @dart=2.9

import 'package:flutter/material.dart';
import './home1.dart';

abstract class Home1Model extends State<Home1App>
    with TickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(duration: Duration(seconds: 4), vsync: this);
  }
}

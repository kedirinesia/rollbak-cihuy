// @dart=2.9

import 'package:flutter/material.dart';
import './home2.dart';

abstract class Home2Model extends State<Home2App>
    with TickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: Duration(seconds: 4), vsync: this);
  }
}

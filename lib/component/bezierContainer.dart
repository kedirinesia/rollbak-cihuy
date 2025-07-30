// @dart=2.9

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile/bloc/ConfigApp.dart';

import 'customClipper.dart';

class BezierContainer extends StatelessWidget {
  const BezierContainer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Transform.rotate(
            angle: -pi / 3.5,
            child: configAppBloc.packagename.valueWrapper?.value ==
                    'com.santrenpay.mobile'
                ? ClipPath(
                    clipper: ClipPainter(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * .5,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                            Theme.of(context).primaryColor.withOpacity(.5),
                            Theme.of(context).primaryColor,
                          ])),
                    ),
                  )
                : ClipPath(
                    clipper: ClipPainter(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * .5,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(.5),
                          ])),
                    ),
                  )));
  }
}

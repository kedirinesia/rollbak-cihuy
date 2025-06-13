// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/bloc/ConfigApp.dart' show configAppBloc;

class SplashPopay extends StatefulWidget {
  @override
  _SplashPopayState createState() => _SplashPopayState();
}

class _SplashPopayState extends State<SplashPopay>
    with TickerProviderStateMixin {
  Animation<double> lebarLogo;
  Animation<Color> colorBg;
  AnimationController logoAnimation;
  AnimationController backgroundAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    logoAnimation = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    lebarLogo = Tween<double>(begin: 70, end: 100).animate(logoAnimation);
    logoAnimation.repeat(reverse: true);

    backgroundAnimation = AnimationController(
        duration: const Duration(milliseconds: 3000), vsync: this);
    colorBg =
        ColorTween(begin: const Color(0XFFCEA0E4), end: const Color(0XFFDCC6E0))
            .animate(backgroundAnimation)
          ..addListener(() {
            setState(() {});
          });
    backgroundAnimation.repeat(reverse: true);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    logoAnimation.dispose();
    backgroundAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Stack(
      children: [
        Container(color: colorBg.value),
        Container(
            child: Center(
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'icon-apk',
              child: AnimatedBuilder(
                  animation: lebarLogo,
                  builder: (_, child) {
                    return CachedNetworkImage(
                        color: Colors.white,
                        width: lebarLogo.value,
                        fit: BoxFit.cover,
                        imageUrl: configAppBloc
                            .iconApp.valueWrapper?.value['logoApp']);
                  }),
            ),
          ],
        )))
      ],
    ));
  }
}

// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/bloc/ConfigApp.dart' show configAppBloc;

class SplashPopay extends StatefulWidget {
  @override
  _SplashPopayState createState() => _SplashPopayState();
}

class _SplashPopayState extends State<SplashPopay>
    with SingleTickerProviderStateMixin {
  // Animation<double> lebarLogo;
  // Animation<Color> colorBg;
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 200, end: 250).animate(_controller);
    _controller.forward();

    // logoAnimation = AnimationController(
    //     duration: const Duration(milliseconds: 1000), vsync: this);
    // lebarLogo = Tween<double>(begin: 200, end: 250).animate(logoAnimation);
    // logoAnimation.repeat(reverse: true);

    // backgroundAnimation = AnimationController(
    //     duration: const Duration(milliseconds: 3000), vsync: this);
    // colorBg = ColorTween(
    //         begin: const Color(0XFFF8E44AD), end: const Color(0XFFF8E44AD))
    //     .animate(backgroundAnimation)
    //   ..addListener(() {
    //     setState(() {});
    //   });
    // backgroundAnimation.repeat(reverse: true);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // logoAnimation.dispose();
    // backgroundAnimation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (BuildContext context, Widget child) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 1000),
              width: MediaQuery.of(context).size.width * _animation.value,
              height: MediaQuery.of(context).size.height * _animation.value,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      'https://dokumen.payuni.co.id/logo/outlet/splash1.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
      //     child: Stack(
      //   children: [
      //     Container(color: colorBg.value),
      //     Container(
      //         child: Center(
      //             child: Column(
      //       // crossAxisAlignment: CrossAxisAlignment.center,
      //       mainAxisAlignment: MainAxisAlignment.start,

      //       children: [
      //         Hero(
      //           tag: 'icon-apk',
      //           child: AnimatedBuilder(
      //               animation: lebarLogo,
      //               builder: (_, child) {
      //                 return CachedNetworkImage(
      //                     // color: Colors.white,
      //                     // width: double.infinity,
      //                     fit: BoxFit.cover,
      //                     imageUrl: configAppBloc
      //                         .iconApp.valueWrapper?.value['logoApp']);
      //               }),
      //         ),
      //       ],
      //     )))
      //   ],
      // )
    );
  }
}

// @dart=2.9

import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/bloc/ConfigApp.dart' show configAppBloc;
import 'package:shared_preferences/shared_preferences.dart';

class SplashTalentapay extends StatefulWidget {
  @override
  _SplashTalentapayState createState() => _SplashTalentapayState();
}

class _SplashTalentapayState extends State<SplashTalentapay>
    with TickerProviderStateMixin {
  AnimationController controller;
  double _linearProgress = 0;
  Timer _timer;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool splashLoading = prefs.getBool('splash-loading') ?? false;

      print("ooooo ${splashLoading}");
      if (!splashLoading) {
        print(_linearProgress);
        if (_linearProgress < 0.7) {
          setState(() {
            _linearProgress += 0.2;
          });
        }
      } else {
        setState(() {
          _linearProgress = 1;
        });
        _timer.cancel();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Stack(
      children: [
        Container(color: Colors.white),
        Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CachedNetworkImage(
                    width: 250,
                    fit: BoxFit.cover,
                    imageUrl:
                        configAppBloc.iconApp.valueWrapper?.value['logoApp']),
                SizedBox(height: 50),
                // Column(
                //   children: [
                //     Text(
                //       'Talentapay'.toUpperCase(),
                //       style: TextStyle(
                //         fontSize: 45,
                //         letterSpacing: 5,
                //         fontWeight: FontWeight.w900,
                //       ),
                //     ),
                //     Text(
                //       'Digital Business Solution',
                //       style: TextStyle(
                //         fontSize: 20,
                //         letterSpacing: 3,
                //         fontWeight: FontWeight.w900,
                //       ),
                //     )
                //   ],
                // ),
                // SizedBox(height: 50),
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                  child: LinearProgressIndicator(
                    value: _linearProgress,
                    semanticsLabel: 'Linear progress indicator',
                    minHeight: 20,
                    color: Color(0xff0B20E5),
                    backgroundColor: Color(0xffEEF0F2),
                  ),
                ),
              ],
            ))
      ],
    ));
  }
}

// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/profile/cs/cs_controller.dart';

class CS extends StatefulWidget {
  @override
  _CSState createState() => _CSState();
}

class _CSState extends CSController {
  @override
  void initState() {
    super.initState();
    analitycs.pageView('/cs', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Customer Service',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text('Customer Service'), centerTitle: true, elevation: 0),
      body: Column(children: <Widget>[
        Container(
          width: double.infinity,
          height: 200,
          padding: EdgeInsets.all(20),
          child: Hero(
            tag: 'cs',
            child: Center(
                child: CachedNetworkImage(
                    imageUrl:
                        'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Ftie.png?alt=media&token=143f7a42-e520-49fb-8314-a53ac2c28614')),
          ),
          decoration: BoxDecoration(color: Colors.white),
        ),
        loading ? loadingWidget() : listWidget()
      ]),
    );
  }
}

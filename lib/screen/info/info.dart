// @dart=2.9
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/info.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/info/info_controller.dart';

class InfoPage extends StatefulWidget {
  final InfoModel info;

  InfoPage(this.info);

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends InfoPageController {
  @override
  void initState() {
    super.initState();
    analitycs.pageView('/informasi/', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Informasi',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informasi'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: packageName == 'com.lariz.mobile'
            ? Theme.of(context).secondaryHeaderColor
            : Theme.of(context).primaryColor,
      ),
      body: Container(
        child: ListView(children: <Widget>[
          Hero(
            tag: 'info-${widget.info.id}',
            child: CachedNetworkImage(
              imageUrl: widget.info.icon,
              width: double.infinity,
              placeholder: (context, str) => Center(
                child: SpinKitThreeBounce(
                    color: packageName == 'com.lariz.mobile'
                        ? Theme.of(context).secondaryHeaderColor
                        : Theme.of(context).primaryColor,
                    size: 20),
              ),
            ),
          ),
          Container(
              width: double.infinity,
              padding: EdgeInsets.all(15),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.info.title,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: packageName == 'com.lariz.mobile'
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(widget.info.content)
                  ]))
        ]),
      ),
    );
  }
}

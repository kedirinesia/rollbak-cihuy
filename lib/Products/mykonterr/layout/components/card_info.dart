// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/models/info.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Bloc.dart' show bloc;
import 'dart:convert';

import 'package:mobile/screen/info/info.dart';

class CardInfo extends StatefulWidget {
  @override
  _CardInfoState createState() => _CardInfoState();
}

class _CardInfoState extends CardInfoController {
  @override
  Widget build(BuildContext context) {
    return loading
        ? SizedBox(width: 0, height: 0)
        : listWidget.length == 0
            ? Container(
                width: double.infinity,
                height: 100,
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                    child: Text('Tidak ada info',
                        style:
                            TextStyle(color: Theme.of(context).primaryColor))),
              )
            : Container(
                padding: EdgeInsets.only(top: 10.0),
                margin: EdgeInsets.only(bottom: 20),
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          // BoxShadow(
                          //     color: Colors.black.withOpacity(.1),
                          //     offset: Offset(5, 10),
                          //     blurRadius: 20)
                        ]),
                    child: Column(
                        mainAxisSize: MainAxisSize.min, children: listWidget)),
              );
  }
}

abstract class CardInfoController extends State<CardInfo>
    with TickerProviderStateMixin {
  bool loading = true;
  List<Widget> listWidget = [];

  @override
  void initState() {
    getData();
    super.initState();
  }

  void getData() async {
    http.Response response = await http.get(Uri.parse('$apiUrl/info/list'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      (json.decode(response.body)['data'] as List).forEach((item) {
        InfoModel info = InfoModel.fromJson(item);
        Widget widget = ListTile(
          dense: true,
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => InfoPage(info)));
          },
          leading: Hero(
              tag: 'info-${info.id}',
              child: CachedNetworkImage(imageUrl: info.icon, width: 50)),
          title: Text(info.title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(info.description,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: Colors.grey)),
          trailing:
              Icon(Icons.navigate_next, color: Theme.of(context).primaryColor),
        );
        if (listWidget.length != 0) {
          listWidget.add(Divider());
        }
        listWidget.add(widget);
      });
    }

    setState(() {
      loading = false;
    });
  }
}

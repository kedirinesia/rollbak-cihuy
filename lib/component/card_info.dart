// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/models/info.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Bloc.dart' show bloc;
import 'dart:convert';

import 'package:mobile/screen/info/info.dart';
import 'package:mobile/utils/debug_helper.dart';

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
                height: 200,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: listWidget.length,
                  separatorBuilder: (context, index) => SizedBox(width: 8),
                  itemBuilder: (context, index) => Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: listWidget[index],
                  ),
                ),
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
        Widget widget = InkWell(
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => InfoPage(info)));
          },
          child: Container(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Hero(
                  tag: 'info-${info.id}',
                  child: CachedNetworkImage(
                    imageUrl: info.icon, 
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        info.description,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11, 
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.navigate_next, 
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
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

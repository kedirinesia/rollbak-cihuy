// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/info.dart';
import 'package:mobile/screen/info/info.dart';

class InfoComponent extends StatefulWidget {
  @override
  _InfoComponentState createState() => _InfoComponentState();
}

class _InfoComponentState extends State<InfoComponent> {
  Future<List<InfoModel>> infos() async {
    List<InfoModel> items = [];

    http.Response response = await http.get(
      Uri.parse('$apiUrl/info/list'),
      headers: {'Authorization': bloc.token.valueWrapper?.value},
    );

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      items = datas.map((e) => InfoModel.fromJson(e)).toList();
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<InfoModel>>(
      future: infos(),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData)
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 1,
                valueColor:
                    AlwaysStoppedAnimation(Theme.of(context).primaryColor),
              ),
            ),
          );

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.1),
                offset: Offset(5, 10),
                blurRadius: 20,
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: snapshot.data.length,
            separatorBuilder: (_, i) => Divider(),
            itemBuilder: (ctx, i) {
              InfoModel info = snapshot.data[i];

              return ListTile(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => InfoPage(info),
                  ),
                ),
                dense: true,
                leading: CachedNetworkImage(
                  imageUrl: info.icon,
                  width: 50,
                ),
                title: Text(
                  info.title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  info.description,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                trailing: Icon(
                  Icons.navigate_next,
                  color: Theme.of(context).primaryColor,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

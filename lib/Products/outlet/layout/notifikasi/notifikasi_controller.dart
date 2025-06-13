// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/notifikasi.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/modules.dart';
import 'package:mobile/bloc/Bloc.dart' show bloc;
import 'notifikasi.dart';

// class Notif extends StatefulWidget {
//   @override
//   NotifikasiController createState() => NotifikasiController();
// }

abstract class NotifikasiController extends State<Notifikasi>
    with TickerProviderStateMixin {
  List<NotifikasiModel> notifications = [];
  bool loading = true;
  bool isEdge = false;
  int page = 0;

  int unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    if (isEdge) return;

    http.Response response = await http.get(
        Uri.parse('$apiUrl/outbox/list?page=$page'),
        headers: {'Authorization': bloc.token.valueWrapper?.value});

    if (response.statusCode == 200) {
      List<dynamic> datas = json.decode(response.body)['data'];
      if (datas.length == 0) isEdge = true;
      datas
          .forEach((item) => notifications.add(NotifikasiModel.fromJson(item)));
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> readNotification(NotifikasiModel notifikasi) async {
    try {
      NotifikasiModel selectItem = notifications[
          notifications.indexWhere((element) => element.id == notifikasi.id)];

      setState(() {
        selectItem.opened = true;
      });

      http.Response response = await http.post(
        Uri.parse('$apiUrl/outbox/read'),
        headers: {
          'Authorization': bloc.token.valueWrapper?.value,
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'id': notifikasi.id,
          },
        ),
      );

      if (response.statusCode == 200) {
        // ..
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Widget loadingWidget() {
    return Center(
        child: SpinKitThreeBounce(
            color: Theme.of(context).primaryColor, size: 35));
  }

  Widget listWidget() {
    if (notifications.length == 0) {
      return Center(
        child: SvgPicture.asset('assets/img/img_notification.svg',
            width: MediaQuery.of(context).size.width * .45),
      );
    } else {
      return Container(
        width: double.infinity,
        height: double.infinity,
        child: LazyLoadScrollView(
          scrollOffset: 200,
          onEndOfPage: () {
            page++;
            getData();
          },
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: notifications.length,
            separatorBuilder: (context, i) => Divider(height: 0),
            itemBuilder: (context, i) {
              NotifikasiModel notif = notifications[i];
              return ListTile(
                tileColor: notif.opened
                    ? Color(0xffEEF0F2).withOpacity(0.5)
                    : Colors.white,
                onTap: () async {
                  List<String> pkgNameList = [
                    'com.talentapay.android',
                  ];

                  pkgNameList.forEach((element) {
                    if (element == packageName) {
                      readNotification(notif);
                    }
                  });

                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      content: Text(notif.pesan),
                      actions: <Widget>[
                        TextButton(
                            child: Text(
                              'TUTUP',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            onPressed: () async {
                              Navigator.pop(ctx);
                            })
                      ],
                    ),
                  );
                },
                title: Text(notif.pesan,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: notif.opened
                            ? FontWeight.normal
                            : FontWeight.bold)),
                leading: CircleAvatar(
                  backgroundColor: notif.opened
                      ? Theme.of(context).primaryColor.withOpacity(.07)
                      : Theme.of(context).primaryColor.withOpacity(.15),
                  child: Icon(Icons.notifications,
                      color: Theme.of(context).primaryColor),
                ),
                dense: true,
                subtitle:
                    Text(formatDate(notif.createdAt, "d MMMM yyyy HH:mm:ss")),
              );
            },
          ),
        ),
      );
    }
  }
}

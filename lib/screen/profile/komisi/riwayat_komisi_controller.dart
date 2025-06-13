// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/komisi.dart';
import 'package:mobile/modules.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Bloc.dart' show bloc;
import 'package:mobile/screen/profile/komisi/riwayat_komisi.dart';
import 'package:mobile/screen/profile/komisi/tukar_komisi.dart';

abstract class RiwayattKomisiController extends State<RiwayatKomisi>
    with TickerProviderStateMixin {
  List<Komisi> listKomisi = [];
  bool loading = true;
  int page = 0;
  bool isEdge = false;

  void getData() async {
    if (!isEdge) {
      try {
        http.Response response = await http.get(
            Uri.parse('$apiUrl/komisi/list?page=$page'),
            headers: {'Authorization': bloc.token.valueWrapper?.value});

        if (response.statusCode == 200) {
          List<dynamic> list = json.decode(response.body)['data'] as List;
          if (list.length == 0) {
            isEdge = true;
          }
          list.forEach((item) {
            listKomisi.add(Komisi.fromJson(item));
          });
        }
      } catch (_) {}
      setState(() {
        loading = false;
        page++;
      });
    }
  }

  Widget loadingWidget() {
    return Center(
        child: SpinKitThreeBounce(
            color: packageName == 'com.lariz.mobile'
                ? Theme.of(context).secondaryHeaderColor
                : Theme.of(context).primaryColor,
            size: 35));
  }

  Widget listWidget() {
    if (listKomisi.length == 0) {
      return Center(
          child: SvgPicture.asset(
        'assets/img/finance.svg',
        width: MediaQuery.of(context).size.width * .45,
      ));
    } else {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: LazyLoadScrollView(
          onEndOfPage: () => getData(),
          scrollOffset: 200,
          child: ListView.separated(
            itemCount: listKomisi.length,
            separatorBuilder: (context, i) => Divider(
              indent: 15,
              endIndent: 15,
            ),
            itemBuilder: (context, i) {
              return Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(listKomisi[i].keterangan,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(formatRupiah(listKomisi[i].jumlah),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green))
                            ]),
                        SizedBox(height: 10),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(listKomisi[i].id.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                              Text(
                                  formatDate(listKomisi[i].createdAt,
                                      'd MMMM yyyy HH:mm:ss'),
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey))
                            ])
                      ]));
            },
          ),
        ),
      );
    }
  }

  Widget bottomWidget() {
    return Container(
      padding: EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(.50),
            offset: Offset(0, -1),
            blurRadius: 10)
      ], color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Total Komisi',
              style: TextStyle(fontSize: 11, color: Colors.grey)),
          SizedBox(height: 5),
          Text(formatRupiah(bloc.user.valueWrapper?.value.komisi),
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget fab() {
    return FloatingActionButton.extended(
      icon: Icon(Icons.navigate_next),
      label: Text('Tukar Komisi'),
      backgroundColor: packageName == 'com.lariz.mobile'
          ? Theme.of(context).secondaryHeaderColor
          : Theme.of(context).primaryColor,
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => TukarKomisi(bloc.user.valueWrapper?.value.komisi)));
      },
    );
  }
}

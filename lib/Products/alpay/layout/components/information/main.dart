// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mobile/Products/alpay/config.dart';
import 'package:mobile/Products/alpay/layout/components/information/information_loading.dart';
import 'package:mobile/Products/alpay/layout/components/information/Information_nothing.dart';
import 'package:mobile/Products/alpay/layout/components/information/information_label.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/models/info.dart';
import 'package:mobile/screen/info/info.dart';

class Information extends StatefulWidget {
  @override
  _InformationState createState() => _InformationState();
}

class _InformationState extends State<Information> {
  List<InfoModel> bannerInfo = [];
  List<dynamic> bannerLoading = [1, 2, 3];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchBannerInfo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  fetchBannerInfo() async {
    try {
      String url = '$apiUrl/info/list';

      FileInfo fileInfo = await DefaultCacheManager().getFileFromCache(url);
      if (fileInfo != null && fileInfo.validTill.isBefore(DateTime.now())) {
        return json.decode(fileInfo.file.readAsStringSync());
      }

      http.Response response = await http.get(Uri.parse(url), headers: {
        'Authorization': bloc.token.valueWrapper?.value,
      });

      if (response.statusCode == 200) {
        List<dynamic> datas = json.decode(response.body)['data'];
        bannerInfo = datas.map((e) => InfoModel.fromJson(e)).toList();

        setState(() {
          loading = false;
        });
      } else {
        String message = json.decode(response.body)['message'] ??
            'Terjadi kesalahan pada server';
        final snackBar = Alert(message, isError: true);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return InformationLoading();

    return bannerInfo.length == 0
        ? InformationNothing()
        : Container(
            padding: EdgeInsets.only(bottom: 18.0),
            decoration: BoxDecoration(color: Colors.white),
            height: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InformationLabel(
                  informations: bannerInfo,
                ),
                Expanded(
                  child: Container(
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            child: ListView.separated(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 6,
                              ),
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) {
                                InfoModel info = bannerInfo[index];
                                return InkWell(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => InfoPage(info),
                                    ),
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: 1.15,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade300,
                                            offset: const Offset(0.0, 1.1),
                                            blurRadius: 1.0,
                                            spreadRadius: 0.2,
                                          ),
                                          BoxShadow(
                                            color: Colors.grey.shade300,
                                            offset: const Offset(-0.1, -0.1),
                                            blurRadius: 1.0,
                                            spreadRadius: 0.2,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(15),
                                                topRight: Radius.circular(15),
                                              ),
                                              child: CachedNetworkImage(
                                                width: double.infinity,
                                                height: 160,
                                                imageUrl: info.icon,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: 18),
                                                Container(
                                                  child: Text(
                                                    info.title,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Container(
                                                  child: Text(
                                                    info.description,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const SizedBox(width: 15),
                              itemCount: bannerInfo.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}

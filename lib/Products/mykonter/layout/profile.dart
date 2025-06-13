// @dart=2.9

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/config.dart';
import 'package:mobile/index.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/profile/about_app.dart';
import 'package:mobile/screen/profile/cs/cs.dart';
import 'package:mobile/screen/profile/detail_profile.dart';
import 'package:mobile/screen/profile/downline/downline.dart';
import 'package:mobile/screen/profile/ganti_pin/ganti_pin.dart';
import 'package:mobile/screen/profile/komisi/riwayat_komisi.dart';
import 'package:mobile/screen/profile/my_qr.dart';
import 'package:mobile/screen/profile/print_settings.dart';
import 'package:mobile/screen/profile/reward/list_reward.dart';
import 'package:mobile/screen/profile/toko/edit_toko.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ProfilePopay extends StatefulWidget {
  @override
  _ProfilePopayState createState() => _ProfilePopayState();
}

class _ProfilePopayState extends State<ProfilePopay> {
  void keluar() async {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: Text('Apakah anda yakin ingin keluar?'),
              actions: <Widget>[
                TextButton(
                    onPressed: () async {
                      try {
                        http.get(Uri.parse('$apiUrl/user/logout'), headers: {
                          'Authorization': bloc.token.valueWrapper?.value
                        });
                      } catch (e) {}
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.clear();
                      Navigator.of(context, rootNavigator: true).pop();
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => PayuniApp()));
                    },
                    child: Text('YA')),
                TextButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: Text('BATAL'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));

    return ListView(
      padding: EdgeInsets.all(15),
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top),
        Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                border:
                    Border.all(color: Theme.of(context).primaryColor, width: 5),
                borderRadius: BorderRadius.circular(35),
              ),
              child: Icon(
                Icons.person_rounded,
                color: Theme.of(context).primaryColor,
                size: 60,
              ),
            ),
            SizedBox(width: 15),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bloc.user.valueWrapper?.value.nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 7),
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DetailProfile(),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Edit Profil',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.navigate_next_rounded,
                          color: Theme.of(context).textTheme.bodyText2.color,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        ListTile(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RiwayatKomisi(),
            ),
          ),
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Komisi Saya',
            style: TextStyle(fontSize: 15),
          ),
          trailing: Icon(Icons.navigate_next_rounded),
        ),
        Divider(height: 10),
        ListTile(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MyQR(),
            ),
          ),
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(
            'QrCode Saya',
            style: TextStyle(fontSize: 15),
          ),
          trailing: Icon(Icons.navigate_next_rounded),
        ),
        Divider(height: 10),
        ListTile(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => Downline(),
            ),
          ),
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Downline',
            style: TextStyle(fontSize: 15),
          ),
          trailing: Icon(Icons.navigate_next_rounded),
        ),
        Divider(height: 10),
        ListTile(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => GantiPin(),
            ),
          ),
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Ubah PIN',
            style: TextStyle(fontSize: 15),
          ),
          trailing: Icon(Icons.navigate_next_rounded),
        ),
        Divider(height: 10),
        ListTile(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PrintSettingsPage(),
            ),
          ),
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Pengaturan Printer',
            style: TextStyle(fontSize: 15),
          ),
          trailing: Icon(Icons.navigate_next_rounded),
        ),
        Divider(height: 10),
        ListTile(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EditToko(),
            ),
          ),
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Ubah Toko',
            style: TextStyle(fontSize: 15),
          ),
          trailing: Icon(Icons.navigate_next_rounded),
        ),
        Divider(height: 10),
        ListTile(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ListReward(),
            ),
          ),
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Hadiah',
            style: TextStyle(fontSize: 15),
          ),
          trailing: Icon(Icons.navigate_next_rounded),
        ),
        Divider(height: 10),
        ListTile(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CS(),
            ),
          ),
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Customer Service',
            style: TextStyle(fontSize: 15),
          ),
          trailing: Icon(Icons.navigate_next_rounded),
        ),
        Divider(height: 10),
        ListTile(
          onTap: () async {
            if (Platform.isAndroid) {
              String url =
                  'http://play.google.com/store/apps/details?id=$packageName';
              if (await canLaunch(url)) launch(url);
            } else {
              final InAppReview inAppReview = InAppReview.instance;
              print(await inAppReview.isAvailable());

              if (await inAppReview.isAvailable()) {
                inAppReview.requestReview();
              } else {
                inAppReview.openStoreListing();
              }
            }
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Beri Ulasan',
            style: TextStyle(fontSize: 15),
          ),
          trailing: Icon(Icons.navigate_next_rounded),
        ),
        Divider(height: 10),
        ListTile(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AboutAppPage(),
            ),
          ),
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Tentang Aplikasi',
            style: TextStyle(fontSize: 15),
          ),
          trailing: Icon(Icons.navigate_next_rounded),
        ),
        Divider(height: 10),
        ListTile(
          onTap: () {
            DefaultCacheManager().emptyCache().then((value) {
              showToast(context, 'Berhasil memperbarui konten');
            }).catchError((err) {
              showToast(context, 'Gagal memperbarui konten');
            });
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Perbarui Konten',
            style: TextStyle(fontSize: 15),
          ),
          trailing: Icon(Icons.navigate_next_rounded),
        ),
        Divider(height: 10),
        ListTile(
          onTap: keluar,
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Keluar',
            style: TextStyle(
              color: Colors.red,
              fontSize: 15,
            ),
          ),
          trailing: Icon(
            Icons.navigate_next_rounded,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}

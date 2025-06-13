// @dart=2.9

import 'dart:convert';

import 'package:division/division.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:mobile/Products/funmo/config.dart';
import 'package:mobile/Products/funmo/layout/invite/invite_wrapper.dart';
import 'package:mobile/Products/funmo/layout/invite/main.style.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/component/alert.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvitePage extends StatefulWidget {
  @override
  _InvitePageState createState() => _InvitePageState();
}

class _InvitePageState extends State<InvitePage> with TickerProviderStateMixin {
  bool loading = true;
  Uri inviteLink;

  TextEditingController url = TextEditingController();

  UserModel userInfo;

  static String urlInvite =
      configAppBloc.info.valueWrapper.value.domainInvite == ""
          ? prefixUrlInvite
          : 'https://${configAppBloc.info.valueWrapper.value.domainInvite}';
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  final DynamicLinkParameters param = DynamicLinkParameters(
      uriPrefix: urlInvite,
      link: Uri.parse('$urlInvite/${bloc.userId.valueWrapper?.value}'),
      androidParameters: AndroidParameters(
          packageName: configAppBloc.packagename.valueWrapper?.value,
          minimumVersion: 1),
      googleAnalyticsParameters: GoogleAnalyticsParameters(
          campaign: 'promo', medium: 'social', source: appName),
      socialMetaTagParameters: SocialMetaTagParameters(
          title:
              '$appName - ${configAppBloc.info.valueWrapper.value.kataInvite}',
          description: '${configAppBloc.info.valueWrapper.value.descInvite}',
          imageUrl:
              Uri.parse(configAppBloc.info.valueWrapper.value.imageInvite)));

  @override
  void initState() {
    super.initState();
    analitycs.pageView('/invite', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Invite Link',
    });
    createLink();
    getUserInfo();
  }

  @override
  void dispose() {
    url.dispose();
    super.dispose();
  }

  void createLink() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String link = prefs.getString('invite_link');

    if (link != null) {
      setState(() {
        loading = false;
        inviteLink = Uri.parse(link);
        url.text = inviteLink.toString();
      });
    } else {
      ShortDynamicLink shortLink = await dynamicLinks.buildShortLink(param);
      prefs.setString('invite_link', shortLink.shortUrl.toString());

      setState(() {
        loading = false;
        inviteLink = shortLink.shortUrl;
        url.text = inviteLink.toString();
      });
    }
  }

  void getUserInfo() async {
    try {
      http.Response response = await http.get(
        Uri.parse('$apiUrl/user/info'),
        headers: {
          'authorization': bloc.token.valueWrapper?.value,
        },
      );

      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          userInfo = UserModel.fromJson(data['data']);
        });

        if (userInfo.inviteCode == '' || userInfo.inviteCode == null) {
          SnackBar snackBar = SnackBar(
              content: Text('Silahkan generate kode referal terlebih dahulu!'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          if (Hive.box('ref-code').values.isEmpty) {
            Hive.box('ref-code').add(data['data']);
          }
        }
      } else {
        SnackBar snackBar = Alert(data['message'], isError: true);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print(e);
    }
  }

  void share() {
    String title = configAppBloc.namaApp.valueWrapper?.value;
    String desc =
        'Mau beli pulsa, topup e-wallet, atau bayar tagihan? Tapi takut mahal? Ayo daftar menjadi member ${configAppBloc.namaApp.valueWrapper?.value} untuk bertransaksi tanpa takut dompet kering! Klik ${inviteLink.toString()}';
    Share.share(desc, subject: title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Undang Teman'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: share,
            icon: Icon(Icons.share),
          ),
        ],
      ),
      body: loading
          ? Center(
              child: SpinKitThreeBounce(
                  color: Theme.of(context).primaryColor, size: 35))
          : Parent(
              style: InviteMainStyle.bgGradient,
              child: SingleChildScrollView(
                child: InviteWrapper(
                  inviteLink: inviteLink,
                  loading: loading,
                  getUserInfo: getUserInfo,
                ),
              ),
            ),
    );
  }
}

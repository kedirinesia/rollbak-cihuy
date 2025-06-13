// @dart=2.9

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/config.dart';
import 'package:mobile/screen/profile/invite/invite.dart';
import 'package:mobile/bloc/Bloc.dart' show bloc;
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class InvitePageController extends State<InvitePage>
    with TickerProviderStateMixin {
  static String urlInvite =
      configAppBloc.info.valueWrapper?.value.domainInvite == ""
          ? prefixUrlInvite
          : 'https://${configAppBloc.info.valueWrapper?.value.domainInvite}';
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
              '$appName - ${configAppBloc.info.valueWrapper?.value.kataInvite}',
          description: '${configAppBloc.info.valueWrapper?.value.descInvite}',
          imageUrl:
              Uri.parse(configAppBloc.info.valueWrapper?.value.imageInvite)));

  bool loading = true;
  Uri inviteLink;
  TextEditingController url = TextEditingController();

  @override
  void initState() {
    createLink();
    super.initState();
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

  void share() {
    String title = configAppBloc.namaApp.valueWrapper?.value;
    String desc =
        'Mau beli pulsa, topup e-wallet, atau bayar tagihan? Tapi takut mahal? Ayo daftar menjadi member ${configAppBloc.namaApp.valueWrapper?.value} untuk bertransaksi tanpa takut dompet kering! Klik ${inviteLink.toString()}';
    Share.share(desc, subject: title);
  }
}

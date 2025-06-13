// @dart=2.9

import 'package:badges/badges.dart' as BadgeModule;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/screen/marketplace/cart.dart';

class StickyNavBar extends StatelessWidget {
  final bool isTransparent;

  const StickyNavBar({Key key, this.isTransparent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
        left: MediaQuery.of(context).padding.left + 14,
        right: MediaQuery.of(context).padding.right + 14,
      ),
      height: (MediaQuery.of(context).padding.top + 50),
      decoration: BoxDecoration(
        color: !isTransparent
            ? Theme.of(context).primaryColor.withOpacity(.15)
            : Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CachedNetworkImage(
                    imageUrl: 'https://dokumen.payuni.co.id/logo/hexapay/font.png',
                    width: 100.0,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pushNamed('/notifikasi'),
                child: Container(
                  height: 43.0,
                  child: SvgPicture.asset(
                    "assets/img/payuni2/bell.svg",
                    height: 25.0,
                    width: 25.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

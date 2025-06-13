// @dart=2.9

import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/Products/payuni2/layout/components/menu_tools/menu_tools_more.dart';
import 'package:mobile/Products/payuni2/layout/components/menu_tools/menu_tools_order_history.style.dart';

import 'package:mobile/screen/history/history.dart';
// import 'package:mobile/Products/payuni2/layout/history.dart';

class MenuToolsOrderHistory extends StatelessWidget {
  const MenuToolsOrderHistory({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => HistoryPage()));
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Parent(
              style: MenuToolsOrderHistoryStyle.iconWrapper,
              child: SvgPicture.asset(
                "assets/img/payuni2/receipt-time.svg",
                color: Theme.of(context).primaryColor,
                width: 22,
              ),
            ),
            Column(
              children: [
                Txt(
                  'Riwayat',
                  style: MenuToolsOrderHistoryStyle.text.clone()..fontSize(11),
                ),
                Txt(
                  'Pesanan',
                  style: MenuToolsOrderHistoryStyle.text.clone()..fontSize(11),
                ),
              ],
            ),
            MenuToolsMore()
          ],
        ),
      ),
    );
  }
}

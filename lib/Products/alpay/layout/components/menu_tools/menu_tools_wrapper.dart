// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/Products/alpay/layout/components/menu_tools/menu_tools_balance_info.dart';
import 'package:mobile/Products/alpay/layout/components/menu_tools/menu_tools_order_history.dart';

class MenuWrapper extends StatelessWidget {
  const MenuWrapper({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          MenuToolsBalanceInfo(),
          Container(
            margin: const EdgeInsets.only(right: 10.0),
            width: 1.5,
            height: 32.0,
            color: Colors.grey.shade300,
          ),
          MenuToolsOrderHistory()
        ],
      ),
    );
  }
}

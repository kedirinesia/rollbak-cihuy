// @dart=2.9

import 'package:division/division.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/Products/delta/layout/components/menu_tools/menu_tools_balance_info.style.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/modules.dart';

class MenuToolsBalanceInfo extends StatelessWidget {
  const MenuToolsBalanceInfo({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed('/topup');
        },
        child: Row(
          children: [
            Container(
              child: Row(
                children: [
                  Parent(
                    style: MenuToolsBalanceInfoStyle.iconWrapper,
                    child: SvgPicture.asset(
                      "assets/img/payuni2/wallet.svg",
                      color: Theme.of(context).primaryColor,
                      width: 22,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Txt(
                            formatRupiah(bloc.user.valueWrapper?.value.saldo),
                            style: MenuToolsBalanceInfoStyle.text,
                          ),
                          SizedBox(height: 2.0),
                          Txt(
                            'Topup Saldo',
                            style: MenuToolsBalanceInfoStyle.text.clone()
                              ..fontSize(11)
                              ..fontWeight(FontWeight.normal)
                              ..textColor(Theme.of(context).primaryColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

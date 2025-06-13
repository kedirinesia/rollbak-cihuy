// @dart=2.9

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mobile/Products/hexapay2/layout/qris/qris_page.dart';
import 'package:mobile/Products/hexapay2/layout/topup.dart';
import 'package:mobile/Products/hexapay2/layout/transfer.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/history/history.dart';
import 'package:mobile/screen/profile/reward/list_reward.dart';

class DashboardPanel extends StatefulWidget {
  const DashboardPanel({Key key}) : super(key: key);

  @override
  State<DashboardPanel> createState() => _DashboardPanelState();
}

class _DashboardPanelState extends State<DashboardPanel> {
  bool _showBalance = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(.75),
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(.5),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => setState(() {
                    _showBalance = !_showBalance;
                  }),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Total Saldo',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(
                        _showBalance ? Icons.visibility_off : Icons.visibility,
                        size: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        _showBalance
                            ? formatRupiah(
                                bloc.user?.valueWrapper?.value?.saldo ?? 0)
                            : 'Rp *****',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ListReward(),
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(width: 10),
                            Text(
                              'Hexapay Points',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.navigate_next,
                              size: 18,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TopupPage(),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle,
                        size: 28,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Top Up',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => TransferManuPage()));
                  },
                  // onTap: () => Navigator.of(context).pushNamed('/transfer'),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Transform.rotate(
                        angle: -90 * math.pi / 180,
                        child: Icon(
                          Icons.arrow_circle_right,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Transfer',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  // onTap: () {
                  //   if (bloc.user.valueWrapper?.value?.enableWithdraw ??
                  //       false) {
                  //     Navigator.of(context).pushNamed('/withdraw');
                  //   } else {
                  //     showToast(
                  //       context,
                  //       'Anda tidak dapat melakukan penarikan saldo',
                  //     );
                  //   }
                  // },
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => QrisPage()));
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_2_rounded,
                        size: 28,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'QRIS',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => HistoryPage(),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.article,
                        size: 28,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'History',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

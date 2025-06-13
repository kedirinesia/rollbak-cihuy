// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/models/user.dart';

class PanelSaldo extends StatefulWidget {
  @override
  _PanelSaldoState createState() => _PanelSaldoState();
}

class _PanelSaldoState extends State<PanelSaldo>
    with SingleTickerProviderStateMixin {
  AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade300,
                  width: 2,
                ),
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 2,
                ),
                left: BorderSide(
                  color: Colors.grey.shade300,
                  width: 2,
                ),
                right: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 15,
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  'Rp',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(width: 5),
                Text(formatNumber(bloc.user.valueWrapper?.value.saldo)),
                SizedBox(width: 5),
                InkWell(
                  onTap: () {
                    updateUserInfo();
                    _rotationController.forward(from: 0);
                    showToast(context, 'Berhasil memperbarui data');
                    setState(() {});
                  },
                  child: RotationTransition(
                    turns: Tween(begin: 0.0, end: 1.0)
                        .animate(_rotationController),
                    child: Container(
                      width: 18,
                      height: 18,
                      // padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.refresh,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 50,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade300,
                  width: 2,
                ),
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 2,
                ),
                left: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
                right: BorderSide(
                  color: Colors.grey.shade300,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.monetization_on_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 15,
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Text(
                    '${formatNumber(bloc.user.valueWrapper?.value.poin)} Poin'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


// @dart=2.9

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/config.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/transfer_saldo/transfer_saldo.dart';
import './home3.dart';

abstract class Home3Model extends State<Home3App>
    with TickerProviderStateMixin {
  AnimationController _animationController;

  bool isTransferBank = false;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(duration: Duration(seconds: 4), vsync: this);
  }

  Widget cardButton() {
    List<String> packageList = [
      'com.flobamora.app',
    ];

    packageList.forEach((e) {
      if (e == packageName) {
        setState(() {
          isTransferBank = true;
        });
      }
    });

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          margin: EdgeInsets.only(right: 20),
          child: InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => TransferSaldo('')));
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                  backgroundColor: Colors.transparent,
                ),
                Text(
                  'Kirim Saldo',
                  textScaleFactor: 0.7,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
        bloc.user.valueWrapper?.value.enableWithdraw
            ? Container(
                margin: EdgeInsets.only(right: 20),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed('/withdraw');
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        child: Icon(
                          Icons.account_balance,
                          color: Colors.white,
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                      isTransferBank
                          ? Text(
                              'Transfer Bank',
                              textScaleFactor: 0.7,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          : Text(
                              'Transfer Bank',
                              textScaleFactor: 0.7,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                    ],
                  ),
                ),
              )
            : SizedBox(),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              AnimatedBuilder(
                animation: _animationController,
                builder: (BuildContext context, Widget child) {
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) => RotationTransition(
                      turns: _animationController,
                      child: GestureDetector(
                          onTap: () async {
                            try {
                              _animationController.fling().then((a) {
                                _animationController.value = 0;
                              });

                              await updateUserInfo();

                              showToast(context, 'Berhasil memperbarui saldo');

                              setState(() {});
                            } catch (e) {
                              showToast(context, 'Gagal memperbarui saldo');
                            }
                          },
                          child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Icon(
                                Icons.refresh,
                                color: Colors.white,
                              ))),
                    ),
                  );
                },
              ),
              MaterialButton(
                child: Text(
                  "TOP UP",
                  style: TextStyle(
                      color: Theme.of(context).buttonColor, fontSize: 12.0),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                color: Theme.of(context).secondaryHeaderColor,
                onPressed: () {
                  Navigator.of(context).pushNamed('/topup');
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget balanceInfo() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Saldo',
                      textScaleFactor: 0.7,
                      style: TextStyle(
                        color: Colors.grey[200],
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      )),
                  // SizedBox(height: 10.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Text(
                          "Rp ",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                          child: Text(
                        formatNumber(bloc.saldo.valueWrapper?.value),
                        maxLines: 2,
                        textScaleFactor: 1.5,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text('Poin ',
                          textScaleFactor: 0.7,
                          style: TextStyle(
                            color: Colors.grey[200],
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          )),
                      Text(
                        NumberFormat.decimalPattern('id')
                            .format(bloc.poin.valueWrapper?.value),
                        textScaleFactor: 0.7,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              Icon(
                Icons.person,
                color: Colors.white,
              ),
              SizedBox(height: 8),
              Text(
                bloc.username.valueWrapper?.value != null
                    ? bloc.username.valueWrapper?.value.split(' ')[0]
                    : 'Username',
                style: TextStyle(color: Colors.white),
              )
            ],
          )
        ],
      ),
    );
  }
}

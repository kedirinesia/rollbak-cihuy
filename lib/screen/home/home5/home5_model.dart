// @dart=2.9

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/transfer_saldo/transfer_saldo.dart';
import './home5.dart';

abstract class Home5Model extends State<Home5App>
    with TickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(duration: Duration(seconds: 4), vsync: this);
  }

  Widget cardButton() {
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
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              AnimatedBuilder(
                animation: _animationController,
                builder: (BuildContext context, Widget child) {
                  return RotationTransition(
                      turns: _animationController,
                      child: IconButton(
                        icon: Icon(
                          Icons.refresh,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          _animationController.fling().then((a) {
                            _animationController.value = 0;
                          });

                          updateUserInfo();
                          setState(() {});
                        },
                      ));
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
              IconButton(
                icon: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
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

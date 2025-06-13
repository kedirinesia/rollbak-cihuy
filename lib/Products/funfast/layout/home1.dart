// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/component/rewards.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/profile/cs/cs.dart';
import 'package:mobile/screen/transfer_saldo/transfer_saldo.dart';
import '../../../component/card_info.dart';
import '../../../component/carousel-depan.dart';
// import '../../../component/menudepan.dart';
import 'package:mobile/Products/funfast/layout/components/menudepan.dart';

class Home1App extends StatefulWidget {
  @override
  _Home1AppState createState() => _Home1AppState();
}

class _Home1AppState extends State<Home1App> with TickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(duration: Duration(seconds: 4), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 3,
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.only(
                  bottomLeft: Radius.elliptical(150, 0),
                  bottomRight: Radius.elliptical(250, 200)),
              gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(.7)
                  ],
                  begin: AlignmentDirectional.topCenter,
                  end: AlignmentDirectional.bottomCenter),
            ),
          ),
          Container(
              padding: EdgeInsets.all(15.0),
              margin: EdgeInsets.only(top: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(bloc.username.valueWrapper?.value,
                      style: TextStyle(fontSize: 15.0, color: Colors.white)),
                  // SizedBox(height: 10.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text('Rp',
                                  style: TextStyle(
                                      fontSize: 12.0, color: Colors.white)),
                              SizedBox(width: 5.0),
                              Text(
                                  NumberFormat.decimalPattern('id')
                                      .format(bloc.saldo.valueWrapper?.value),
                                  style: TextStyle(
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor)),
                            ],
                          ),
                          Text(
                              'Poin ' +
                                  NumberFormat.decimalPattern('id')
                                      .format(bloc.poin.valueWrapper?.value),
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.white)),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          AnimatedBuilder(
                            animation: animationController,
                            builder: (BuildContext context, Widget child) {
                              return RotationTransition(
                                  turns: animationController,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.refresh,
                                      color: Colors.white,
                                    ),
                                    onPressed: () async {
                                      animationController.fling().then((a) {
                                        animationController.value = 0;
                                      });

                                      await updateUserInfo();
                                      setState(() {});
                                    },
                                  ));
                            },
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamed('/topup');
                            },
                            child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 10.0),
                                decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Text('Topup',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 12.0))),
                          ),
                        ],
                      )
                    ],
                  ),

                  MenuGrid(),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(.1),
                              blurRadius: 10.0,
                              offset: Offset(10, 5))
                        ]),
                    child: MenuDepan(grid: 5, gradient: true),
                  ),

                  SizedBox(height: 20.0),
                  CarouselDepan(),
                  SizedBox(height: 20.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Info', style: TextStyle(fontSize: 20.0)),
                      Text(
                          'Mengenal Lebih Jauh Aplikasi ${configAppBloc.namaApp.valueWrapper?.value}')
                    ],
                  ),
                  CardInfo(),
                  SizedBox(height: 20.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Hadiah Unggulan', style: TextStyle(fontSize: 20.0)),
                      Text(
                          'Reward Akan Di Berikan Ke Member ${configAppBloc.namaApp.valueWrapper?.value}')
                    ],
                  ),
                  SizedBox(height: 20.0),
                  RewardComponent(),
                ],
              ))
        ],
      ),
    );
  }
}

class MenuGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 0.0),
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(.2),
                offset: Offset(5, 10),
                blurRadius: 10.0),
            BoxShadow(
                color: Theme.of(context).secondaryHeaderColor,
                offset: Offset(0, 5),
                blurRadius: 0)
          ]),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed('/withdraw');
            },
            child: Container(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      gradient: LinearGradient(
                          begin: AlignmentDirectional.topCenter,
                          end: AlignmentDirectional.bottomEnd,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(0.0),
                            Theme.of(context).primaryColor.withOpacity(.0),
                            Theme.of(context).primaryColor.withOpacity(0.0)
                          ]),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Image.asset('assets/img/funmo/withdraw1.png',
                        width: 20.0),
                  ),
                  SizedBox(height: 5.0),
                  Text('Withdraw',
                      style:
                          TextStyle(fontSize: 12.0, color: Theme.of(context).primaryColor))
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              return Navigator.of(context).push(PageTransition(
                  child: TransferSaldo(''),
                  type: PageTransitionType.rippleRightUp,
                  duration: Duration(seconds: 1)));
            },
            child: Container(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      gradient: LinearGradient(
                          begin: AlignmentDirectional.topCenter,
                          end: AlignmentDirectional.bottomEnd,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(0.0),
                            Theme.of(context).primaryColor.withOpacity(.0),
                            Theme.of(context).primaryColor.withOpacity(0.0)
                          ]),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Image.asset('assets/img/funmo/tfsaldo.png', width: 20.0),
                  ),
                  SizedBox(height: 5.0),
                  Text('Kirim',
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Theme.of(context).primaryColor))
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed('/rewards');
            },
            child: Container(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      gradient: LinearGradient(
                          begin: AlignmentDirectional.topCenter,
                          end: AlignmentDirectional.bottomEnd,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(0.0),
                            Theme.of(context).primaryColor.withOpacity(.0),
                            Theme.of(context).primaryColor.withOpacity(0.0)
                          ]),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child:
                        Image.asset('assets/img/funmo/reward.png', fit: BoxFit.cover),
                  ),
                  SizedBox(height: 5.0),
                  Text('Rewards',
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Theme.of(context).primaryColor))
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed('/komisi');
            },
            child: Container(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      gradient: LinearGradient(
                          begin: AlignmentDirectional.topCenter,
                          end: AlignmentDirectional.bottomEnd,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(0.0),
                            Theme.of(context).primaryColor.withOpacity(.0),
                            Theme.of(context).primaryColor.withOpacity(0.0)
                          ]),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Image.asset('assets/img/funmo/komisi.png', width: 20.0),
                  ),
                  SizedBox(height: 5.0),
                  Text('Komisi',
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Theme.of(context).primaryColor))
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              return Navigator.of(context).push(PageTransition(
                  child: CS(),
                  type: PageTransitionType.rippleRightUp,
                  duration: Duration(seconds: 1)));
            },
            child: Container(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      gradient: LinearGradient(
                          begin: AlignmentDirectional.topCenter,
                          end: AlignmentDirectional.bottomEnd,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(0.0),
                            Theme.of(context).primaryColor.withOpacity(.0),
                            Theme.of(context).primaryColor.withOpacity(0.0)
                          ]),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Image.asset('assets/img/funmo/cs.png', width: 20.0),
                  ),
                  SizedBox(height: 5.0),
                  Text('Bantuan',
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Theme.of(context).primaryColor))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

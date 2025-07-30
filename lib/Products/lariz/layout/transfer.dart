// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/lariz/layout/transfer-bank/daftar_transfer.dart';
import 'package:mobile/bloc/Bloc.dart';

class TransferPagePopay extends StatefulWidget {
  @override
  _TransferPagePopayState createState() => _TransferPagePopayState();
}

class _TransferPagePopayState extends State<TransferPagePopay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          // Container(
          //   height: 100.0,
          //   width: double.infinity,
          //   decoration: BoxDecoration(
          //       image: DecorationImage(
          //           image: CachedNetworkImageProvider(
          //               configAppBloc.iconApp.valueWrapper?.value['imgAppBar']),
          //           fit: BoxFit.fill)),
          // ),
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 3,
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.only(
                  bottomLeft: Radius.elliptical(150, 0),
                  bottomRight: Radius.elliptical(250, 200)),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).secondaryHeaderColor,
                  Theme.of(context).secondaryHeaderColor.withOpacity(.7)
                ],
                begin: AlignmentDirectional.topCenter,
                end: AlignmentDirectional.bottomCenter,
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              title: Text('Transfer'),
            ),
            body: ListView(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              children: <Widget>[
                SizedBox(height: 20.0),
                Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(.2),
                            offset: Offset(5, 10))
                      ]),
                  child: ListTile(
                    onTap: () => Navigator.of(context).pushNamed('/transfer'),
                    leading: CircleAvatar(
                      child: CachedNetworkImage(
                          imageUrl:
                              'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpayku%2Fdigital-wallet%20(2).png?alt=media&token=60a6e1f0-e71b-478f-8ce3-d44f9fd32fea'),
                      backgroundColor: Colors.transparent,
                    ),
                    title: Text('Transfer ke Lariz',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: Text('Kirim Saldo ke Member Lariz',
                        style:
                            TextStyle(fontSize: 12.0, color: Colors.grey[700])),
                    trailing: Icon(Icons.navigate_next),
                  ),
                ),
                bloc.user.valueWrapper?.value.enableWithdraw
                    ? Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 10.0,
                                  color: Colors.black.withOpacity(.2),
                                  offset: Offset(5, 10))
                            ]),
                        child: ListTile(
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => DaftarTransferPage())),
                          leading: CircleAvatar(
                            child: CachedNetworkImage(
                                imageUrl:
                                    'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpayku%2Fmoney-transfer%20(2).png?alt=media&token=9c262e86-1083-49f6-8605-6e84fc68322b'),
                            backgroundColor: Colors.transparent,
                          ),
                          title: Text('Transfer ke Bank',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold)),
                          subtitle: Text('Kirim Saldo ke Rekening Bank',
                              style: TextStyle(
                                  fontSize: 12.0, color: Colors.grey[700])),
                          trailing: Icon(Icons.navigate_next),
                        ),
                      )
                    : Container()
              ],
            ),
          )
        ],
      ),
    );
  }
}

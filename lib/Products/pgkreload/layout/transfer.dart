// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';

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
          Container(
            height: 100.0,
            width: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: CachedNetworkImageProvider(configAppBloc
                        .iconApp.valueWrapper?.value['imageAppbar']),
                    fit: BoxFit.fill)),
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
                              'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2FPayuni%2F013-credit%20card.png?alt=media&token=29dd8c54-b7a6-4eca-9b73-706159e27f1d'),
                      backgroundColor: Colors.transparent,
                    ),
                    title: Text('Transfer ke PGK Reload',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: Text('Kirim Saldo ke Sesama Member PGK Reload',
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
                          onTap: () =>
                              Navigator.of(context).pushNamed('/withdraw'),
                          leading: CircleAvatar(
                            child: CachedNetworkImage(
                                imageUrl:
                                    'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2FPayuni%2F008-card%20payment.png?alt=media&token=d2a1840f-908f-4879-9e42-756b6fff4f64'),
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

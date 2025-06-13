// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/payment-list.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/topup/bank/bank-controller.dart';

class TopupBank extends StatefulWidget {
  final PaymentModel payment;
  TopupBank(this.payment);

  @override
  _TopupBankState createState() => _TopupBankState();
}

class _TopupBankState extends BankController with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    analitycs.pageView('/bank/', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Bank',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.payment.title),
          centerTitle: true,
          elevation: 0,
          backgroundColor: packageName == 'com.lariz.mobile'
              ? Theme.of(context).secondaryHeaderColor
              : Theme.of(context).primaryColor,
        ),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            child: loading
                ? Center(
                    child: SpinKitThreeBounce(
                        color: packageName == 'com.lariz.mobile'
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).primaryColor,
                        size: 35))
                : ListView(padding: EdgeInsets.all(20), children: <Widget>[
                    SizedBox(height: MediaQuery.of(context).size.height * .10),
                    SvgPicture.asset('assets/img/img_topup.svg',
                        width: MediaQuery.of(context).size.width * .5),
                    SizedBox(height: MediaQuery.of(context).size.height * .05),
                    TextFormField(
                      controller: nominal,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Nominal',
                          prefixText: 'Rp ',
                          isDense: true),
                      onChanged: (value) {
                        int amount = int.tryParse(nominal.text
                                .replaceAll(RegExp('[^0-9]'), '')) ??
                            0;
                        nominal.text = FormatRupiah(amount);
                        nominal.selection = TextSelection.fromPosition(
                            TextPosition(offset: nominal.text.length));
                      },
                    ),
                  ])),
        floatingActionButton: loading
            ? null
            : FloatingActionButton.extended(
                backgroundColor: packageName == 'com.lariz.mobile'
                    ? Theme.of(context).secondaryHeaderColor
                    : Theme.of(context).primaryColor,
                icon: Icon(Icons.navigate_next),
                label: Text('Lanjut'),
                onPressed: () => topup()));
  }
}

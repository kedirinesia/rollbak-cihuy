
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/payment-list.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/topup/bank/bank-controller.dart';
import 'package:mobile/utils/debug_helper.dart';

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
    DebugHelper.debugPrint('🔍 [TOPUP BANK] initState called');
    DebugHelper.debugPrint('🔍 [TOPUP BANK] Payment method: ${widget.payment.title}');
    DebugHelper.debugPrint('🔍 [TOPUP BANK] Payment type: ${widget.payment.type}');
    DebugHelper.debugPrint('🔍 [TOPUP BANK] Payment channel: ${widget.payment.channel}');
    DebugHelper.debugPrint('🔍 [TOPUP BANK] User ID: ${bloc.userId.valueWrapper?.value}');
    
    var analyticsData = {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Bank',
    };
    DebugHelper.debugPrint('🔍 [TOPUP BANK] Analytics payload: ${analyticsData.toString()}');
    analitycs.pageView('/bank/', analyticsData);
    DebugHelper.debugPrint('🔍 [TOPUP BANK] Analytics page view sent');
  }

  @override
  Widget build(BuildContext context) {
    DebugHelper.debugPrint('🔍 [TOPUP BANK] build() called');
    DebugHelper.debugPrint('🔍 [TOPUP BANK] Loading state: $loading');
    DebugHelper.debugPrint('🔍 [TOPUP BANK] Payment: ${widget.payment.title} (${widget.payment.type})');
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
                        DebugHelper.debugPrint('🔍 [TOPUP BANK] Nominal field changed: $value');
                        int amount = int.tryParse(nominal.text
                                .replaceAll(RegExp('[^0-9]'), '')) ??
                            0;
                        DebugHelper.debugPrint('🔍 [TOPUP BANK] Parsed amount: $amount');
                        nominal.text = FormatRupiah(amount);
                        DebugHelper.debugPrint('🔍 [TOPUP BANK] Formatted nominal: ${nominal.text}');
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
                onPressed: () {
                  DebugHelper.debugPrint('🔍 [TOPUP BANK] Lanjut button pressed');
                  DebugHelper.debugPrint('🔍 [TOPUP BANK] Current nominal: ${nominal.text}');
                  topup();
                }));
  }
}

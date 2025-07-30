// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/models/payment-list.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/provider/api.dart';
import 'package:mobile/Products/eralink/layout/qris.dart';
import 'package:mobile/Products/eralink/layout/topup/bank/bank.dart';
import 'package:mobile/Products/eralink/layout/topup/channel/channel.dart';
import 'package:mobile/Products/eralink/layout/topup/merchant/merchant.dart';
import 'package:mobile/Products/eralink/layout/topup/qris/qris.dart';
import 'package:mobile/Products/eralink/layout/topup/topup.dart';
import 'package:mobile/Products/eralink/layout/topup/va/va.dart';

abstract class TopupController extends State<TopupPage> {
  bool loading = true;
  List<PaymentModel> listPayment = [];

  @override
  void initState() {
    super.initState();
    analitycs.pageView('/topup/controller/', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Topup Controller',
    });
    fetchData();
  }

  fetchData() async {
    try {
      List<dynamic> datas = await api.get('/deposit/methode', cache: false);
      listPayment = datas.map((e) => PaymentModel.fromJson(e)).toList();

      if (configAppBloc.qrisStaticOnTopup.valueWrapper?.value ?? false) {
        PaymentModel qrisStatic = PaymentModel(
          id: '',
          title: 'QRIS',
          description: 'Transfer saldo menggunakan QRIS langsung ke akun ini',
          admin: {
            'nominal': 0,
            'satuan': 'rupiah',
          },
          channel: 'qris_static',
          icon:
              'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/assets%2Ficons%2Fdeposit%2Fqris.png?alt=media&token=4cc8167c-22d9-4d3d-93fd-a6c2ddcdd649',
          type: 9,
        );

        listPayment.add(qrisStatic);
      }
    } catch (e) {
      listPayment = [];
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  onTapMenu(PaymentModel payment) {
    if (payment.type == 1 || payment.type == 2) {
      return Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => TopupBank(payment)));
    } else if (payment.type == 5) {
      return Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => TopupVA()));
    } else if (payment.type == 4 || payment.type == 6) {
      return Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => TopupMerchant(payment)));
    } else if (payment.type == 7) {
      return Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => TopupChannel(payment)));
    } else if (payment.type == 8) {
      return Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => QrisTopup()));
    } else if (payment.type == 9) {
      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              configAppBloc.layoutApp.valueWrapper?.value['qris-static'] ??
              MyQrisPage(),
        ),
      );
    }
  }
}

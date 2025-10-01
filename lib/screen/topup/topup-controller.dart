
import 'package:flutter/material.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/models/payment-list.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/provider/api.dart';
import 'package:mobile/screen/profile/my_qris.dart';
import 'package:mobile/screen/topup/bank/bank.dart';
import 'package:mobile/screen/topup/channel/channel.dart';
import 'package:mobile/screen/topup/merchant/merchant.dart';
import 'package:mobile/screen/topup/qris/qris.dart';
import 'package:mobile/screen/topup/topup.dart';
import 'package:mobile/screen/topup/va/va.dart';
import 'package:mobile/utils/debug_helper.dart';

abstract class TopupController extends State<TopupPage> {
  bool loading = true;
  List<PaymentModel> listPayment = [];

  @override
  void initState() {
    super.initState();
    DebugHelper.debugPrint('🔍 [TOPUP] initState called');
    DebugHelper.debugPrint('🔍 [TOPUP] User ID: ${bloc.userId.valueWrapper?.value}');
    
    var analyticsData = {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Topup Controller',
    };
    DebugHelper.debugPrint('🔍 [TOPUP] Analytics payload: ${analyticsData.toString()}');
    analitycs.pageView('/topup/controller/', analyticsData);
    DebugHelper.debugPrint('🔍 [TOPUP] Analytics page view sent');
    
    fetchData();
  }

  fetchData() async {
    DebugHelper.debugPrint('🔍 [TOPUP] fetchData() called');
    DebugHelper.debugPrint('🔍 [TOPUP] Loading payment methods from API');
    
    try {
      DebugHelper.debugPrint('🔍 [TOPUP] Making API call to /deposit/methode');
      List<dynamic> datas = await api.get('/deposit/methode', cache: false);
      DebugHelper.debugPrint('🔍 [TOPUP] API response received');
      DebugHelper.debugPrint('🔍 [TOPUP] Raw API response data: ${datas.toString()}');
      DebugHelper.debugPrint('🔍 [TOPUP] Number of payment methods received: ${datas.length}');
      
      listPayment = datas.map((e) {
        DebugHelper.debugPrint('🔍 [TOPUP] Processing payment method: ${e.toString()}');
        return PaymentModel.fromJson(e);
      }).toList();
      
      DebugHelper.debugPrint('🔍 [TOPUP] Payment methods processed: ${listPayment.length}');
      DebugHelper.debugPrint('🔍 [TOPUP] Payment methods details:');
      listPayment.forEach((payment) {
        DebugHelper.debugPrint('🔍 [TOPUP] - ID: ${payment.id}, Title: ${payment.title}, Type: ${payment.type}, Channel: ${payment.channel}');
      });

      DebugHelper.debugPrint('🔍 [TOPUP] Checking QRIS static configuration');
      DebugHelper.debugPrint('🔍 [TOPUP] QRIS static enabled: ${configAppBloc.qrisStaticOnTopup.valueWrapper?.value ?? false}');
      
      if (configAppBloc.qrisStaticOnTopup.valueWrapper?.value ?? false) {
        DebugHelper.debugPrint('🔍 [TOPUP] Adding QRIS static payment method');
        PaymentModel qrisStatic = PaymentModel(
          id: '',
          title: 'QRIS',
          description: 'Transfer saldo menggunakan QRIS langsung ke akun ini',
          admin: {
            'admin': 0,
            'nominal': 0,
            'satuan': 'rupiah',
          },
          channel: 'qris_static',
          icon:
              'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/assets%2Ficons%2Fdeposit%2Fqris.png?alt=media&token=4cc8167c-22d9-4d3d-93fd-a6c2ddcdd649',
          type: 9,
          cover: '',
          admin_trx: null,
        );

        listPayment.add(qrisStatic);
        DebugHelper.debugPrint('🔍 [TOPUP] QRIS static added, total methods: ${listPayment.length}');
      }
    } catch (e) {
      DebugHelper.debugPrint('🔍 [TOPUP] Error fetching payment methods: $e');
      listPayment = [];
    } finally {
      DebugHelper.debugPrint('🔍 [TOPUP] Setting loading to false');
      setState(() {
        loading = false;
      });
      DebugHelper.debugPrint('🔍 [TOPUP] State updated, loading completed');
    }
  }

  onTapMenu(PaymentModel payment) {
    DebugHelper.debugPrint('🔍 [TOPUP] onTapMenu called');
    DebugHelper.debugPrint('🔍 [TOPUP] Selected payment method:');
    DebugHelper.debugPrint('🔍 [TOPUP] - ID: ${payment.id}');
    DebugHelper.debugPrint('🔍 [TOPUP] - Title: ${payment.title}');
    DebugHelper.debugPrint('🔍 [TOPUP] - Type: ${payment.type}');
    DebugHelper.debugPrint('🔍 [TOPUP] - Channel: ${payment.channel}');
    DebugHelper.debugPrint('🔍 [TOPUP] - Description: ${payment.description}');
    DebugHelper.debugPrint('🔍 [TOPUP] - Admin: ${payment.admin}');
    
    if (payment.type == 1 || payment.type == 2) {
      DebugHelper.debugPrint('🔍 [TOPUP] Navigating to TopupBank (Bank/E-wallet transfer)');
      return Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => TopupBank(payment)));
    } else if (payment.type == 5) {
      DebugHelper.debugPrint('🔍 [TOPUP] Navigating to TopupVA (Virtual Account)');
      return Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => TopupVA()));
    } else if (payment.type == 4 || payment.type == 6) {
      DebugHelper.debugPrint('🔍 [TOPUP] Navigating to TopupMerchant (Merchant/Agen)');
      return Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => TopupMerchant(payment)));
    } else if (payment.type == 7) {
      DebugHelper.debugPrint('🔍 [TOPUP] Navigating to TopupChannel (Channel)');
      return Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => TopupChannel(payment)));
    } else if (payment.type == 8) {
      DebugHelper.debugPrint('🔍 [TOPUP] Navigating to QrisTopup (QRIS)');
      return Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => QrisTopup()));
    } else if (payment.type == 9) {
      DebugHelper.debugPrint('🔍 [TOPUP] Navigating to QRIS Static page');
      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              configAppBloc.layoutApp.valueWrapper?.value['qris-static'] ??
              MyQrisPage(),
        ),
      );
    } else {
      DebugHelper.debugPrint('🔍 [TOPUP] Unknown payment type: ${payment.type}, no navigation');
    }
  }
}

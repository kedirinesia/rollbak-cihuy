
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/template-main.dart';
import 'package:mobile/models/payment-list.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/topup/topup-controller.dart';
import 'package:mobile/utils/debug_helper.dart';

class TopupPage extends StatefulWidget {
  @override
  _TopupPageState createState() => _TopupPageState();
}

class _TopupPageState extends TopupController with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    DebugHelper.debugPrint('🔍 [TOPUP PAGE] initState called');
    DebugHelper.debugPrint('🔍 [TOPUP PAGE] User ID: ${bloc.userId.valueWrapper?.value}');
    
    var analyticsData = {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Topup',
    };
    DebugHelper.debugPrint('🔍 [TOPUP PAGE] Analytics payload: ${analyticsData.toString()}');
    analitycs.pageView('/topup/', analyticsData);
    DebugHelper.debugPrint('🔍 [TOPUP PAGE] Analytics page view sent');
  }

  @override
  Widget build(BuildContext context) {
    DebugHelper.debugPrint('🔍 [TOPUP PAGE] build() called');
    DebugHelper.debugPrint('🔍 [TOPUP PAGE] Loading state: $loading');
    DebugHelper.debugPrint('🔍 [TOPUP PAGE] Number of payment methods: ${listPayment.length}');
    
    final spinkit = SpinKitThreeBounce(
      color: Theme.of(context).primaryColor,
      size: 50.0,
      controller: AnimationController(
          vsync: this, duration: const Duration(milliseconds: 1200)),
    );

    return TemplateMain(
      title: 'Pilih Metode Pembayaran',
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.transparent,
        onPressed: null,
        child: SizedBox.shrink(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      children: <Widget>[
        loading
            ? spinkit
            : Container(
                child: ListView.builder(
                    itemCount: listPayment.length,
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemBuilder: (_, int index) {
                      PaymentModel mm = listPayment[index];
                      DebugHelper.debugPrint('🔍 [TOPUP PAGE] Building payment method item at index: $index');
                      DebugHelper.debugPrint('🔍 [TOPUP PAGE] Payment method: ${mm.title} (Type: ${mm.type})');

                      return InkWell(
                        onTap: () {
                          DebugHelper.debugPrint('🔍 [TOPUP PAGE] Payment method tapped at index: $index');
                          DebugHelper.debugPrint('🔍 [TOPUP PAGE] Selected: ${mm.title} (Type: ${mm.type})');
                          onTapMenu(mm);
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                              bottom: 20.0, left: 10.0, right: 10.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(.2),
                                    offset: Offset(5, 10),
                                    blurRadius: 10.0)
                              ]),
                          child: ListTile(
                            leading: CircleAvatar(
                              foregroundColor: Theme.of(context).primaryColor,
                              backgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(.1),
                              child: mm.icon.isNotEmpty
                                  ? Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: CachedNetworkImage(
                                        imageUrl: mm.icon,
                                        width: 40.0,
                                        placeholder: (context, url) {
                                          DebugHelper.debugPrint('🔍 [TOPUP PAGE] Loading image placeholder for: $url');
                                          return CircularProgressIndicator();
                                        },
                                        errorWidget: (context, url, error) {
                                          DebugHelper.debugPrint('🔍 [TOPUP PAGE] Image error for: $url - $error');
                                          return Icon(Icons.error);
                                        },
                                      ))
                                  : Icon(Icons.list),
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(mm.title ?? ' ',
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700)),
                                mm.admin != null
                                    ? Text(
                                        '+${mm.admin['satuan'] == 'persen' ? '' : 'Rp '}${mm.admin['nominal']}${mm.admin['satuan'] == 'persen' ? '%' : ''} (admin)',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[800]),
                                      )
                                    : SizedBox()
                              ],
                            ),
                            subtitle: Text(mm.description ?? ' ',
                                style: TextStyle(
                                    fontSize: 10.0,
                                    color: Colors.grey.shade700)),
                          ),
                        ),
                      );
                    }),
              )
      ],
    );
  }
}

// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/deposit.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/history/deposit/deposit-controller.dart';
import 'package:mobile/screen/transaksi/detail_deposit.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:mobile/utils/debug_helper.dart';

class DepositPage extends StatefulWidget {
  @override
  _DepositPageState createState() => _DepositPageState();
}

class _DepositPageState extends DepositController
    with TickerProviderStateMixin {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Widget _buildDepositLogo(DepositModel m) {
    // Cek apakah aplikasi adalah Payuniovo atau Seepays
    bool isPayuniovoOrSeepays = packageName == 'mobile.payuni.id' || 
                                packageName == 'co.payuni.id' || 
                                packageName == 'com.seepaysbiller.app';
    
    // Untuk Payuniovo dan Seepays, gunakan Image.asset dengan status icon
    if (isPayuniovoOrSeepays) {
      return CircleAvatar(
        foregroundColor: packageName == 'com.lariz.mobile'
            ? Theme.of(context).secondaryHeaderColor
            : Theme.of(context).primaryColor,
        backgroundColor: packageName == 'com.lariz.mobile'
            ? Theme.of(context).secondaryHeaderColor.withOpacity(.1)
            : Theme.of(context).primaryColor.withOpacity(.1),
        child: m.statusModel?.icon != null && m.statusModel.icon.isNotEmpty
            ? Image.asset(
                m.statusModel.icon,
                width: 20.0,
                height: 20.0,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  DebugHelper.debugPrint('🔍 [DEPOSIT] Asset error for: ${m.statusModel.icon} - Exception: $error');
                  return Icon(
                    m.statusModel.status == 0 
                        ? Icons.hourglass_empty 
                        : m.statusModel.status == 1 
                            ? Icons.check_circle 
                            : Icons.error,
                    size: 20.0,
                    color: m.statusModel.color,
                  );
                })
            : Icon(
                m.statusModel?.status == 0 
                    ? Icons.hourglass_empty 
                    : m.statusModel?.status == 1 
                        ? Icons.check_circle 
                        : Icons.error,
                size: 20.0,
                color: m.statusModel?.color ?? Colors.grey,
              ),
      );
    } else {
      // Untuk produk selain Payuniovo/Seepays, gunakan CachedNetworkImage dengan URL status icon
      String statusIconUrl = _getStatusIconUrl(m.statusModel.status);
      
      return CircleAvatar(
        foregroundColor: packageName == 'com.lariz.mobile'
            ? Theme.of(context).secondaryHeaderColor
            : Theme.of(context).primaryColor,
        backgroundColor: packageName == 'com.lariz.mobile'
            ? Theme.of(context).secondaryHeaderColor.withOpacity(.1)
            : Theme.of(context).primaryColor.withOpacity(.1),
        child: CachedNetworkImage(
          imageUrl: statusIconUrl,
          width: 20.0,
          errorWidget: (context, url, error) => Icon(
            m.statusModel.status == 0 
                ? Icons.hourglass_empty 
                : m.statusModel.status == 1 
                    ? Icons.check_circle 
                    : Icons.error,
            size: 20.0,
            color: m.statusModel.color,
          ),
        ),
      );
    }
  }

  String _getStatusIconUrl(int status) {
    // Konversi status deposit ke URL icon untuk CachedNetworkImage
    switch (status) {
      case 0:
        return 'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Fcoffee-cup.png?alt=media&token=fd0d0a4d-9689-4ab9-8473-72516ccd3c5f'; // Pending
      case 1:
        return 'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Ftrophy.png?alt=media&token=271f57f4-bc76-4f19-8f69-b3543376adff'; // Sukses
      default:
        return 'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Ferror.png?alt=media&token=f5148d8a-a90d-494f-8368-0daf85eb4803'; // Gagal
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.all(15),
            child: Center(
              child: SpinKitThreeBounce(
                color: packageName == 'com.lariz.mobile'
                    ? Theme.of(context).secondaryHeaderColor
                    : Theme.of(context).primaryColor,
                size: 30,
              ),
            ),
          )
        : listDeposit.length == 0
            ? Container(
                width: double.infinity,
                height: double.infinity,
                child: Center(
                    child: SvgPicture.asset('assets/img/empty.svg',
                        width: MediaQuery.of(context).size.width * .35)),
              )
            : SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                enablePullUp: true,
                onRefresh: () async {
                  currentPage = 0;
                  isEdge = false;
                  listDeposit.clear();
                  await getData();
                  _refreshController.refreshCompleted();
                },
                onLoading: () async {
                  await getData();
                  _refreshController.loadComplete();
                },
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  itemCount: listDeposit.length,
                  separatorBuilder: (_, i) => SizedBox(height: 10),
                  itemBuilder: (_, int index) {
                    DepositModel m = listDeposit[index];
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(.5),
                                offset: Offset(3, 3),
                                blurRadius: 15)
                          ]),
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).push(
                            PageTransition(
                              child: DetailDeposit(m),
                              type: PageTransitionType.rippleMiddle,
                              duration: Duration(milliseconds: 10),
                            ),
                          );
                        },
                        leading: _buildDepositLogo(m),
                        title: Text(formatRupiah(m.nominal),
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            )),
                        subtitle: Text(
                            formatDate(m.created_at, "d MMMM yyyy HH:mm:ss") ??
                                ' ',
                            style: TextStyle(
                                fontSize: 10.0, color: Colors.grey.shade700)),
                        trailing: Text(m.statusModel.statusText,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: m.statusModel.color)),
                      ),
                    );
                  },
                ));
  }
}

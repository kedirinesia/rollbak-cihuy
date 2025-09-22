// @dart=2.9

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:mobile/models/menu.dart';

// Import necessary pages for navigation - using SEEPAY specific ones
import 'package:mobile/screen/detail-denom/detail-denom.dart';
import 'package:mobile/screen/detail-denom-postpaid/detail-postpaid.dart';
import 'package:mobile/screen/dynamic-prepaid/dynamic-denom.dart';
import 'package:mobile/screen/list-grid-menu/list-grid-menu.dart';
import 'list-sub-menu.dart';
import 'pulsa.dart';
import 'package:mobile/screen/transaksi/voucher_bulk.dart';

// Import SEEPAY specific detail pages
import 'detail-denom.dart';
import 'detail-denom-postpaid.dart';
import 'package:mobile/utils/debug_helper.dart';

class MorePage extends StatefulWidget {
  final List<MenuModel> menus;
  final bool isKotak;

  MorePage(this.menus, {this.isKotak = false});

  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final bool isSmallScreen = screenWidth < 360;
    final bool isMediumScreen = screenWidth >= 360 && screenWidth < 414;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Product Lainnya',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : (isMediumScreen ? 17 : 18),
                ),
              ),
              centerTitle: true,
            ),
            expandedHeight: isSmallScreen ? 160.0 : (isMediumScreen ? 180.0 : 200.0),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8.0 : (isMediumScreen ? 9.0 : 10.0), 
                  vertical: isSmallScreen ? 15.0 : (isMediumScreen ? 17.0 : 20.0)
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  primary: false,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.menus.length,
                  itemBuilder: (_, int index) {
                    MenuModel menu = widget.menus[index];
                    return Container(
                      child: InkWell(
                        onTap: () => _onTapMenu(menu),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: isSmallScreen ? 45 : (isMediumScreen ? 50 : 55),
                              height: isSmallScreen ? 45 : (isMediumScreen ? 50 : 55),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFA259FF).withOpacity(0.3),
                                    blurRadius: isSmallScreen ? 4 : 6,
                                    offset: Offset(0, isSmallScreen ? 6 : 9),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: CachedNetworkImage(
                                imageUrl: menu.icon,
                                width: isSmallScreen ? 28 : (isMediumScreen ? 32 : 35),
                                height: isSmallScreen ? 28 : (isMediumScreen ? 32 : 35),
                                fit: BoxFit.contain,
                                errorWidget: (context, url, error) => Container(
                                  width: isSmallScreen ? 28 : (isMediumScreen ? 32 : 35),
                                  height: isSmallScreen ? 28 : (isMediumScreen ? 32 : 35),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFA259FF).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: isSmallScreen ? 16 : (isMediumScreen ? 18 : 20),
                                    color: Color(0xFFA259FF),
                                  ),
                                ),
                                placeholder: (context, url) => Container(
                                  width: isSmallScreen ? 28 : (isMediumScreen ? 32 : 35),
                                  height: isSmallScreen ? 28 : (isMediumScreen ? 32 : 35),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFA259FF).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: CircularProgressIndicator(
                                    strokeWidth: isSmallScreen ? 1.5 : 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA259FF)),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 8.0 : (isMediumScreen ? 10.0 : 12.0)),
                            Flexible(
                              child: Text(
                                menu.name,
                                style: TextStyle(
                                    fontSize: isSmallScreen ? 10.0 : (isMediumScreen ? 11.0 : 12.0),
                                    color: Color(0xFFA259FF),
                                    fontWeight: FontWeight.bold),
                                softWrap: true,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isSmallScreen ? 3 : (isMediumScreen ? 3 : 4),
                      crossAxisSpacing: isSmallScreen ? 1 : 2,
                      childAspectRatio: isSmallScreen ? 0.9 : (isMediumScreen ? 0.92 : 0.95),
                      mainAxisSpacing: isSmallScreen ? 3.0 : 4.0),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void _onTapMenu(MenuModel menu) {
    DebugHelper.debugPrint('📌 MorePage Menu diklik: ${menu.name} | jenis: ${menu.jenis}, type: ${menu.type}, category_id: ${menu.category_id}, kodeProduk: ${menu.kodeProduk}');
    
    if (menu.jenis == 1) {
      DebugHelper.debugPrint('➡️ Menu menuju ke: Pulsa');
      Navigator.of(context).push(MaterialPageRoute(builder: (_) {
        return Pulsa(menu);
      }));
    } else if (menu.jenis == 2) {
      if (menu.category_id != null &&
          menu.category_id.isNotEmpty &&
          menu.type == 1) {
        DebugHelper.debugPrint('➡️ Menu menuju ke: SeepaysDetailDenom');
        Navigator.of(context).push(PageTransition(
            child: SeepaysDetailDenom(menu), type: PageTransitionType.rippleRightUp));
      } else if (menu.kodeProduk != null &&
          menu.kodeProduk.isNotEmpty &&
          menu.type == 2) {
        DebugHelper.debugPrint('➡️ Menu menuju ke: SeepaysDetailDenomPostpaid');
        Navigator.of(context).push(PageTransition(
            child: SeepaysDetailDenomPostpaid(menu),
            type: PageTransitionType.rippleRightUp));
      } else {
        if (menu.type == 3) {
          DebugHelper.debugPrint('➡️ Menu menuju ke: DynamicPrepaidDenom');
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => DynamicPrepaidDenom(menu)));
        } else {
          DebugHelper.debugPrint('➡️ Menu menuju ke: ListSubMenu (category_id kosong/null)');
          DebugHelper.debugPrint('🔍 MorePage Debug: Mengirim menu ke ListSubMenu:');
          DebugHelper.debugPrint('   📋 Menu ID: ${menu.id}');
          DebugHelper.debugPrint('   📋 Menu Name: ${menu.name}');
          DebugHelper.debugPrint('   📋 Menu Type: ${menu.type}');
          DebugHelper.debugPrint('   📋 Menu Jenis: ${menu.jenis}');
          DebugHelper.debugPrint('   📋 Menu Category ID: ${menu.category_id}');
          DebugHelper.debugPrint('   📋 Menu Kode Produk: ${menu.kodeProduk}');
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => ListSubMenu(menu)));
        }
      }
    } else if (menu.jenis == 4) {
      DebugHelper.debugPrint('➡️ Menu menuju ke: ListGridMenu');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ListGridMenu(menu),
        ),
      );
    } else if (menu.jenis == 5) {
      DebugHelper.debugPrint('➡️ Menu menuju ke: VoucherBulkPage');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VoucherBulkPage(menu),
        ),
      );
    } else {
      DebugHelper.debugPrint('❌ Jenis menu tidak dikenali: ${menu.jenis}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Menu belum tersedia'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}

// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/mykonterr/layout/qris/qris_page.dart';
import 'package:mobile/Products/mykonterr/layout/topup.dart';
import 'package:mobile/Products/mykonterr/layout/transfer.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/component/webview.dart';
import 'package:mobile/models/banner.dart';
import 'package:mobile/models/menu.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/provider/api.dart';
import 'package:mobile/screen/detail-denom/detail-denom.dart';
import 'package:mobile/screen/list-grid-menu/list-grid-menu.dart';
import 'package:mobile/screen/profile/reward/list_reward.dart';

class BannerComponent extends StatefulWidget {
  @override
  _BannerComponentState createState() => _BannerComponentState();
}

class _BannerComponentState extends State<BannerComponent> {
  int _index = 0;

  Future<List<BannerModel>> banners() async {
    List<dynamic> datas = await api.get('/banner/list', cache: true);
    return datas.map((e) => BannerModel.fromJson(e)).toList();
  }

  dynamic onClickBanner(BannerModel banner) {
    List<String> urls = banner.url.split('/');
    if (urls[0] == 'menu') {
      MenuModel menu = MenuModel(
        id: urls[1],
        name: banner.title,
        icon: '',
      );

      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ListGridMenu(menu),
        ),
      );
    } else if (urls[0] == 'prepaid') {
      MenuModel menu = MenuModel(
        id: banner.id,
        name: banner.title,
        category_id: urls[1],
        icon: '',
      );

      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DetailDenom(menu),
        ),
      );
    } else {
      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Webview(banner.title, banner.url),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BannerModel>>(
      future: banners(),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return AspectRatio(
            aspectRatio: 1.134,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 1,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data.isEmpty) {
          return AspectRatio(
            aspectRatio: 1.134,
            child: Center(
              child: Text(
                snapshot.hasError ? 'TERJADI KESALAHAN' : 'TIDAK ADA PROMO',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            CarouselSlider.builder(
              options: CarouselOptions(
                autoPlay: true,
                aspectRatio: 1.5,
                viewportFraction: 1.0,
                initialPage: _index,
                onPageChanged: (index, _) {
                  setState(() {
                    _index = index;
                  });
                },
              ),
              itemCount: snapshot.data.length,
              itemBuilder: (ctx, i, _) {
                final banner = snapshot.data[i];
                return InkWell(
                  onTap: () => onClickBanner(banner),
                  child: CachedNetworkImage(
                    imageUrl: banner.cover,
                    fit: BoxFit.fill,
                    width: double.infinity,
                  ),
                );
              },
            ),
            Transform.translate(
              offset: const Offset(0, -35),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TopupPage(),
                          ),
                        ),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).secondaryHeaderColor,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.center,
                          child: const Text(
                            'Top Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
              
                      const SizedBox(width: 16),
              
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              'https://dokumen.payuni.co.id/logo/mykonter/custom/iconsaldo.png',
                              width: 34,
                              height: 34,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  formatRupiah(bloc.user?.valueWrapper?.value?.saldo ?? 0),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'Saldo My Konter',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
              
                      const SizedBox(width: 16),
              
                      Expanded(
                        child: InkWell(
                          onTap: () =>
                                Navigator.of(context).pushNamed('/komisi'),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                'https://dokumen.payuni.co.id/logo/mykonter/custom/iconkomisi.png',
                                width: 32,
                                height: 32,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(formatRupiah(bloc.user?.valueWrapper?.value?.komisi ?? 0), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('Komisi Tersedia', style: TextStyle(fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => QrisPage()),
                      );
                    },
                    child: Row(
                      children: [
                        Image.network(
                          'https://dokumen.payuni.co.id/logo/mykonter/custom/iconqris.png',
                          width: 25,
                          height: 25,
                          fit: BoxFit.contain
                        ),
                        SizedBox(width: 10),
                        Text('Oris', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => TransferManuPage()),
                      );
                    },
                    child: Row(
                      children: [
                        Image.network(
                          'https://dokumen.payuni.co.id/logo/mykonter/custom/icontfsaldo.png',
                          width: 25,
                          height: 25,
                          fit: BoxFit.contain
                        ),
                        SizedBox(width: 10),
                        Text('Transfer Saldo', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => ListReward())),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://dokumen.payuni.co.id/logo/mykonter/custom/coin.png',
                          width: 25,
                          height: 25,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${bloc.user?.valueWrapper?.value?.poin} Pts', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            Text('Poin My Konter', style: TextStyle(fontSize: 8,))
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}

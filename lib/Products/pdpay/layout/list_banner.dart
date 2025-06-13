import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/component/webview.dart';
import 'package:mobile/config.dart';
import 'package:mobile/models/banner.dart';
import 'package:mobile/provider/api.dart';

class ListBannerPage extends StatefulWidget {
  @override
  _ListBannerPageState createState() => _ListBannerPageState();
}

class _ListBannerPageState extends State<ListBannerPage> {
  TextEditingController search = TextEditingController();
  List<BannerModel> banners = [];
  List<BannerModel> temp = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    getBanners();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> getBanners() async {
    List<dynamic> datas = await api.get('/banner/list', cache: true);
    banners = datas.map((e) => BannerModel.fromJson(e)).toList();
    temp = banners;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Promo $appName'),
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade100,
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          TextField(
            controller: search,
            keyboardType: TextInputType.text,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              isDense: true,
              isCollapsed: true,
              filled: true,
              fillColor: Colors.grey.shade300,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Colors.grey,
              ),
              suffixIcon: search.text.isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(Icons.close_rounded),
                      color: Colors.grey,
                      onPressed: () {
                        setState(() {
                          search.clear();
                          temp = banners;
                        });
                      },
                    ),
              hintText: 'Mau cari promo apa?',
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
            ),
            onChanged: (value) {
              setState(() {
                temp = banners
                    .where((element) => element.title
                        .toLowerCase()
                        .contains(value.toLowerCase()))
                    .toList();
              });
            },
          ),
          SizedBox(height: 15),
          loading
              ? Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * .2,
                  child: Center(
                    child: SpinKitThreeBounce(
                      color: Theme.of(context).primaryColor,
                      size: 35,
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: temp.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    BannerModel banner = temp.elementAt(i);

                    return InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => Webview(banner.title, banner.url),
                        ),
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              offset: Offset(3, 3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              child: AspectRatio(
                                aspectRatio: 2,
                                child: CachedNetworkImage(
                                  imageUrl: banner.cover,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                banner.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

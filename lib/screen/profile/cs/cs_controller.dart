import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/models/cs.dart';
import 'package:mobile/provider/api.dart';
import 'package:mobile/screen/profile/cs/cs.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class CSController extends State<CS> with TickerProviderStateMixin {
  List<CustomerService> listCs = [];
  bool loading = true;

  @override
  void initState() {
    getData();
    super.initState();
  }

  void getData() async {
    try {
      List<dynamic> datas =
          await api.get('/cs/list/public', cache: false, auth: false);
      listCs = datas.map((e) => CustomerService.fromJson(e)).toList();
    } catch (_) {
      listCs = [];
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Widget loadingWidget() {
    return Flexible(
      flex: 1,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: SpinKitThreeBounce(
            color: Theme.of(context).primaryColor,
            size: 35,
          ),
        ),
      ),
    );
  }

  Widget listWidget() {
    if (listCs.length == 0) {
      return Flexible(
        flex: 1,
        child: Center(
          child: SvgPicture.asset(
            'assets/img/contact_us.svg',
            width: MediaQuery.of(context).size.width * .45,
          ),
        ),
      );
    } else {
      return Flexible(
        flex: 1,
        child: Container(
          margin: EdgeInsets.only(top: 20.0),
          padding: EdgeInsets.all(10),
          child: ListView.builder(
            itemCount: listCs.length,
            itemBuilder: (context, i) {
              return InkWell(
                onTap: () => launchUrl(
                  Uri.parse(listCs[i].link),
                  mode: LaunchMode.externalApplication,
                ),
                child: Container(
                  margin: EdgeInsets.only(bottom: 10.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(.1),
                            offset: Offset(5, 10),
                            blurRadius: 10.0)
                      ]),
                  child: ListTile(
                    leading: listCs[i].icon == ""
                        ? CircleAvatar(
                            backgroundColor:
                                Theme.of(context).primaryColor.withOpacity(.1),
                            child: CachedNetworkImage(
                                imageUrl:
                                    'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Finfo.png?alt=media&token=c4af5286-53b6-42a8-be30-4799f84fb71f',
                                width: 20.0))
                        : CircleAvatar(
                            backgroundColor:
                                Theme.of(context).primaryColor.withOpacity(.1),
                            child: CachedNetworkImage(
                              imageUrl: listCs[i].icon,
                              width: 24,
                              height: 24,
                            ),
                          ),
                    title: Text(
                      listCs[i].contact,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      listCs[i].title,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }
}

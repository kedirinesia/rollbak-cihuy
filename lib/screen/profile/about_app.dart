// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:package_info/package_info.dart';

class AboutAppPage extends StatefulWidget {
  @override
  _AboutAppPageState createState() => _AboutAppPageState();
}

class _AboutAppPageState extends State<AboutAppPage> {
  bool loading = true;
  String appName;
  String packageName;
  String versionName;
  String versionCode;

  @override
  void initState() {
    initData();
    super.initState();
    analitycs.pageView('/about/app', {
      'userId': bloc.userId.valueWrapper?.value,
      'title': 'Tentang Aplikasi',
    });
  }

  void initData() async {
    PackageInfo info = await PackageInfo.fromPlatform();

    appName = info.appName;
    packageName = info.packageName;
    versionName = info.version;
    versionCode = info.buildNumber;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tentang Aplikasi'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: packageName == 'com.lariz.mobile'
            ? Theme.of(context).secondaryHeaderColor
            : Theme.of(context).primaryColor,
      ),
      body: loading
          ? Container(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                  child: SpinKitThreeBounce(
                      color: packageName == 'com.lariz.mobile'
                          ? Theme.of(context).secondaryHeaderColor
                          : Theme.of(context).primaryColor,
                      size: 35)))
          : Container(
              width: double.infinity,
              height: double.infinity,
              child: Column(children: <Widget>[
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * .2,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                    packageName == 'com.lariz.mobile'
                        ? Theme.of(context).secondaryHeaderColor
                        : Theme.of(context).primaryColor,
                    Theme.of(context).canvasColor
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                  child: Center(
                      child: Icon(Icons.info_outline,
                          size: MediaQuery.of(context).size.height * .15,
                          color: Colors.white)),
                ),
                Flexible(
                    flex: 1,
                    child: ListView(padding: EdgeInsets.all(20), children: <
                        Widget>[
                      ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          backgroundColor: packageName == 'com.lariz.mobile'
                              ? Theme.of(context)
                                  .secondaryHeaderColor
                                  .withOpacity(.1)
                              : Theme.of(context).primaryColor.withOpacity(.1),
                          child: Icon(
                            Icons.navigate_next,
                            color: packageName == 'com.lariz.mobile'
                                ? Theme.of(context).secondaryHeaderColor
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                        title: Text('Nama Aplikasi',
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                        subtitle: Text(appName ?? '-',
                            style: TextStyle(
                                fontSize: 16,
                                color: packageName == 'com.lariz.mobile'
                                    ? Theme.of(context).secondaryHeaderColor
                                    : Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold)),
                      ),
                      Divider(height: 10),
                      // ListTile(
                      //   dense: true,
                      //   leading: CircleAvatar(
                      //     backgroundColor:
                      //         Theme.of(context).primaryColor.withOpacity(.1),
                      //     child: Icon(Icons.navigate_next,
                      //         color: Theme.of(context).primaryColor),
                      //   ),
                      //   title: Text('Nama Paket',
                      //       style: TextStyle(fontSize: 11, color: Colors.grey)),
                      //   subtitle: Text(packageName ?? '-',
                      //       style: TextStyle(
                      //           fontSize: 16,
                      //           color: Theme.of(context).primaryColor,
                      //           fontWeight: FontWeight.bold)),
                      // ),
                      // Divider(height: 10),
                      ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          backgroundColor: packageName == 'com.lariz.mobile'
                              ? Theme.of(context)
                                  .secondaryHeaderColor
                                  .withOpacity(.1)
                              : Theme.of(context).primaryColor.withOpacity(.1),
                          child: Icon(
                            Icons.navigate_next,
                            color: packageName == 'com.lariz.mobile'
                                ? Theme.of(context).secondaryHeaderColor
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                        title: Text('Versi',
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                        subtitle: Text(versionName ?? '-',
                            style: TextStyle(
                                fontSize: 16,
                                color: packageName == 'com.lariz.mobile'
                                    ? Theme.of(context).secondaryHeaderColor
                                    : Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold)),
                      ),
                      Divider(height: 10),
                      ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          backgroundColor: packageName == 'com.lariz.mobile'
                              ? Theme.of(context)
                                  .secondaryHeaderColor
                                  .withOpacity(.1)
                              : Theme.of(context).primaryColor.withOpacity(.1),
                          child: Icon(
                            Icons.navigate_next,
                            color: packageName == 'com.lariz.mobile'
                                ? Theme.of(context).secondaryHeaderColor
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                        title: Text('Build Code',
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                        subtitle: Text(versionCode ?? '-',
                            style: TextStyle(
                                fontSize: 16,
                                color: packageName == 'com.lariz.mobile'
                                    ? Theme.of(context).secondaryHeaderColor
                                    : Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold)),
                      )
                    ]))
              ])),
    );
  }
}

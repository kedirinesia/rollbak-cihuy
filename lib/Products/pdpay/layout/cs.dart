import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/Products/pdpay/layout/livechat.dart';
import 'package:mobile/models/cs.dart';
import 'package:mobile/provider/api.dart';
import 'package:url_launcher/url_launcher.dart';

class CS1 extends StatefulWidget {
  @override
  _CSState createState() => _CSState();
}

class _CSState extends State<CS1> {
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
          await api.get('/cs/list/public', auth: false, cache: true);
      listCs.add(CustomerService());
      listCs.addAll(datas.map((e) => CustomerService.fromJson(e)).toList());
    } catch (_) {
      listCs.add(CustomerService());
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
              child: SvgPicture.asset('assets/img/contact_us.svg',
                  width: MediaQuery.of(context).size.width * .45)));
    } else {
      return Flexible(
        flex: 1,
        child: Container(
          margin: EdgeInsets.only(top: 20.0),
          padding: EdgeInsets.all(10),
          child: ListView.builder(
            itemCount: listCs.length,
            itemBuilder: (context, i) {
              if (i == 0) {
                return Container(
                  margin: EdgeInsets.only(bottom: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.1),
                        offset: Offset(5, 10),
                        blurRadius: 10.0,
                      ),
                    ],
                  ),
                  child: ListTile(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CustomerServicePage(),
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(.1),
                      child: Icon(Icons.support_agent_rounded),
                    ),
                    title: Text(
                      'Live Chat',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Live Chat dengan Customer Service kami',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ),
                );
              }

              return Container(
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
                  onTap: () async {
                    if (await canLaunch(listCs[i].link)) {
                      launch(listCs[i].link);
                    }
                  },
                  leading: listCs[i].icon == ""
                      ? CircleAvatar(
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(.1),
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Finfo.png?alt=media&token=c4af5286-53b6-42a8-be30-4799f84fb71f',
                            width: 20.0,
                          ),
                        )
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
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text('Customer Service'), centerTitle: true, elevation: 0),
      body: Column(children: <Widget>[
        Container(
          width: double.infinity,
          height: 200,
          padding: EdgeInsets.all(20),
          child: Hero(
            tag: 'cs',
            child: Center(
                child: CachedNetworkImage(
                    imageUrl:
                        'https://firebasestorage.googleapis.com/v0/b/wajib-online.appspot.com/o/icons%2Ftie.png?alt=media&token=143f7a42-e520-49fb-8314-a53ac2c28614')),
          ),
          decoration: BoxDecoration(color: Colors.white),
        ),
        loading ? loadingWidget() : listWidget()
      ]),
    );
  }
}

// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import '../config.dart';

// class CustomerServicePage extends StatefulWidget {
//   @override
//   _CustomerServicePageState createState() => _CustomerServicePageState();
// }

// class _CustomerServicePageState extends State<CustomerServicePage> {
//   //   Completer<WebViewController> _controller = Completer<WebViewController>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         //         appBar: AppBar(
//             title:
//                 Text('Payuni Live Chat', style: TextStyle(color: Colors.white)),
//             centerTitle: true,
//             elevation: 0,
//             iconTheme: IconThemeData(color: Colors.white)),
//         body: WebView(
//             initialUrl: liveChat,
//             javascriptMode: JavascriptMode.unrestricted,
//             onWebViewCreated: (controller) {
//               _controller.complete(controller);
//             }));
//   }
// }

// @dart=2.9

import 'package:mobile/bloc/ConfigApp.dart' show configAppBloc;
import 'package:http/http.dart' as http;

String apiAnal = 'https://www.google-analytics.com/collect?v=1';

class Analitycs {
  pageView(String page, Map<dynamic, dynamic> properties) async {
    String userId = 'Anonymous';
    String userName = 'Anonymous';
    String title = 'No-Title';
    if (properties != null) {
      if (properties['userId'] != null) {
        userId = properties['userId'];
      }
      if (properties['userName'] != null) {
        userName = properties['userName'];
      }
      if (properties['title'] != null) {
        title = properties['title'];
      }
    }

    if (configAppBloc.gaId.valueWrapper?.value.isEmpty) {
      return "Failed fetch analitycs, NO PROBLEM";
    }
    String url = "$apiAnal&tid=" +
        configAppBloc.gaId.valueWrapper?.value +
        "&cid=" +
        userId +
        '&dp=' +
        page +
        '&aip=1&cs=' +
        configAppBloc.namaApp.valueWrapper?.value +
        '&uid=' +
        userName;
    url +=
        '&ua=Mozilla/5.0 (Linux; U; Android 2.2) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1';
    url += '&dr=' + configAppBloc.namaApp.valueWrapper?.value;
    url += '&sr=800x600';
    url += '&dt=' + title;
    url += '&cm=' + configAppBloc.namaApp.valueWrapper?.value;

    print(url);
    await http.get(Uri.parse(url));
    return "OK";
  }
}

Analitycs analitycs = Analitycs();

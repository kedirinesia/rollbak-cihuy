// @dart=2.9

import 'dart:convert';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/modules.dart';

class Api {
  final String host = apiUrl;

  Future<dynamic> get(String path,
      {bool cache = false,
      bool auth = true,
      Duration expired = const Duration(hours: 1)}) async {
    String url = '$host$path';

    if (cache) {
      FileInfo fileInfo = await DefaultCacheManager().getFileFromCache(url);
      if (fileInfo != null && fileInfo.validTill.isBefore(DateTime.now())) {
        return json.decode(fileInfo.file.readAsStringSync());
      }
    }

    http.Response response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': auth ? bloc.token.valueWrapper?.value : null,
        'merchantcode': sigVendor,
      },
    );

    if (response.statusCode == 200) {
      dynamic data = json.decode(response.body)['data'];
      DefaultCacheManager().putFile(
        '$url',
        toBytes(json.encode(data)),
        maxAge: Duration(hours: 1),
      );
      return data;
    } else {
      throw json.decode(response.body);
    }
  }

  Future<dynamic> post(
    String path, {
    bool auth = true,
    Map<String, dynamic> data = const {},
  }) async {
    String url = '$host$path';

    http.Response response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': auth ? bloc.token.valueWrapper?.value : null,
        'merchantcode': sigVendor,
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      dynamic data = json.decode(response.body);
      return data;
    } else {
      throw json.decode(response.body);
    }
  }
}

Api api = Api();

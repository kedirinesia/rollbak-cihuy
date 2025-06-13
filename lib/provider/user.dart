// @dart=2.9

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/Api.dart' show apiUrl;

class UserProvider {
  Future<UserModel> getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    if (token != null) {
      try {
        http.Response response = await http.get(Uri.parse('$apiUrl/user/info'),
            headers: {'Authorization': token});
        if (response.statusCode == 200) {
          return UserModel.fromJson(jsonDecode(response.body)['data']);
        } else {
          return bloc.user.valueWrapper?.value;
        }
      } catch (_) {
        return null;
      }
    } else {
      return null;
    }
  }
}

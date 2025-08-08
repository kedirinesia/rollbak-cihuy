// ignore_for_file: invalid_use_of_visible_for_testing_member
// @dart=2.9

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/models/app_info.dart';
import 'package:mobile/models/flash_banner.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/provider/api.dart';
import 'package:mobile/provider/user.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

import 'bloc/Api.dart';

String formatDate(String datetime, String format) {
  String date;

  initializeDateFormatting('id', null);
  date = DateFormat(format, 'id').format(DateTime.parse(datetime));

  return date;
}

String formatRupiah(int nominal) {
  String rupiah = NumberFormat.decimalPattern('id').format(nominal);
  return 'Rp $rupiah';
}

String FormatRupiah(int nominal) {
  String Rupiah = NumberFormat.decimalPattern('id').format(nominal);
  return '$Rupiah';
}

String formatNominal(int nominal) {
  String rupiah = NumberFormat.decimalPattern('id').format(nominal);
  return '$rupiah';
}

String formatNumber(int nominal) {
  return NumberFormat.decimalPattern('id').format(nominal);
}

String recapitalize(String text) {
  List<String> arr = text.toLowerCase().split(' ');
  return arr
      .map((e) {
        return e.substring(0, 1).toUpperCase() + e.substring(1);
      })
      .toList()
      .join(' ');
}

Future<bool> getUserInfo() async {
  http.Response response = await http.get(
    Uri.parse('$apiUrl/user/info'),
    headers: {'Authorization': bloc.token.valueWrapper?.value},
  );

  if (response.statusCode == 200) {
    UserModel user = UserModel.fromJson(json.decode(response.body)['data']);
    bloc.user.add(user);
    return true;
  } else {
    bloc.token.add(null);
    bloc.user.add(null);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    return false;
  }
}

Future<void> updateUserInfo() async {
  UserProvider provider = UserProvider();
  var user = await provider.getProfile();
  if (user != null) {
    bloc.user.add(user);
    bloc.userId.add(user.id);
    bloc.username.add(user.nama);
    bloc.userPhone.add(user.phone);
    bloc.alamat.add(user.alamat);
    bloc.saldo.add(user.saldo);
    bloc.poin.add(user.poin);
    bloc.komisi.add(user.komisi);
  }
}

Future<void> testApiConnection() async {
  try {
    print('DEBUG: Testing API connection...');
    print('DEBUG: API URL: $apiUrl');
    
    // Test basic connectivity
    bool isConnected = await _checkConnectivity();
    print('DEBUG: Internet connectivity: $isConnected');
    
    if (!isConnected) {
      print('DEBUG: No internet connection available');
      return;
    }
    
    // Test the API endpoint directly
    http.Response response = await http.get(
      Uri.parse('$apiUrl/app/info?id=$sigVendor'),
      headers: {
        'merchantcode': sigVendor,
      },
    ).timeout(Duration(seconds: 10));
    
    print('DEBUG: Test response status: ${response.statusCode}');
    print('DEBUG: Test response headers: ${response.headers}');
    print('DEBUG: Test response body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
    
    if (response.statusCode == 200) {
      if (response.headers['content-type']?.contains('application/json') == true) {
        print('DEBUG: API is working correctly');
      } else {
        print('DEBUG: API returned non-JSON response');
      }
    } else {
      print('DEBUG: API returned error status: ${response.statusCode}');
    }
  } catch (e) {
    print('DEBUG: API test failed: $e');
  }
}

Future<bool> _checkConnectivity() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}

Future<void> getAppInfo() async {
  try {
    print('DEBUG: Starting getAppInfo...');
    print('DEBUG: API URL: $apiUrl/app/info?id=$sigVendor');
    
    // Test API connection first
    await testApiConnection();
    
    Map<String, dynamic> data =
        await api.get('/app/info?id=$sigVendor', auth: false, cache: true);
    AppInfo app = AppInfo.fromJson(data);
    configAppBloc.info.add(app);
    print('DEBUG: getAppInfo completed successfully');
  } catch (e) {
    print('DEBUG: getAppInfo error: $e');
    print('DEBUG: Error type: ${e.runtimeType}');
    
    // Handle specific FormatException for HTML responses
    if (e is FormatException) {
      print('DEBUG: FormatException detected - likely HTML response from server');
      print('DEBUG: Error message: ${e.message}');
      
      // You might want to show a user-friendly error dialog here
      // or handle the error gracefully by using default values
    }
    
    // Re-throw the error so the calling code can handle it
    rethrow;
  }
}

Future<File> getPhoto() async {
  PermissionStatus status = await Permission.camera.request();
  while (status != PermissionStatus.granted) {
    status = await Permission.camera.request();
  }

  PickedFile image = await ImagePicker.platform
      .pickImage(source: ImageSource.camera, imageQuality: 80);
  return await compressImage(image);
}

Future<File> compressImage(PickedFile image) async {
  List<int> compressed = await FlutterImageCompress.compressWithFile(image.path,
      minWidth: 800, minHeight: 600, quality: 80, format: CompressFormat.jpeg);
  return await File(image.path)
      .writeAsBytes(compressed, flush: true, mode: FileMode.write);
}

List<int> toBytes(String string) {
  return utf8.encode(string);
}

String toString(List<int> bytes) {
  return utf8.decode(bytes);
}

void sendDeviceToken() async {
  print('=== DEBUG: Starting sendDeviceToken ===');
  print('DEBUG: API URL: $apiUrl/user/device_token');
  print('DEBUG: Token available: ${bloc.token.valueWrapper?.value != null}');
  print('DEBUG: Device token available: ${bloc.deviceToken.valueWrapper?.value != null}');
  
  try {
    print('DEBUG: Making device token request...');
    await http.post(Uri.parse('$apiUrl/user/device_token'),
        headers: {
          'Authorization': bloc.token.valueWrapper?.value,
          'Content-Type': 'application/json'
        },
        body: json.encode({'token': bloc.deviceToken.valueWrapper?.value}));
    print('DEBUG: Device token sent successfully');
  } catch (err) {
    print('DEBUG: Error sending device token: $err');
    print('DEBUG: Error type: ${err.runtimeType}');
  }
}

Future<void> launchUrl(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) launchUrl(url);
}

Future<void> getFlashBanner(BuildContext context) async {
  http.Response response = await http.get(
      Uri.parse('$apiUrl/banner/flash/list'),
      headers: {'Authorization': bloc.token.valueWrapper?.value});

  if (response.statusCode == 200) {
    List<dynamic> datas = json.decode(response.body)['data'];

    datas.forEach((data) async {
      FlashBannerModel fb = FlashBannerModel.fromJson(data);
      if (fb.type == 0) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool displayed = prefs.getBool('fb_${fb.id}') ?? false;
        if (!displayed) {
          prefs.setBool('fb_${fb.id}', true);
          await showDialog(
              context: context,
              builder: (ctx) => Center(
                    child: Stack(fit: StackFit.loose, children: [
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: GestureDetector(
                          onTap: () => launch(fb.url),
                          child: CachedNetworkImage(
                            imageUrl: fb.imageUrl,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: Navigator.of(ctx).pop,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Icon(
                                Icons.close,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ));
        }
      } else {
        await showDialog(
            context: context,
            builder: (ctx) => Center(
                  child: Stack(fit: StackFit.loose, children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: GestureDetector(
                        onTap: () => launch(fb.url),
                        child: CachedNetworkImage(
                          imageUrl: fb.imageUrl,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: Navigator.of(ctx).pop,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Icon(
                              Icons.close,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
                ));
      }
    });
  }
}

void showToast(BuildContext context, String message,
    {int duration = 3, int gravity = 0}) {
  return Toast.show(message, context,
      gravity: gravity,
      duration: duration,
      backgroundColor: Colors.black.withOpacity(.75),
      backgroundRadius: 10);
}

void showLoading(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return WillPopScope(
          onWillPop: () => Future.value(false),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 1,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        );
      });
}

void closeLoading(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}

DateTime getFirstDate() {
  DateTime now = DateTime.now();
  return DateTime(now.year, now.month, 1);
}

DateTime getLastDate() {
  DateTime now = DateTime.now();
  bool isLeapYear = now.year % 4 == 0;
  List<int> daysOfMonth = [
    31,
    isLeapYear ? 29 : 28,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31,
  ];

  return DateTime(now.year, now.month, daysOfMonth[now.month - 1]);
}

DateTime getCurrentDate() {
  DateTime now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

List<int> printLine(Generator ticket, List<Map<String, dynamic>> lines,
    {bool bold = false}) {
  List<int> results = [];

  for (Map<String, dynamic> line in lines) {
    int maxCharsPerLine = 32;
    String label = (line['label'] ?? '').toString();
    String value = (line['value'] ?? '-').toString();

    label = label.padRight(11);
    value = value.padLeft(18);
    String text = '$label : $value';
    int rowsCount = (text.length / maxCharsPerLine).ceil();

    for (int i = 1; i <= rowsCount; i++) {
      int start = maxCharsPerLine * (i - 1);
      int end = min((maxCharsPerLine * i), text.length);

      if (i == 1) {
        results += ticket.text(
          text.substring(start, end),
          styles: PosStyles(
            bold: bold,
          ),
        );
      } else {
        results += ticket.text(
          text.substring(start, end).padLeft(17),
          styles: PosStyles(
            bold: bold,
          ),
        );
      }
    }
  }

  return results;
}

// ignore_for_file: invalid_use_of_visible_for_testing_member

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
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:esc_pos_utils/esc_pos_utils.dart';

import 'bloc/Api.dart';
import 'package:mobile/utils/debug_helper.dart';

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
  final token = bloc.token.valueWrapper?.value;
  if (token == null) return false;
  
  http.Response response = await http.get(
    Uri.parse('$apiUrl/user/info'),
    headers: {'Authorization': token},
  );

  if (response.statusCode == 200) {
    UserModel user = UserModel.fromJson(json.decode(response.body)['data']);
    bloc.user.add(user);
    return true;
  } else {
    bloc.token.add('');
    bloc.user.add(UserModel(
      nama: '',
      phone: '',
      email: '',
      id: '',
      kyc_verification: false,
      kyc: '',
      kode_merchant: '',
      saldo: 0,
      komisi: 0,
      poin: 0,
      idProvinsi: '',
      idKota: '',
      idKecamatan: '',
      alamat: '',
      namaToko: '',
      alamatToko: '',
      aktif: false,
      enableWithdraw: false,
      inviteCode: '',
    ));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    return false;
  }
}

Future<void> updateUserInfo() async {
  UserProvider provider = UserProvider();
  try {
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
  } catch (e) {
    DebugHelper.debugError('UPDATE_USER_INFO', 'Failed to update user info: $e');
  }
}

Future<void> testApiConnection() async {
  try {
    DebugHelper.debugPrint('Testing API connection...');
    DebugHelper.debugApi('TEST_CONNECTION', 'API URL: $apiUrl');
    
    // Test basic connectivity
    bool isConnected = await _checkConnectivity();
    DebugHelper.debugNetwork('Internet connectivity: $isConnected');
    
    if (!isConnected) {
      DebugHelper.debugNetwork('No internet connection available');
      return;
    }
    
    // Test the API endpoint directly
    http.Response response = await http.get(
      Uri.parse('$apiUrl/app/info?id=$sigVendor'),
      headers: {
        'merchantcode': sigVendor,
      },
    ).timeout(Duration(seconds: 10));
    
    DebugHelper.debugApi('TEST_CONNECTION', 'Test response status: ${response.statusCode}');
    DebugHelper.debugApi('TEST_CONNECTION', 'Test response headers: ${response.headers}');
    DebugHelper.debugApi('TEST_CONNECTION', 'Test response body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
    
    if (response.statusCode == 200) {
      if (response.headers['content-type']?.contains('application/json') == true) {
        DebugHelper.debugApi('TEST_CONNECTION', 'API is working correctly');
      } else {
        DebugHelper.debugApi('TEST_CONNECTION', 'API returned non-JSON response');
      }
    } else {
      DebugHelper.debugError('TEST_CONNECTION', 'API returned error status: ${response.statusCode}');
    }
  } catch (e) {
    DebugHelper.debugError('TEST_CONNECTION', 'API test failed: $e');
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
    DebugHelper.debugPrint('Starting getAppInfo...');
    DebugHelper.debugApi('GET_APP_INFO', 'API URL: $apiUrl/app/info?id=$sigVendor');
    
    // Test API connection first
    await testApiConnection();
    
    DebugHelper.debugPrint('🔍 CALLING API: /app/info?id=$sigVendor with cache: true');
    DebugHelper.debugPrint('🔍 sigVendor value: "$sigVendor" (type: ${sigVendor.runtimeType})');
    DebugHelper.debugPrint('🔍 sigVendor length: ${sigVendor.length}');
    Map<String, dynamic> data =
        await api.get('/app/info?id=$sigVendor', auth: false, cache: true);

   
    DebugHelper.debugPrint('📦 CACHE INFO: Data received, checking if cached...');
    DebugHelper.debugPrint('📦 Data length: ${data.toString().length}');

    try {
      DebugHelper.debugPrint('🔍 Attempting to parse AppInfo...');
      AppInfo app = AppInfo.fromJson(data);
      DebugHelper.debugPrint('✅ AppInfo parsed successfully');
      configAppBloc.info.add(app);

     
      DebugHelper.debugPrint('=== APP INFO DEBUG ===');
      DebugHelper.debugPrint('API URL: $apiUrl/app/info?id=$sigVendor');
      DebugHelper.debugPrint('Raw API Response: $data');
      DebugHelper.debugPrint('Rad API Response Type: ${data.runtimeType}');

      {
        DebugHelper.debugPrint('📊 API DATA ANALYSIS:');
        data.forEach((key, value) {
          DebugHelper.debugPrint('  $key: $value (type: ${value.runtimeType})');
          if (key == 'register' || key == 'stopAllRegister' || key == 'data' || key == 'status') {
            DebugHelper.debugPrint('    🔍 $key detailed: value=$value, isBool=${value is bool}, isNull=${value == null}, toString=${value.toString()}');
          }
        });
        // Check if data['data'] exists and analyze it
        if (data['data'] != null) {
          DebugHelper.debugPrint('📋 DATA SECTION ANALYSIS:');
          var dataSection = data['data'];
          DebugHelper.debugPrint('  data section type: ${dataSection.runtimeType}');
          dataSection.forEach((key, value) {
            DebugHelper.debugPrint('    $key: $value (type: ${value.runtimeType})');
            if (key == 'register' || key == 'stopAllRegister') {
              DebugHelper.debugPrint('      🔍 REGISTER FIELD: $key = $value (isBool=${value is bool}, isNull=${value == null})');
            }
          });
        } else {
          DebugHelper.debugPrint('❌ data section is NULL');
        }
        DebugHelper.debugPrint('❌ API Response is NOT a Map<String, dynamic>');
        DebugHelper.debugPrint('❌ Raw response: $data');
      }

      DebugHelper.debugPrint('📋 PARSED APP INFO:');
      DebugHelper.debugPrint('  register: ${app.register} (type: ${app.register.runtimeType})');
      DebugHelper.debugPrint('  stopAllRegister: ${app.stopAllRegister} (type: ${app.stopAllRegister.runtimeType})');
      DebugHelper.debugPrint('  inviteLink: ${app.inviteLink} (type: ${app.inviteLink.runtimeType})');
      DebugHelper.debugPrint('  enableSelectCA: ${app.enableSelectCA} (type: ${app.enableSelectCA.runtimeType})');

      DebugHelper.debugPrint('✅ REGISTER CONDITION CHECK:');
      DebugHelper.debugPrint('  register == true: ${app.register == true}');
      DebugHelper.debugPrint('  stopAllRegister == false: ${app.stopAllRegister == false}');
      DebugHelper.debugPrint('  Combined condition: ${(app.register == true && app.stopAllRegister == false)}');
      DebugHelper.debugPrint('=== APP INFO DEBUG END ===');

    } catch (e) {
      DebugHelper.debugPrint('❌ ERROR parsing AppInfo: $e');
      DebugHelper.debugPrint('❌ Error type: ${e.runtimeType}');
      DebugHelper.debugPrint('❌ Data that caused error: $data');
      DebugHelper.debugPrint('❌ Data type: ${data.runtimeType}');
      DebugHelper.debugPrint('❌ Data toString length: ${data.toString().length}');

      {
        DebugHelper.debugPrint('❌ Checking each field for null values:');
        data.forEach((key, value) {
          DebugHelper.debugPrint('  $key: $value (isNull=${value == null}, type=${value.runtimeType})');
        });

        if (data['kode_merchant'] != null) {
          DebugHelper.debugPrint('❌ kode_merchant section: ${data['kode_merchant']}');
          var merchant = data['kode_merchant'];
          merchant.forEach((key, value) {
            DebugHelper.debugPrint('    $key: $value (isNull=${value == null}, type=${value.runtimeType})');
          });
        } else {
          DebugHelper.debugPrint('❌ kode_merchant is NULL!');
        }
      }

      throw e;
    }

  } catch (e) {
        DebugHelper.debugPrint('❌ ERROR in getAppInfo(): $e');
        DebugHelper.debugPrint('❌ Error type: ${e.runtimeType}');
        DebugHelper.debugPrint('❌ Error stack trace: ${StackTrace.current}');

    // Try to analyze the API response even on error
        DebugHelper.debugPrint('🔍 ANALYZING API RESPONSE ON ERROR:');
    try {
      Map<String, dynamic> errorData = await api.get('/app/info?id=$sigVendor', auth: false, cache: false);
      DebugHelper.debugPrint('Error API Response: $errorData');
      DebugHelper.debugPrint('Error API Response Type: ${errorData.runtimeType}');

      {
        DebugHelper.debugPrint('Error data analysis:');
        errorData.forEach((key, value) {
          DebugHelper.debugPrint('  $key: $value (type: ${value.runtimeType})');
        });

        if (errorData['data'] != null) {
          DebugHelper.debugPrint('Error data section: ${errorData['data']}');
          var errorDataSection = errorData['data'];
          errorDataSection.forEach((key, value) {
            DebugHelper.debugPrint('    $key: $value (type: ${value.runtimeType})');
          });
        }
      }
    } catch (innerError) {
      DebugHelper.debugPrint('❌ Could not analyze error response: $innerError');
    }

    DebugHelper.debugError('GET_APP_INFO', 'getAppInfo error: $e');
    DebugHelper.debugError('GET_APP_INFO', 'Error type: ${e.runtimeType}');
    
    // Handle specific FormatException for HTML responses
    if (e is FormatException) {
      DebugHelper.debugError('GET_APP_INFO', 'FormatException detected - likely HTML response from server');
      DebugHelper.debugError('GET_APP_INFO', 'Error message: ${e.message}');
      
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

  XFile? image = await ImagePicker()
      .pickImage(source: ImageSource.camera, imageQuality: 80);
  if (image == null) throw Exception('No image selected');
  return await compressImage(image);
}

Future<File> compressImage(XFile image) async {
  List<int>? compressed = await FlutterImageCompress.compressWithFile(image.path,
      minWidth: 800, minHeight: 600, quality: 80, format: CompressFormat.jpeg);
  if (compressed == null) throw Exception('Image compression failed');
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
  DebugHelper.debugApi('SEND_DEVICE_TOKEN', '=== DEBUG: Starting sendDeviceToken ===');
  DebugHelper.debugApi('SEND_DEVICE_TOKEN', 'API URL: $apiUrl/user/device_token');
  DebugHelper.debugApi('SEND_DEVICE_TOKEN', 'Token available: ${bloc.token.valueWrapper?.value != null}');
  DebugHelper.debugApi('SEND_DEVICE_TOKEN', 'Device token available: ${bloc.deviceToken.valueWrapper?.value != null}');
  
  final authToken = bloc.token.valueWrapper?.value;
  final deviceToken = bloc.deviceToken.valueWrapper?.value;
  
  if (authToken == null || deviceToken == null) {
    DebugHelper.debugError('SEND_DEVICE_TOKEN', 'Missing required tokens');
    return;
  }
  
  try {
    DebugHelper.debugApi('SEND_DEVICE_TOKEN', 'Making device token request...');
    await http.post(Uri.parse('$apiUrl/user/device_token'),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json'
        },
        body: json.encode({'token': deviceToken}));
    DebugHelper.debugApi('SEND_DEVICE_TOKEN', 'Device token sent successfully');
  } catch (err) {
    DebugHelper.debugError('SEND_DEVICE_TOKEN', 'Error sending device token: $err');
    DebugHelper.debugError('SEND_DEVICE_TOKEN', 'Error type: ${err.runtimeType}');
  }
}

Future<void> launchUrl(String url) async {
  final uri = Uri.parse(url);
  if (await url_launcher.canLaunchUrl(uri)) await url_launcher.launchUrl(uri);
}

Future<void> getFlashBanner(BuildContext context) async {
  final token = bloc.token.valueWrapper?.value;
  if (token == null) return;
  
  http.Response response = await http.get(
      Uri.parse('$apiUrl/banner/flash/list'),
      headers: {'Authorization': token});

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
                          onTap: () => url_launcher.launchUrl(Uri.parse(fb.url)),
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
        } else if (fb.type == 1) {
          await showDialog(
              context: context,
              builder: (ctx) => Center(
                    child: Stack(fit: StackFit.loose, children: [
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: GestureDetector(
                          onTap: () => url_launcher.launchUrl(Uri.parse(fb.url)),
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
      }
    });
  }
}

void showToast(BuildContext context, String message,
    {int duration = 3, int gravity = 0}) {
  final String safeMessage = message.toString();
  if (safeMessage.isEmpty) return;

  try {
    // Pastikan Toast memiliki context agar tidak melempar "Context is null"
    ToastContext().init(context);
    Toast.show(
      safeMessage,
      duration: duration,
      gravity: gravity,
      backgroundColor: Colors.black.withOpacity(.75),
      backgroundRadius: 10,
    );
  } catch (err) {
    // Fallback aman jika Toast gagal (mis. context belum ter-initialize)
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(safeMessage)));
  }
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

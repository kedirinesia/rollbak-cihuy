
import 'package:mobile/utils/debug_helper.dart';

class MetodeBayarModel {
  final int type;
  final String id;
  final String title;
  final String code;
  final String icon;
  String description;
  Map<String, dynamic> admin;

  MetodeBayarModel(
      { required this.id,
      required this.type,
      required this.title,
      required this.code,
      required this.icon,
      required this.description,
      required this.admin});

  factory MetodeBayarModel.fromJson(dynamic json) {
    // Debug logging untuk admin fee
    if (json['admin'] != null) {
      DebugHelper.debugPrint('🔍 [ADMIN FEE] ${json['title']}: ${json['admin']}');
      if (json['admin']['nominal'] == null) {
        DebugHelper.debugPrint('⚠️ [ADMIN FEE WARNING] ${json['title']} has null nominal for admin fee');
      }
    } else {
      DebugHelper.debugPrint('⚠️ [ADMIN FEE WARNING] ${json['title']} has null admin object');
    }
    
    return MetodeBayarModel(
      id: json['_id'] ?? '',
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      icon: json['icon'] ?? '',
      description: json['description'] ?? ' ',
      type: json['type'] ?? 0,
      admin: json['admin'] ?? null,
    );
  }
}

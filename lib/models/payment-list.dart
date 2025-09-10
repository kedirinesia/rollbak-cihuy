// @dart=2.9

import 'package:mobile/utils/debug_helper.dart';

class PaymentModel {
  String id;
  int type;
  String title;
  String cover;
  String icon;
  String description;
  String channel;
  Map<String, dynamic> admin;
  Map<String, dynamic> admin_trx;

  PaymentModel(
      {this.title,
      this.cover,
      this.id,
      this.type,
      this.icon,
      this.description,
      this.channel,
      this.admin}) {
    DebugHelper.debugPrint('🔍 [PAYMENT MODEL] PaymentModel constructor called');
    DebugHelper.debugPrint('🔍 [PAYMENT MODEL] Title: $title, Type: $type, Channel: $channel');
    DebugHelper.debugPrint('🔍 [PAYMENT MODEL] ID: $id, Icon: $icon');
    DebugHelper.debugPrint('🔍 [PAYMENT MODEL] Description: $description');
    DebugHelper.debugPrint('🔍 [PAYMENT MODEL] Admin: $admin');
  }

  PaymentModel.fromJson(Map<String, dynamic> json) {
    DebugHelper.debugPrint('🔍 [PAYMENT MODEL] fromJson called with FULL JSON PAYLOAD:');
    DebugHelper.debugPrint('🔍 [PAYMENT MODEL] ${json.toString()}');
    
    title = json['title'];
    id = json['_id'];
    cover = json['cover'] ?? '';
    icon = json['icon'] ?? '';
    description = json['description'] ?? ' ';
    channel = json['channel'] ?? '';
    type = json['type'] ?? 0;
    admin = json['admin'];
    admin_trx = json['admin_trx'] ?? null;
    
    DebugHelper.debugPrint('🔍 [PAYMENT MODEL] Parsed values:');
    DebugHelper.debugPrint('🔍 [PAYMENT MODEL] - Title: $title');
    DebugHelper.debugPrint('🔍 [PAYMENT MODEL] - ID: $id');
    DebugHelper.debugPrint('🔍 [PAYMENT MODEL] - Type: $type');
    DebugHelper.debugPrint('🔍 [PAYMENT MODEL] - Channel: $channel');
    DebugHelper.debugPrint('🔍 [PAYMENT MODEL] - Icon: $icon');
    DebugHelper.debugPrint('🔍 [PAYMENT MODEL] - Description: $description');
    DebugHelper.debugPrint('🔍 [PAYMENT MODEL] - Admin: $admin');
    DebugHelper.debugPrint('🔍 [PAYMENT MODEL] - Admin TRX: $admin_trx');
  }
}

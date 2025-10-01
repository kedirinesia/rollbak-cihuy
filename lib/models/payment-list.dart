
import 'package:mobile/utils/debug_helper.dart';

class PaymentModel {
  String id = '';
  int type = 0;
  String title = '';
  String cover = '';
  String icon = '';
  String description = '';
  String channel = '';
  Map<String, dynamic> admin = {};
  Map<String, dynamic>? admin_trx;

  PaymentModel(
      {required this.title,
      required this.cover,
      required this.id,
      required this.type,
      required this.icon,
      required this.description,
      required this.channel,
      required this.admin,
      required this.admin_trx}) {
    DebugHelper.debugPrint('🔍 [PAYMENT MODEL] PaymentModel constructor called');
    DebugHelper.debugPrint('🔍 [PAYMENT MODEL] Title: $title, Type: $type, Channel: $channel');
    DebugHelper.debugPrint('🔍 [PAYMENT MODEL] ID: $id, Icon: $icon');
    DebugHelper.debugPrint('🔍 [PAYMENT MODEL] Description: $description');
    DebugHelper.debugPrint('🔍 [PAYMENT MODEL] Admin: $admin');
  }

  PaymentModel.fromJson(Map<String, dynamic> json) {
    DebugHelper.debugPrint('🔍 [PAYMENT MODEL] fromJson called with FULL JSON PAYLOAD:');
    DebugHelper.debugPrint('🔍 [PAYMENT MODEL] ${json.toString()}');
    
    title = json['title'] ?? '';
    id = json['_id'] ?? '';
    cover = json['cover'] ?? '';
    icon = json['icon'] ?? '';
    description = json['description'] ?? ' ';
    channel = json['channel'] ?? '';
    type = json['type'] ?? 0;
    admin = json['admin'] ?? {};
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

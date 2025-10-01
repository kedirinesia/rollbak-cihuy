
class AppInfo {
  String kodeMerchant;
  String nama;
  int tipe;
  bool aktif;
  bool inviteLink;
  bool register;
  bool stopAllRegister;
  bool updateHarga;
  bool enableSelectCA;
  String domain;
  String domainInvite;
  String iconWeb;
  int defaultLaba;
  int defaultMarkup;
  MarqueeText marquee;
  String imageInvite;
  String kataInvite;
  String descInvite;
  String urlPrivacyPolicy;
  String urlServicePolicy;
  String footerStruk;

  AppInfo({
   required  this.kodeMerchant,
    required    this.nama,
    required this.tipe,
    required this.aktif,
    required this.inviteLink,
    required this.register,
    required this.stopAllRegister,
    required this.updateHarga,
    required this.enableSelectCA,
    required this.imageInvite,
    required this.kataInvite,
    required this.descInvite,
    required this.marquee,
    required this.domain,
    required this.domainInvite,
    required this.iconWeb,
    required this.defaultLaba,
    required this.urlPrivacyPolicy,
    required this.urlServicePolicy,
    required this.defaultMarkup,
    required  this.footerStruk,
  });

  // Helper method untuk parsing boolean dari berbagai tipe data
  static bool? _parseBoolean(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      String lowerValue = value.toLowerCase();
      if (lowerValue == 'true' || lowerValue == '1') return true;
      if (lowerValue == 'false' || lowerValue == '0') return false;
    }
    if (value is int) {
      return value == 1;
    }
    return null;
  }

  factory AppInfo.fromJson(dynamic json) {
    print('🔍 AppInfo.fromJson called with: $json');
    print('🔍 JSON type: ${json.runtimeType}');

    // Check if json is null
    if (json == null) {
      print('❌ JSON is NULL in AppInfo.fromJson');
      throw Exception('JSON is null in AppInfo.fromJson');
    }

    // Check if json is Map
    if (json is! Map<String, dynamic>) {
      print('❌ JSON is not Map<String, dynamic>: $json');
      throw Exception('JSON is not Map<String, dynamic>');
    }

    try {
      return AppInfo(
          kodeMerchant: json['kode_merchant']['_id'],
        nama: json['kode_merchant']['nama'],
        tipe: json['kode_merchant']['tipe'],
        aktif: json['kode_merchant']['aktif'],
        inviteLink: _parseBoolean(json['invite_link']) ?? true,
        register: _parseBoolean(json['register']) ?? true,
        stopAllRegister: _parseBoolean(json['stopAllRegister']) ?? false,
        updateHarga: json['updateHarga'],
        enableSelectCA: _parseBoolean(json['enableSelectCA']) ?? false,
        domain: json['domain'],
        domainInvite: json['domain_invite'],
        defaultLaba: json['defaultLaba'],
        defaultMarkup: json['defaultMarkup'],
        urlPrivacyPolicy: json['url_privacy_policy'],
        urlServicePolicy: json['url_service_policy'],
        iconWeb: json['icon_web'],
        footerStruk: json['footer_struk'] ?? '',
        marquee: json['marquee_text'] == null
            ? MarqueeText(active: false, message: '')
            : MarqueeText.fromJson(json['marquee_text']),
        kataInvite: json['kata_invite'] != null
            ? json['kata_invite']
            : 'Aplikasi buat jualan pulsa, paket, data dan pembayaran online',
        descInvite: json['description_invite'] != null
            ? json['description_invite']
            : 'Beli Pulsa, Paket Data, Token Listrik, PLN, Dll. Banyak Diskon membuat member jadi semakin betah',
        imageInvite: json['image_invite'] != null
            ? json['image_invite']
            : 'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/banners%2FWhatsApp%20Image%202019-08-12%20at%202.29.42%20AM.jpeg?alt=media&token=a4f39656-2f73-4645-85b1-c8fe2f5525f5');
    } catch (e) {
      print('❌ ERROR in AppInfo.fromJson: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ JSON data: $json');
      print('❌ Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }
}

class MarqueeText {
  final bool active;
  final String message;

  MarqueeText({
    required this.active,
    required this.message,
  });

  factory MarqueeText.fromJson(dynamic json) {
    return MarqueeText(
      active: json['active'],
      message: json['message'],
    );
  }
}

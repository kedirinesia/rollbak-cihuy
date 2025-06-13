// @dart=2.9

class AppInfo {
  String kodeMerchant;
  String nama;
  int tipe;
  bool aktif;
  bool inviteLink;
  bool register;
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
    this.kodeMerchant,
    this.nama,
    this.tipe,
    this.aktif,
    this.inviteLink,
    this.register,
    this.updateHarga,
    this.enableSelectCA,
    this.imageInvite,
    this.kataInvite,
    this.descInvite,
    this.marquee,
    this.domain,
    this.domainInvite,
    this.iconWeb,
    this.defaultLaba,
    this.urlPrivacyPolicy,
    this.urlServicePolicy,
    this.defaultMarkup,
    this.footerStruk,
  });

  factory AppInfo.fromJson(dynamic json) {
    return AppInfo(
        kodeMerchant: json['kode_merchant']['_id'],
        nama: json['kode_merchant']['nama'],
        tipe: json['kode_merchant']['tipe'],
        aktif: json['kode_merchant']['aktif'],
        inviteLink: json['invite_link'],
        register: json['register'],
        updateHarga: json['updateHarga'],
        enableSelectCA: json['enableSelectCA'],
        domain: json['domain'],
        domainInvite: json['domain_invite'],
        defaultLaba: json['defaultLaba'],
        defaultMarkup: json['defaultMarkup'],
        urlPrivacyPolicy: json['url_privacy_policy'],
        urlServicePolicy: json['url_service_policy'],
        iconWeb: json['icon_web'],
        footerStruk: json['footer_struk'] ?? '',
        marquee: json['marquee_text'] == null
            ? null
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
  }
}

class MarqueeText {
  final bool active;
  final String message;

  MarqueeText({
    this.active,
    this.message,
  });

  factory MarqueeText.fromJson(dynamic json) {
    return MarqueeText(
      active: json['active'],
      message: json['message'],
    );
  }
}

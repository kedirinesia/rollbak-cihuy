// @dart=2.9

import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:mobile/Products/talentapay/layout/qris/qris_page.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/config.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/kyc/reject.dart';
import 'package:mobile/screen/kyc/verification1.dart';
import 'package:mobile/screen/kyc/waiting.dart';
import 'package:mobile/screen/login.dart';
import 'package:mobile/screen/profile/about_app.dart';
import 'package:mobile/screen/profile/cs/cs.dart';
import 'package:mobile/screen/profile/detail_profile.dart';
import 'package:mobile/screen/profile/downline/downline.dart';
import 'package:mobile/screen/profile/ganti_pin/ganti_pin.dart';
import 'package:mobile/screen/profile/invite/invite.dart';
import 'package:mobile/screen/profile/print_settings.dart';
import 'package:mobile/screen/profile/profile.dart';
import 'package:mobile/screen/profile/reward/list_reward.dart';
import 'package:mobile/screen/profile/toko/edit_toko.dart';
import 'package:nav/nav.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/Products/talentapay/layout/qris.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ProfilePopay extends StatefulWidget {
  @override
  _ProfilePopayState createState() => _ProfilePopayState();
}

class _ProfilePopayState extends State<ProfilePopay> {
  Future<void> keluar() async {
    bool result = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text('Apakah anda yakin ingin keluar?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('YA'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('BATAL'),
          ),
        ],
      ),
    );
    if (!result) return;

    try {
      http.get(Uri.parse('$apiUrl/user/logout'),
          headers: {'Authorization': bloc.token.valueWrapper?.value});
    } catch (e) {
      print(e);
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Nav.clearAllAndPush(LoginPage());
  }

  void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    final response = await http.get(
      Uri.parse('$apiUrl/user/info'),
      headers: {'Authorization': bloc.token.valueWrapper?.value},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user info');
    }
  }

  void _onVerificationButtonPressed(BuildContext context) async {
    // Menampilkan CircularProgressIndicator yang disesuaikan
    showLoading(context);

    try {
      // Memanggil API dan mendapatkan informasi pengguna
      Map<String, dynamic> userInfo = await getUserInfo();
      Map<String, dynamic> kyc = userInfo['data']['kyc'];

      // Menyembunyikan CircularProgressIndicator yang disesuaikan
      hideLoading(context);

      if (kyc == null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SubmitKyc1()),
        );
      } else {
        switch (kyc['status']) {
          case 0: // Dalam Proses
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WaitingKycPage()),
            );
            break;
          case 1: // Sukses
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyQrisPage()),
            );
            break;
          case 2: // Di Tolak
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => KycRejectPage()),
            );
            break;
          default:
            // Anda dapat menangani kondisi default di sini jika diperlukan
            break;
        }
      }
    } catch (error) {
      // Menyembunyikan CircularProgressIndicator yang disesuaikan
      hideLoading(context);

      // Tampilkan pesan kesalahan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  Future<String> getPhoneNumberCs() async {
    try {
      String link;

      http.Response response = await http.get(Uri.parse('$apiUrl/cs/list'),
          headers: {'Authorization': bloc.token.valueWrapper?.value});
      if (response.statusCode == 200) {
        List<dynamic> responseData = json.decode(response.body)['data'];
        responseData.forEach((e) {
          print(e['link']);
          if (e['link'] is String &&
              (e['link'] as String).contains('api.whatsapp.com')) {
            link = e['link'];
          }
        });
      }
      return link;
    } catch (err) {
      return '';
    }
  }

  Future<void> sendWhatsApp() async {
    String link = await getPhoneNumberCs();

    if (link == null) return;
    print(link);

    String message =
        'Kepada Yth. Customer Service ${configAppBloc.namaApp.valueWrapper?.value},\r\n\nSaya yang bertanda tangan di bawah ini:\r\n\nNama: *${bloc.user.valueWrapper?.value.nama}*\r\nNomor: *${bloc.user.valueWrapper?.value.phone}*\r\n\nDengan ini mengajukan permohonan penutupan akun pada aplikasi ${configAppBloc.namaApp.valueWrapper?.value} yang telah saya daftarkan dengan nomor tersebut di atas. Saya memohon agar pihak customer service dapat membantu saya dalam proses penutupan akun dengan segera.\r\n\nSaya juga memastikan bahwa semua data dan informasi yang terkait dengan akun saya telah saya hapus atau dihapus oleh pihak ${configAppBloc.namaApp.valueWrapper?.value}.\r\n\nTerima kasih atas perhatian dan kerjasamanya.\r\n\nHormat saya,\r\n\n[${bloc.user.valueWrapper?.value.nama}]';

    String url = '$link&text=${Uri.encodeFull(message)}';

    launch(url);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Stack(children: <Widget>[
          Container(
            height: 200.0,
            width: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: CachedNetworkImageProvider(configAppBloc
                        .iconApp.valueWrapper?.value['imageHeader']),
                    fit: BoxFit.fill)),
          ),
          Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                title: Text('Profile'),
              ),
              body: ListView(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 30.0),
                      padding: EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(.1),
                                offset: Offset(5, 10),
                                blurRadius: 10.0)
                          ]),
                      child: Column(
                        children: <Widget>[
                          ProfilePict(),
                          Text(bloc.user.valueWrapper?.value.nama,
                              style: TextStyle(
                                  fontSize: 15.0, fontWeight: FontWeight.bold)),
                          SizedBox(height: 5.0),
                          Text(bloc.user.valueWrapper?.value.phone,
                              style: TextStyle(
                                  fontSize: 12.0, color: Colors.grey[700])),
                          SizedBox(height: 10.0),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 5.0),
                            decoration: BoxDecoration(
                                color: bloc.user.valueWrapper?.value
                                        .kyc_verification
                                    ? Colors.green.withOpacity(.2)
                                    : Colors.grey.withOpacity(.2),
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Text(
                                bloc.user.valueWrapper?.value.kyc_verification
                                    ? 'Premium User'
                                    : 'Basic User',
                                style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                    color: bloc.user.valueWrapper?.value
                                            .kyc_verification
                                        ? Colors.green
                                        : Colors.grey)),
                          ),
                          SizedBox(height: 20.0),
                          Divider(),
                          SizedBox(height: 20.0),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Container(
                                    child: Row(
                                  children: <Widget>[
                                    CircleAvatar(
                                      child: CachedNetworkImage(
                                          imageUrl:
                                              'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Fbusiness-and-finance%20(1).png?alt=media&token=02200893-8495-4e89-ba9d-dc79c65c4887'),
                                      backgroundColor: Colors.transparent,
                                      radius: 12.0,
                                      foregroundColor: Colors.red,
                                    ),
                                    SizedBox(width: 5.0),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('Saldo',
                                            style: TextStyle(fontSize: 10.0)),
                                        SizedBox(height: 2.0),
                                        Text(
                                            formatRupiah(bloc.user.valueWrapper
                                                ?.value.saldo),
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .primaryColor))
                                      ],
                                    ),
                                  ],
                                )),
                                Container(
                                    child: Row(
                                  children: <Widget>[
                                    CircleAvatar(
                                      child: CachedNetworkImage(
                                          imageUrl:
                                              'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Fbusiness-and-finance%20(1).png?alt=media&token=02200893-8495-4e89-ba9d-dc79c65c4887',
                                          color: Colors.purple),
                                      backgroundColor: Colors.transparent,
                                      radius: 12.0,
                                      foregroundColor: Colors.red,
                                    ),
                                    SizedBox(width: 5.0),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('Komisi',
                                            style: TextStyle(fontSize: 10.0)),
                                        SizedBox(height: 2.0),
                                        Text(
                                            formatRupiah(bloc.user.valueWrapper
                                                .value.komisi),
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.purple))
                                      ],
                                    ),
                                  ],
                                )),
                                Container(
                                    child: Row(
                                  children: <Widget>[
                                    CircleAvatar(
                                      child: CachedNetworkImage(
                                          imageUrl:
                                              'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Freward.png?alt=media&token=7ff34a27-1c7b-4be6-981e-55e9dc7e313d',
                                          color: Colors.orange),
                                      backgroundColor: Colors.transparent,
                                      radius: 12.0,
                                      foregroundColor: Colors.purple,
                                    ),
                                    SizedBox(width: 5.0),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('Poin',
                                            style: TextStyle(fontSize: 10.0)),
                                        SizedBox(height: 2.0),
                                        Text(
                                            formatNominal(bloc.user.valueWrapper
                                                    .value.poin) +
                                                ' Pts',
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange))
                                      ],
                                    ),
                                  ],
                                )),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
                      padding: EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(.1),
                                offset: Offset(5, 10),
                                blurRadius: 10.0)
                          ]),
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.all(0.0),
                        physics: ScrollPhysics(),
                        children: <Widget>[
                          Container(
                            child: Text('Akun Saya',
                                style: TextStyle(
                                    fontSize: 13.0, color: Colors.grey[700])),
                          ),
                          SizedBox(height: 10.0),
                          Divider(),
                          ListTile(
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => DetailProfile())),
                            title: Text('Profile Detail',
                                style: TextStyle(fontSize: 12.0)),
                            leading: Icon(Icons.person,
                                color: Theme.of(context).primaryColor),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          Divider(),
                          ListTile(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => QrisPage(),
                              ),
                            ),
                            title: Text(
                              'QRIS',
                              style: TextStyle(
                                fontSize: 12.0,
                              ),
                            ),
                            leading: Icon(
                              Icons.qr_code,
                              color: Colors.amber.shade700,
                            ),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          Divider(),
                          ListTile(
                            onTap: () =>
                                Navigator.of(context).pushNamed('/komisi'),
                            title: Text('Komisi',
                                style: TextStyle(fontSize: 12.0)),
                            leading:
                                Icon(Icons.rate_review, color: Colors.purple),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          Divider(),
                          ListTile(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => InvitePage()),
                            ),
                            title: Text('Undang Teman',
                                style: TextStyle(fontSize: 12.0)),
                            leading:
                                Icon(Icons.share_rounded, color: Colors.teal),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          Divider(),
                          ListTile(
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => Downline())),
                            title: Text('Downline',
                                style: TextStyle(fontSize: 12.0)),
                            leading: Icon(Icons.people,
                                color: Colors.deepOrangeAccent),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          Divider(),
                          ListTile(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PrintSettingsPage(),
                              ),
                            ),
                            title: Text('Atur Printer',
                                style: TextStyle(fontSize: 12.0)),
                            leading: Icon(
                              Icons.print_rounded,
                              color: Colors.deepOrange,
                            ),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          Divider(),
                          ListTile(
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return GantiPin();
                              }));
                            },
                            title: Text('Ganti PIN',
                                style: TextStyle(fontSize: 12.0)),
                            leading: Icon(
                              Icons.fiber_pin,
                              color: Colors.orange,
                            ),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          Divider(),
                          ListTile(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => EditToko()));
                            },
                            title: Text('Ubah Toko',
                                style: TextStyle(fontSize: 12.0)),
                            leading: Icon(
                              Icons.store,
                              color: Colors.green[400],
                            ),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          Divider(),
                          ListTile(
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => ListReward())),
                            title: Text('Rewards',
                                style: TextStyle(fontSize: 12.0)),
                            leading:
                                Icon(Icons.view_list, color: Colors.blue[700]),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          SizedBox(height: 40.0),
                          Container(
                            child: Text('Pelayanan',
                                style: TextStyle(
                                    fontSize: 13.0, color: Colors.grey[700])),
                          ),
                          SizedBox(height: 10.0),
                          Divider(),
                          ListTile(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => CS()));
                            },
                            title: Text('Customer Service',
                                style: TextStyle(fontSize: 12.0)),
                            leading: Icon(Icons.contact_phone,
                                color: Colors.purple[400]),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          Divider(),
                          ListTile(
                            onTap: () async {
                              if (Platform.isAndroid) {
                                String url =
                                    'http://play.google.com/store/apps/details?id=$packageName';
                                if (await canLaunch(url)) launch(url);
                              } else {
                                final InAppReview inAppReview =
                                    InAppReview.instance;
                                print(await inAppReview.isAvailable());

                                if (await inAppReview.isAvailable()) {
                                  inAppReview.requestReview();
                                } else {
                                  inAppReview.openStoreListing();
                                }
                              }
                            },
                            title: Text('Beri Ulasan',
                                style: TextStyle(fontSize: 12.0)),
                            leading:
                                Icon(Icons.star, color: Colors.orange[400]),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          Divider(),
                          ListTile(
                            onTap: () async {
                              await launch(configAppBloc
                                  .info.valueWrapper.value.urlPrivacyPolicy
                                  .toString());
                            },
                            title: Text('Privacy Policy',
                                style: TextStyle(fontSize: 12.0)),
                            leading: Icon(Icons.privacy_tip_rounded,
                                color: Theme.of(context).primaryColor),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          Divider(),
                          SizedBox(height: 40.0),
                          Container(
                            child: Text('Aplikasi',
                                style: TextStyle(
                                    fontSize: 13.0, color: Colors.grey[700])),
                          ),
                          SizedBox(height: 10.0),
                          Divider(),
                          ListTile(
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => AboutAppPage())),
                            title: Text('Tentang Aplikasi',
                                style: TextStyle(fontSize: 12.0)),
                            leading: Icon(Icons.info_outline,
                                color: Colors.green[700]),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          Divider(),
                          ListTile(
                            onTap: sendWhatsApp,
                            title: Text('Hapus Akun',
                                style: TextStyle(fontSize: 12.0)),
                            leading: Icon(Icons.delete_outline,
                                color: Colors.red[400]),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          Divider(),
                          ListTile(
                            onTap: () {
                              DefaultCacheManager().emptyCache().then((value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Berhasil memperbarui konten')));
                              }).catchError((err) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Gagal memperbarui konten')));
                              });
                            },
                            title: Text('Perbarui Konten',
                                style: TextStyle(fontSize: 12.0)),
                            leading:
                                Icon(Icons.refresh, color: Colors.indigoAccent),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          Divider(),
                          ListTile(
                            onTap: keluar,
                            title: Text('Keluar',
                                style: TextStyle(fontSize: 12.0)),
                            leading: Icon(Icons.lock_open,
                                color: Theme.of(context).primaryColor),
                            trailing: Icon(Icons.arrow_forward_ios),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 100.0)
                  ]))
        ]));
  }
}

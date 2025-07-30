// @dart=2.9

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mobile/Products/eralink/layout/agreement/privacy_page.dart';
import 'package:mobile/Products/eralink/layout/downline/downline.dart';
import 'package:mobile/Products/eralink/layout/agreement/service_page.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/config.dart';
import 'package:mobile/provider/analitycs.dart';
import 'package:mobile/screen/cs.dart';
import 'package:mobile/Products/eralink/layout/login.dart';
import 'package:mobile/screen/profile/about_app.dart';
import 'package:mobile/screen/profile/detail_profile.dart';
import 'package:mobile/screen/profile/ganti_pin/ganti_pin.dart';
import 'package:mobile/screen/profile/invite/invite.dart';
import 'package:mobile/screen/profile/komisi/riwayat_komisi.dart';
import 'package:mobile/screen/profile/my_qr.dart';
import 'package:mobile/screen/profile/print_settings.dart';
import 'package:mobile/screen/profile/reward/list_reward.dart';
import 'package:mobile/screen/profile/toko/edit_toko.dart';
import 'package:mobile/screen/wd/withdraw.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'package:mobile/screen/profile/downline/downline.dart';

typedef ValueSetter<Color> = void Function(Color value);

class ProfilePage extends StatefulWidget {
  ProfilePage();

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    bloc.mainColor.add(Colors.purple);
    bloc.mainTextColor.add(Colors.white);
    super.initState();
    analitycs.pageView('/profile',
        {'userId': bloc.userId.valueWrapper?.value, 'title': 'Profile'});
  }

  @override
  void dispose() {
    bloc.mainColor.add(Colors.white);
    bloc.mainTextColor.add(Colors.purple);
    super.dispose();
  }

  void keluar() async {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: Text('Apakah anda yakin ingin keluar?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    try {
                      http.get(Uri.parse('$apiUrl/user/logout'), headers: {
                        'Authorization': bloc.token.valueWrapper?.value
                      });
                    } catch (e) {}
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.of(context, rootNavigator: true).pop();
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => LoginPage()));
                  },
                  child: Text(
                    'YA',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text(
                    'BATAL',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ));
  }

  // Future<String> getPhoneNumberCs() async {
  //   try {
  //     String phoneNumber;

  //     http.Response response = await http.get(Uri.parse('$apiUrl/cs/list'),
  //         headers: {'Authorization': bloc.token.valueWrapper?.value});
  //     if (response.statusCode == 200) {
  //       List<dynamic> responseData = json.decode(response.body)['data'];
  //       responseData.forEach((e) {
  //         print(e['title']);
  //         phoneNumber = e['contact'];
  //       });
  //     }

  //     return phoneNumber;
  //   } catch (err) {
  //     return '';
  //   }
  // }

  // Future<void> sendWhatsApp() async {
  //   String phoneNumber = await getPhoneNumberCs();

  //   if (phoneNumber == null) return;
  //   print(phoneNumber);
  //   phoneNumber = phoneNumber.replaceAll(RegExp("[^0-9]"), "");
  //   phoneNumber = phoneNumber.replaceFirst(RegExp('0'), '62');

  //   String message =
  //       'Kepada Yth. Customer Service ${configAppBloc.namaApp.valueWrapper?.value},\r\n\nSaya yang bertanda tangan di bawah ini:\r\n\nNama: *${bloc.user.valueWrapper?.value.nama}*\r\nNomor: *${bloc.user.valueWrapper?.value.phone}*\r\n\nDengan ini mengajukan permohonan penutupan akun pada aplikasi ${configAppBloc.namaApp.valueWrapper?.value} yang telah saya daftarkan dengan nomor tersebut di atas. Saya memohon agar pihak customer service dapat membantu saya dalam proses penutupan akun dengan segera.\r\n\nSaya juga memastikan bahwa semua data dan informasi yang terkait dengan akun saya telah saya hapus atau dihapus oleh pihak ${configAppBloc.namaApp.valueWrapper?.value}.\r\n\nTerima kasih atas perhatian dan kerjasamanya.\r\n\nHormat saya,\r\n\n[${bloc.user.valueWrapper?.value.nama}]';
  //   String url = Uri.encodeFull(
  //       'https://api.whatsapp.com/send?phone=$phoneNumber&text=$message');

  //   launch(url);
  // }
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 250.0,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(.5)
                  ],
                      begin: AlignmentDirectional.topCenter,
                      end: AlignmentDirectional.bottomCenter)),
            ),
            Container(
                padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ProfilePict(),
                    SizedBox(height: 20.0),
                    Text(bloc.username.valueWrapper?.value,
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text(bloc.user.valueWrapper?.value.phone.toUpperCase(),
                        style: TextStyle(fontSize: 11.0, color: Colors.white)),
                    SizedBox(height: 20.0),
                    MenuGrid(),
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(.2),
                                offset: Offset(5, 10),
                                blurRadius: 10.0)
                          ]),
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.all(0.0),
                        physics: ScrollPhysics(),
                        children: <Widget>[
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
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => EditToko()));
                            },
                            title: Text('Edit Profile',
                                style: TextStyle(fontSize: 12.0)),
                            leading: Icon(
                              Icons.store,
                              color: Theme.of(context).primaryColor,
                            ),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          Divider(),
                          ListTile(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => MyQR()));
                            },
                            title: Text('My Qrcode',
                                style: TextStyle(fontSize: 12.0)),
                            leading: Icon(
                              Icons.screen_rotation,
                              color: Theme.of(context).primaryColor,
                            ),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          Divider(),
                          configAppBloc.packagename.valueWrapper?.value ==
                                  'com.funmo.id'
                              ? ListTile(
                                  onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) => WithdrawPage())),
                                  title: Text('Withdraw Saldo',
                                      style: TextStyle(fontSize: 12.0)),
                                  leading: Icon(Icons.monetization_on,
                                      color: Theme.of(context).primaryColor),
                                  trailing: Icon(Icons.arrow_forward_ios),
                                )
                              : SizedBox(),
                          configAppBloc.packagename.valueWrapper?.value ==
                                  'com.funmo.id'
                              ? Divider()
                              : SizedBox(),
                          ListTile(
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => ListReward())),
                            title: Text('Rewards',
                                style: TextStyle(fontSize: 12.0)),
                            leading: Icon(Icons.view_list,
                                color: Theme.of(context).primaryColor),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          Divider(),
                          // ListTile(
                          //   onTap: () {
                          //     Navigator.of(context)
                          //         .push(MaterialPageRoute(builder: (context) {
                          //       return EditUser();
                          //     }));
                          //   },
                          //   title: Text('Edit User',
                          //       style: TextStyle(fontSize: 12.0)),
                          //   leading: Icon(Icons.edit,
                          //       color: Theme.of(context).primaryColor),
                          //   trailing: Icon(Icons.arrow_forward_ios),
                          // ),
                          // Divider(),
                          ListTile(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => CS1()));
                            },
                            title: Text('Customer Service',
                                style: TextStyle(fontSize: 12.0)),
                            leading: Icon(Icons.contact_phone,
                                color: Theme.of(context).primaryColor),
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
                              color: Theme.of(context).primaryColor,
                            ),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          Divider(),
                          // ListTile(
                          //   onTap: () {
                          //     Navigator.of(context).push(MaterialPageRoute(
                          //         builder: (context) => EditToko()));
                          //   },
                          //   title: Text('Ubah Toko',
                          //       style: TextStyle(fontSize: 12.0)),
                          //   leading: Icon(
                          //     Icons.store,
                          //     color: Theme.of(context).primaryColor,
                          //   ),
                          //   trailing: Icon(Icons.arrow_forward_ios),
                          // ),
                          // Divider(),
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
                              color: Theme.of(context).primaryColor,
                            ),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          Divider(),
                          ListTile(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) {
                                  return PrivacyPolicyPage();
                                },
                              ));
                            },
                            title: Text('Privacy Policy',
                                style: TextStyle(fontSize: 12.0)),
                            leading: Icon(Icons.privacy_tip_rounded,
                                color: Theme.of(context).primaryColor),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          Divider(),
                          ListTile(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) {
                                  return ServicePolicyPage();
                                },
                              ));
                            },
                            title: Text('Terms & Condition',
                                style: TextStyle(fontSize: 12.0)),
                            leading: Icon(Icons.note_add_outlined,
                                color: Theme.of(context).primaryColor),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          Divider(),
                          ListTile(
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => AboutAppPage())),
                            title: Text('Tentang Aplikasi',
                                style: TextStyle(fontSize: 12.0)),
                            leading: Icon(Icons.info_outline,
                                color: Theme.of(context).primaryColor),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          Divider(),
                          ListTile(
                            onTap: sendWhatsApp,
                            title: Text('Hapus Akun',
                                style: TextStyle(fontSize: 12.0)),
                            leading: Icon(Icons.delete_outline,
                                color: Theme.of(context).primaryColor),
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
                            leading: Icon(Icons.refresh,
                                color: Theme.of(context).primaryColor),
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
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}

class ProfilePict extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(.2),
            borderRadius: BorderRadius.circular(400.0)),
        child: Container(
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(400.0)),
            width: 64.0,
            child: CachedNetworkImage(
              imageUrl: iconApp['iconProfile'],
              width: 60,
              height: 60,
            ),
            height: 64.0));
  }
}

class MenuGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(.2),
                offset: Offset(5, 10),
                blurRadius: 10.0)
          ]),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => RiwayatKomisi()));
            },
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Icon(Icons.rate_review,
                      size: 32.0, color: Theme.of(context).primaryColor),
                  SizedBox(height: 5.0),
                  Text('Komisi',
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Theme.of(context).primaryColor))
                ],
              ),
            ),
          ),
          packageName == 'com.eralink.mobileapk'
              ? InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DownlinePage()));
                  },
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.person_pin,
                            size: 32.0, color: Theme.of(context).primaryColor),
                        SizedBox(height: 5.0),
                        Text('Downline',
                            style: TextStyle(
                                fontSize: 12.0,
                                color: Theme.of(context).primaryColor))
                      ],
                    ),
                  ),
                )
              : InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Downline()));
                  },
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.person_pin,
                            size: 32.0, color: Theme.of(context).primaryColor),
                        SizedBox(height: 5.0),
                        Text('Downline',
                            style: TextStyle(
                                fontSize: 12.0,
                                color: Theme.of(context).primaryColor))
                      ],
                    ),
                  ),
                ),
          InkWell(
            onTap: () {
              if (configAppBloc.info.valueWrapper?.value.inviteLink) {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => InvitePage()));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invite link tidak tersedia')));
              }
            },
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Icon(Icons.share,
                      size: 32.0, color: Theme.of(context).primaryColor),
                  SizedBox(height: 5.0),
                  Text('Invite',
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Theme.of(context).primaryColor))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// @dart=2.9

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:mobile/Products/payku/layout/cs.dart';
import 'package:mobile/Products/payku/layout/login.dart';
import 'package:mobile/bloc/Api.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/config.dart';
import 'package:mobile/modules.dart';
import 'package:mobile/screen/laporan/laporan.dart';
import 'package:mobile/screen/profile/about_app.dart';
import 'package:mobile/screen/profile/detail_profile.dart';
import 'package:mobile/screen/profile/downline/downline.dart';
import 'package:mobile/screen/profile/ganti_pin/ganti_pin.dart';
import 'package:mobile/screen/profile/invite/invite.dart';
import 'package:mobile/screen/profile/print_settings.dart';
import 'package:mobile/screen/profile/reward/list_reward.dart';
import 'package:mobile/screen/profile/toko/edit_toko.dart';
import 'package:nav/nav.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class ProfilePayku extends StatefulWidget {
  @override
  _ProfilePaykuState createState() => _ProfilePaykuState();
}

class _ProfilePaykuState extends State<ProfilePayku> {
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).secondaryHeaderColor,
                Theme.of(context).primaryColor,
              ],
              begin: FractionalOffset.bottomCenter,
              end: FractionalOffset.topCenter,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'My Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontFamily: 'Nisebuschgardens',
              ),
            ),
          ),
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Container(
                    height: height * 0.3,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double innerHeight = constraints.maxHeight;
                        double innerWidth = constraints.maxWidth;
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                // height: innerHeight * 0.70,
                                // width: innerWidth,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(height: 35),
                                    Text(
                                      bloc.user.valueWrapper?.value.nama,
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontFamily: 'Nunito',
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      bloc.user.valueWrapper?.value.phone,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: 'Nunito',
                                        fontSize: 12,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.0, vertical: 5.0),
                                      decoration: BoxDecoration(
                                          color: bloc.user.valueWrapper?.value
                                                  .kyc_verification
                                              ? Colors.green.withOpacity(.2)
                                              : Colors.grey.withOpacity(.2),
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      child: Text(
                                          bloc.user.valueWrapper?.value
                                                  .kyc_verification
                                              ? 'Premium User'
                                              : 'Basic User',
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.bold,
                                              color: bloc.user.valueWrapper
                                                      ?.value.kyc_verification
                                                  ? Colors.green
                                                  : Colors.grey)),
                                    ),
                                    Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                              child: Row(
                                            children: <Widget>[
                                              CircleAvatar(
                                                child: Image.network(
                                                    'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Fbusiness-and-finance%20(1).png?alt=media&token=02200893-8495-4e89-ba9d-dc79c65c4887'),
                                                backgroundColor:
                                                    Colors.transparent,
                                                radius: 12.0,
                                                foregroundColor: Colors.red,
                                              ),
                                              SizedBox(width: 5.0),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text('Saldo',
                                                      style: TextStyle(
                                                          fontSize: 10.0)),
                                                  SizedBox(height: 2.0),
                                                  Text(
                                                      formatRupiah(bloc
                                                          .user
                                                          .valueWrapper
                                                          ?.value
                                                          .saldo),
                                                      style: TextStyle(
                                                          fontSize: 12.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor))
                                                ],
                                              ),
                                            ],
                                          )),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 8),
                                            child: Container(
                                              height: 30,
                                              width: 2,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          Container(
                                              child: Row(
                                            children: <Widget>[
                                              CircleAvatar(
                                                child: Image.network(
                                                    'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Fbusiness-and-finance%20(1).png?alt=media&token=02200893-8495-4e89-ba9d-dc79c65c4887',
                                                    color: Colors.purple),
                                                backgroundColor:
                                                    Colors.transparent,
                                                radius: 12.0,
                                                foregroundColor: Colors.red,
                                              ),
                                              SizedBox(width: 5.0),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text('Komisi',
                                                      style: TextStyle(
                                                          fontSize: 10.0)),
                                                  SizedBox(height: 2.0),
                                                  Text(
                                                      formatRupiah(bloc
                                                          .user
                                                          .valueWrapper
                                                          .value
                                                          .komisi),
                                                      style: TextStyle(
                                                          fontSize: 12.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.purple))
                                                ],
                                              ),
                                            ],
                                          )),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 8),
                                            child: Container(
                                              height: 30,
                                              width: 2,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          Container(
                                              child: Row(
                                            children: <Widget>[
                                              CircleAvatar(
                                                child: Image.network(
                                                    'https://firebasestorage.googleapis.com/v0/b/payuni-2019y.appspot.com/o/merchants%2Fpopay%2Fapk%2Freward.png?alt=media&token=7ff34a27-1c7b-4be6-981e-55e9dc7e313d',
                                                    color: Colors.orange),
                                                backgroundColor:
                                                    Colors.transparent,
                                                radius: 12.0,
                                                foregroundColor: Colors.purple,
                                              ),
                                              SizedBox(width: 5.0),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text('Poin',
                                                      style: TextStyle(
                                                          fontSize: 10.0)),
                                                  SizedBox(height: 2.0),
                                                  Text(
                                                      formatNominal(bloc
                                                              .user
                                                              .valueWrapper
                                                              .value
                                                              .poin) +
                                                          ' Pts',
                                                      style: TextStyle(
                                                          fontSize: 12.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.orange))
                                                ],
                                              ),
                                            ],
                                          )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  child: Image.asset(
                                    'assets/img/user.gif',
                                    width: innerWidth * 0.35,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          Text(
                            'Akun Saya',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16,
                              fontFamily: 'Nunito',
                            ),
                          ),
                          Divider(
                            thickness: 2.5,
                          ),
                          // SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => DetailProfile())),
                                borderRadius: BorderRadius.circular(20),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    child: Icon(
                                      Icons.person,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  title: Text(
                                    'Profile Detail',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Lihat Semua Informasi Tentang Akun Anda',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Divider(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () =>
                                    Navigator.of(context).pushNamed('/komisi'),
                                borderRadius: BorderRadius.circular(20),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    child: Icon(Icons.rate_review,
                                        color: Colors.purple),
                                  ),
                                  title: Text(
                                    'Komisi',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Lihat Rincian Komisi yang Anda Dapatkan',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Divider(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => InvitePage()),
                                ),
                                borderRadius: BorderRadius.circular(20),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    child: Icon(Icons.share_rounded,
                                        color: Colors.teal),
                                  ),
                                  title: Text(
                                    'Undang Teman',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Bagikan Link Undangan dan Dapatkan Bonus!',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Divider(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => Downline())),
                                borderRadius: BorderRadius.circular(20),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    child: Icon(Icons.people,
                                        color: Colors.deepOrangeAccent),
                                  ),
                                  title: Text(
                                    'Downline',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Pantau Perkembangan Jaringan Anda dan Tingkatkan Penghasilan',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Divider(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => ReportPage())),
                                borderRadius: BorderRadius.circular(20),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    child: Icon(Icons.note_add_outlined,
                                        color: Colors.greenAccent),
                                  ),
                                  title: Text(
                                    'Laporan',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Pantau dan Analisis Transaksi Serta Kinerja Bisnis Anda',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Divider(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PrintSettingsPage(),
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(20),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    child: Icon(
                                      Icons.print_rounded,
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                  title: Text(
                                    'Atur Printer',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Kelola dan Sesuaikan Pengaturan Printer Anda Dengan Mudah',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Divider(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return GantiPin();
                                  }));
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    child: Icon(
                                      Icons.fiber_pin,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  title: Text(
                                    'Ganti PIN',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Amankan akun Anda dengan mengganti PIN secara berkala',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Divider(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => EditToko()));
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    child: Icon(
                                      Icons.store,
                                      color: Colors.green[400],
                                    ),
                                  ),
                                  title: Text(
                                    'Ubah Toko',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Mudahnya mengelola edit profil toko Anda',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Divider(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => ListReward())),
                                borderRadius: BorderRadius.circular(20),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    child: Icon(
                                      Icons.view_list,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  title: Text(
                                    'Reward',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Kumpulkan dan tukarkan poin rewards Anda',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Divider(),
                          Text(
                            'Pelayanan',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16,
                              fontFamily: 'Nunito',
                            ),
                          ),
                          Divider(
                            thickness: 2.5,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => CS1()));
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    child: Icon(
                                      Icons.contact_phone,
                                      color: Colors.purple[400],
                                    ),
                                  ),
                                  title: Text(
                                    'Customer Service',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Hubungi kami untuk dukungan dan bantuan',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Divider(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
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
                                borderRadius: BorderRadius.circular(20),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    child: Icon(
                                      Icons.star,
                                      color: Colors.orange[400],
                                    ),
                                  ),
                                  title: Text(
                                    'Beri Ulasan',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Berikan ulasan dan rating untuk pengalaman Anda',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Divider(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: sendWhatsApp,
                                borderRadius: BorderRadius.circular(20),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    child: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red[400],
                                    ),
                                  ),
                                  title: Text(
                                    'Hapus Akun',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Hapus akun Anda dengan aman dan mudah',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Divider(),
                          Text(
                            'Aplikasi',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16,
                              fontFamily: 'Nunito',
                            ),
                          ),
                          Divider(
                            thickness: 2.5,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => AboutAppPage())),
                                borderRadius: BorderRadius.circular(20),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    child: Icon(
                                      Icons.info_outline,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                  title: Text(
                                    'Tentang Aplikasi',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Temukan fitur dan pembaruan aplikasi terbaru',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Divider(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  DefaultCacheManager()
                                      .emptyCache()
                                      .then((value) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Berhasil memperbarui konten')));
                                  }).catchError((err) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Gagal memperbarui konten')));
                                  });
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    child: Icon(
                                      Icons.refresh,
                                      color: Colors.indigoAccent,
                                    ),
                                  ),
                                  title: Text(
                                    'Perbarui Konten',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Dapatkan konten dan informasi terbaru dari kami',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Divider(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: keluar,
                                borderRadius: BorderRadius.circular(20),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    child: Icon(
                                      Icons.lock_open,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  title: Text(
                                    'Keluar',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Keluar dari akun Anda dengan aman',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

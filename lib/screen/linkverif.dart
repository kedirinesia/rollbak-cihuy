import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import '../component/bezierContainer.dart';
import 'login.dart';

class LinkVerifPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: configAppBloc.iconApp.valueWrapper?.value['texture'] != null
              ? DecorationImage(
                  image: CachedNetworkImageProvider(
                    configAppBloc.iconApp.valueWrapper?.value['texture'] ?? '',
                  ),
                  fit: BoxFit.fitWidth,
                )
              : null,
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -MediaQuery.of(context).size.height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer(),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    configAppBloc.iconApp.valueWrapper?.value['logoLogin'] !=
                            null
                        ? CachedNetworkImage(
                            imageUrl: configAppBloc
                                    .iconApp.valueWrapper?.value['logoLogin'] ??
                                '',
                            height: MediaQuery.of(context).size.width * .18,
                            fit: BoxFit.contain,
                          )
                        : Text(
                            configAppBloc.namaApp.valueWrapper?.value ?? '',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                    SizedBox(height: 40),
                    Text(
                      'Link verifikasi sudah dikirim ke email Anda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Silakan periksa email Anda dan klik link verifikasi sebelum akun dihapus.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Jika email tidak muncul, cek folder Spam di Gmail Anda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => configAppBloc.layoutApp.valueWrapper?.value['login'] ?? LoginPage(),
                          ),
                          (route) => false,
                        );
                      },
                      icon: Icon(Icons.arrow_back),
                      label: Text('Kembali ke Login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        textStyle: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

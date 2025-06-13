import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mobile/Products/ayoba/layout/login.dart';
import 'package:mobile/Products/ayoba/layout/privacy_policy.dart';
import 'package:nav/nav.dart';
import 'package:mobile/Products/ayoba/layout/register.dart';

class LoginWizardPage extends StatefulWidget {
  const LoginWizardPage({Key? key}) : super(key: key);

  @override
  State<LoginWizardPage> createState() => _LoginWizardPageState();
}

class _LoginWizardPageState extends State<LoginWizardPage> {
  List<Widget> _images = [
    Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/img/ayoba/slide1.png'),
              fit: BoxFit.cover)),
    ),
    Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/img/ayoba/slide2.png'),
              fit: BoxFit.cover)),
    ),
    Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/img/ayoba/slide3.png'),
              fit: BoxFit.cover)),
    ),
  ];
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CarouselSlider.builder(
            itemCount: _images.length,
            options: CarouselOptions(
                height: MediaQuery.of(context).size.height,
                aspectRatio: MediaQuery.of(context).size.width /
                    MediaQuery.of(context).size.height,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 5),
                viewportFraction: 1,
                onPageChanged: (value, _) {
                  setState(() {
                    _index = value;
                  });
                }),
            itemBuilder: (_, i, __) {
              return _images[i];
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _images.length,
                    (index) {
                      double size = 8;

                      if (index == _index) {
                        return Container(
                          width: size + 4,
                          height: size + 4,
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular((size + 4) / 2),
                          ),
                        );
                      } else {
                        return Container(
                          width: size,
                          height: size,
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(size / 2),
                          ),
                          child: Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(.25),
                              borderRadius: BorderRadius.circular(size / 2),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(.2),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => Nav.push(PrivacyPolicyPage()),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(25),
                                  topRight: Radius.circular(25),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Belum punya akun',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => Nav.pushFromBottom(Login()),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: Center(
                                child: Text(
                                  'Sudah punya akun',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

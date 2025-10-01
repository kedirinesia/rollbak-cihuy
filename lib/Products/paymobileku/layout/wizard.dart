import 'package:flutter/material.dart';
import 'package:mobile/Products/paymobileku/layout/login.dart';

class StartWizardPage extends StatefulWidget {
  const StartWizardPage({Key? key}) : super(key: key);

  @override
  State<StartWizardPage> createState() => _StartWizardPageState();
}

class _StartWizardPageState extends State<StartWizardPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  final List<String> _images = [
    // 'assets/img/paymobileku/splash1.png',
    // 'assets/img/paymobileku/splash2.png',
    'assets/img/paymobileku/wizard1.jpeg',
    'assets/img/paymobileku/wizard2.jpeg',
    'assets/img/paymobileku/wizard3.jpeg',
  ];

  Future<void> _precacheImage() async {
    _images.map((e) async => await precacheImage(AssetImage(e), context));
  }

  @override
  void initState() {
    super.initState();
    _precacheImage();
    _tabController = TabController(
        initialIndex: _selectedIndex, length: _images.length, vsync: this);
    _tabController.addListener(() => setState(() {
          _selectedIndex = _tabController.index;
        }));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          TabBarView(
            controller: _tabController,
            children: _images
                .map((e) => Image.asset(
                      e,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ))
                .toList(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              // decoration: BoxDecoration(
              //   color: Colors.black.withOpacity(.5),
              // ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MaterialButton(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Text(
                        //   _selectedIndex == 1
                        //       ? 'Mulai'.toUpperCase()
                        //       : 'Lanjut'.toUpperCase(),
                        //   style: TextStyle(
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        Text(
                          _selectedIndex == 0
                              ? 'Mulai'.toUpperCase()
                              : _selectedIndex == 1
                                  ? 'Next'.toUpperCase()
                                  : 'Lanjut'.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.navigate_next_rounded,
                        ),
                      ],
                    ),
                    shape: StadiumBorder(),
                    color: Colors.white,
                    // onPressed: () {
                    //   if (_selectedIndex == 1) {
                    //     Navigator.of(context).pushReplacement(
                    //       MaterialPageRoute(
                    //         builder: (_) => LoginPage(),
                    //       ),
                    //     );
                    //   } else {
                    //     _tabController.animateTo(_selectedIndex + 1);
                    //   }
                    // },
                    onPressed: () {
                      if (_selectedIndex == _images.length - 1) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => LoginPage(),
                          ),
                        );
                      } else {
                        _tabController.animateTo(_selectedIndex + 1);
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_images.length, (i) {
                      return Container(
                        width: 10,
                        height: 10,
                        margin: EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: i == _selectedIndex
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mobile/Products/santren/layout/login.dart';

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
    'assets/img/santren/splash1.jpg',
    'assets/img/santren/splash2.jpg',
  ];

  Future<void> _precacheImage() async {
    for (var e in _images) {
      await precacheImage(AssetImage(e), context);
    }
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
                .map(
                  (e) => Center(
                    child: FractionallySizedBox(
                      widthFactor: 1.0,
                      heightFactor: 0.95,
                      child: Image.asset(
                        e,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MaterialButton(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedIndex == 1
                              ? 'Mulai'.toUpperCase()
                              : 'Lanjut'.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.navigate_next_rounded,
                        ),
                      ],
                    ),
                    shape: const StadiumBorder(),
                    color: Colors.white,
                    onPressed: () {
                      if (_selectedIndex == 1) {
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
                  const SizedBox(height: 20),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_images.length, (i) {
                      return Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
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

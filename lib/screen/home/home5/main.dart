import 'package:flutter/material.dart';
import 'package:mobile/bloc/Bloc.dart';
import 'package:mobile/screen/history/history.dart';
import 'package:mobile/screen/profile/profile.dart';

import './home5.dart';

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  Color mainColor = Colors.white;
  Color mainTextColor = Colors.blue;

  List<Widget> halaman = [Home5App(), HistoryPage(), ProfilePage()];
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();

    bloc.mainColor
      ..listen((Color color) {
        setState(() {
          mainColor = color;
        });
      });
    bloc.mainTextColor
      ..listen((Color color) {
        setState(() {
          mainTextColor = color;
        });
      });

    changePrimaryColor();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void changePrimaryColor() {
    if (mounted) {
      setState(() {
        mainTextColor = Colors.purple;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        // appBar: AppBar(
        //   title: Text(configAppBloc.namaApp.valueWrapper?.value, style: TextStyle(color: Colors.white)),
        //   backgroundColor: Theme.of(context).primaryColor,
        //   elevation: 0.0,
        //   actions: <Widget>[
        //     IconButton(
        //       icon: Icon(Icons.chat, color: Colors.white), onPressed: () {
        //         if (configAppBloc.liveChat.valueWrapper?.value != '') {
        //           return Navigator.of(context).push(
        //               MaterialPageRoute(
        //                   builder: (context) =>
        //                       Webview('Live Chat Support', configAppBloc.liveChat.valueWrapper?.value)));
        //         } else {
        //           return null;
        //         }
        //     }),
        //     IconButton(
        //       color: Colors.white,
        //       icon: Icon(Icons.notifications),
        //       onPressed: () {
        //         Navigator.of(context).pushNamed('/notifikasi');
        //       },
        //     )
        //   ],
        // ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: pageIndex,
          onTap: (index) {
            setState(() {
              pageIndex = index;
            });
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.apps),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
        body: halaman[pageIndex]);
  }
}

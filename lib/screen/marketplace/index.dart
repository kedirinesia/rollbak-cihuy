import 'package:flutter/material.dart';
import 'package:mobile/screen/marketplace/history.dart';
import 'package:mobile/screen/marketplace/home.dart';
import 'package:mobile/screen/marketplace/list_produk.dart';

class MarketPage extends StatefulWidget {
  @override
  _MarketPageState createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  int _index = 0;
  List<Widget> pages = [
    HomePage(),
    ListProdukMarketplace(),
    HistoryOrderPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(.25),
                offset: Offset(0, -5),
                blurRadius: 25,
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.home_rounded,
                  color: _index == 0
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _index = 0;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.view_list_rounded,
                  color: _index == 1
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _index = 1;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.history_rounded,
                  color: _index == 2
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _index = 2;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// @dart=2.9

import 'package:flutter/material.dart';
import 'package:mobile/config.dart';

class TemplateMain extends StatelessWidget {
  final List<Widget> children;
  final String title;
  final Color backgroundColor;
  final FloatingActionButton floatingActionButton;
  final FloatingActionButtonLocation floatingActionButtonLocation;

  TemplateMain(
      {Key key,
      @required this.children,
      this.title,
      this.backgroundColor,
      this.floatingActionButton,
      this.floatingActionButtonLocation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        bottomNavigationBar: floatingActionButton != null
            ? BottomAppBar(
                clipBehavior: Clip.antiAlias,
                shape: AutomaticNotchedShape(RoundedRectangleBorder(),
                    StadiumBorder(side: BorderSide())),
                child: Material(
                  child: SizedBox(width: double.infinity, height: 50.0),
                  color: Theme.of(context).primaryColor,
                ),
              )
            : null,
        backgroundColor: Colors.white,
        body: CustomScrollView(slivers: <Widget>[
          SliverAppBar(
            iconTheme: IconThemeData(color: Colors.white),
            expandedHeight: 200.0,
            backgroundColor: backgroundColor != null
                ? backgroundColor
                : packageName == 'com.lariz.mobile'
                    ? Theme.of(context).secondaryHeaderColor
                    : Theme.of(context).primaryColor,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
                title: Text(title, style: TextStyle(fontSize: 12.0)),
                centerTitle: true),
          ),
          SliverList(
            delegate: SliverChildListDelegate(children),
          )
        ]));
  }
}

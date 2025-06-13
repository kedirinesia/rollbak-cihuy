// @dart=2.9
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/bloc/ConfigApp.dart';

class TemplatePopay extends StatefulWidget {
  final Widget body;
  final String title;
  final double height;
  final List<Widget> children;
  final Color backgroundColor;
  final FloatingActionButton floatingActionButton;
  final FloatingActionButtonLocation floatingActionButtonLocation;

  TemplatePopay(
      {this.title,
      this.body,
      this.height,
      this.children,
      this.backgroundColor,
      this.floatingActionButton,
      this.floatingActionButtonLocation});

  @override
  _TemplatePopayState createState() => _TemplatePopayState();
}

class _TemplatePopayState extends State<TemplatePopay> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Stack(children: <Widget>[
          Container(
            height: widget.height ?? 100.0,
            width: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: CachedNetworkImageProvider(configAppBloc
                        .iconApp.valueWrapper?.value['imageAppbar']),
                    fit: BoxFit.cover)),
          ),
          Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                title: Text(widget.title),
              ),
              body: widget.body)
        ]));
  }
}

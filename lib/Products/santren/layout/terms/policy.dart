// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownDisplayScreen extends StatelessWidget {
  MarkdownDisplayScreen({
    Key key,
    this.radius = 8,
    @required this.mdFileName,
  })  : assert(mdFileName.contains('.md'),
            'The file must contain the .md extension'),
        super(key: key);

  final String mdFileName;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: Future.delayed(Duration(milliseconds: 150)).then((value) {
          return rootBundle.loadString('assets/img/santren/$mdFileName');
        }),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              child: Markdown(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                data: snapshot.data,
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

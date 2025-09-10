import 'package:flutter/widgets.dart';
import 'package:mobile/utils/debug_helper.dart';

class CustomScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

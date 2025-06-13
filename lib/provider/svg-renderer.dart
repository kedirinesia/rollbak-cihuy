// @dart=2.9

import 'package:flutter/services.dart' show rootBundle;

class SvgRenderer {
  Future<String> getSvg(String fileLocation, String color) async {
    String svgString = await rootBundle.loadString(fileLocation);
    if (svgString.isNotEmpty) {
      svgString = svgString.replaceAll('6d66d8', color);
      return svgString;
    } else {
      return null;
    }
  }
}

import 'package:flutter/material.dart';

/// Alternative to division package for styling widgets
class StyleHelper {
  /// Create a styled container similar to ParentStyle
  static Widget styledContainer({
    required Widget child,
    EdgeInsets? padding,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
    double? width,
    double? height,
    Alignment? alignment,
    BoxDecoration? decoration,
  }) {
    return Container(
      width: width,
      height: height,
      alignment: alignment,
      padding: padding,
      decoration: decoration ??
          BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            border: border,
            boxShadow: boxShadow,
          ),
      child: child,
    );
  }

  /// Create a styled text widget
  static Widget styledText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Create a styled row
  static Widget styledRow({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
  }) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }

  /// Create a styled column
  static Widget styledColumn({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
  }) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }
}

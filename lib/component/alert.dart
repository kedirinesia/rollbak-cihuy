// @dart=2.9

import 'package:flutter/material.dart';

enum AlertType { error, info, success, warning }

class Alert extends SnackBar {
  final String text;
  final bool isError;

  Alert(this.text, {this.isError})
      : super(
          backgroundColor:
              isError ?? false ? Colors.red[600] : Colors.green[600],
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                isError ?? false ? Icons.error : Icons.info,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Flexible(
                flex: 1,
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
}

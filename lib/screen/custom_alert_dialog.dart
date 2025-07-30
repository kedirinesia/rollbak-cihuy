import 'package:flutter/material.dart';

enum DialogType { success, error, warning, question }

void showCustomDialog({
  required BuildContext context,
  required String title,
  required String content,
  String buttonText = 'Okay',
  DialogType type = DialogType.error,
  VoidCallback? onButtonPressed,
  VoidCallback? onConfirmed,
}) {
  Image image;

  switch (type) {
    case DialogType.success:
      image = Image.asset('assets/img/success.gif', width: 100);
      break;
    case DialogType.error:
      image = Image.asset('assets/img/wrong.gif', width: 100);
      break;
    case DialogType.warning:
      image = Image.asset('assets/img/warning.gif', width: 100);
      break;
    case DialogType.question:
      image = Image.asset('assets/img/question.gif', width: 100);
      break;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 10),
              Container(child: image),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 15),
              Text(
                content,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 22),
              Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    ),
                    onPressed: () {
                      // if (onButtonPressed != null) {
                      //   onButtonPressed();
                      // } else {
                      //   Navigator.of(context).pop();
                      // }
                      Navigator.of(context).pop();
                      if (onConfirmed != null) {
                        onConfirmed();
                      }
                    },
                    child: Text(
                      buttonText,
                      style: TextStyle(fontSize: 18),
                    ),
                  )),
            ],
          ),
        ),
      );
    },
  );
}

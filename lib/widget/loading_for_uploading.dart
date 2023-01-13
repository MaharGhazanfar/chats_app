import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingForUpload {
  static onLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const CupertinoActivityIndicator(
          radius: 30,
          color: Colors.black87,
        );
      },
    );
  }

  static hideDialog(BuildContext context) {
    Navigator.pop(context);
  }
}

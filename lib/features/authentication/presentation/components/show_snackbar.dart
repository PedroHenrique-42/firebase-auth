import 'package:flutter/material.dart';

void showSnackBar(
  BuildContext context, {
  required String message,
  bool isError = true,
}) {
  SnackBar snackBar = SnackBar(
    content: Text(message),
    backgroundColor: (isError) ? Colors.red : Colors.green,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

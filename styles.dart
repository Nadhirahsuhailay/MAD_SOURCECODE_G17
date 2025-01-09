import 'package:flutter/material.dart';

class Styles {
  static BoxDecoration containerStyle = BoxDecoration(
    color: Colors.grey[300],
    borderRadius: BorderRadius.circular(10),
  );

  static TextStyle textStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.red,
  );
}

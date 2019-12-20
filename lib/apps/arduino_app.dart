import 'package:arduino_rc_car/pages/pages.dart';
import 'package:flutter/material.dart';

class ArduinoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arduino RC',
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
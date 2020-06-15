import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:control_pad/control_pad.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ControlPage extends StatefulWidget {
  ControlPage({@required this.device, @required this.connection});

  final BluetoothDevice device;
  final BluetoothConnection connection;

  @override
  State<StatefulWidget> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  static const int _STOP = 0;
  static const int _FORWARD = 1;
  static const int _BACKWARD = 2;
  static const int _FORWARD_RIGHT = 3;
  static const int _FORWARD_LEFT = 4;
  static const int _BACKWARD_RIGHT = 5;
  static const int _BACKWARD_LEFT = 6;

  StreamSubscription<Uint8List> _subscription;

  @override
  void initState() {
    print('Connection in progress: ${widget.device.name ?? widget.device.address}');
    _subscription = widget.connection.input.listen((data) {
      print('IN: $data');
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    widget.connection.finish().then((_) {
      print('Connection finished');
    }).catchError((error) {
      print('ERROR: $error');
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Android RC - ${widget.device.name ?? widget.device.address}'),
      ),
      body: Container(
        child: Center(
          child: JoystickView(
            onDirectionChanged: _handleJoystickDirectionChanged,
            size: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.8,
          ),
        ),
      ),
    );
  }

  void _handleJoystickDirectionChanged(double degrees, double distance) {
    int value = _STOP;

    if(distance.abs() > 0.5) {
      double sector = degrees / 45.0;

      if((sector >= 0 && sector < 1) || (sector >= 7 && sector < 8)) {
        value = _FORWARD;
      }

      if(sector >= 1 && sector < 2) {
        value = _FORWARD_RIGHT;
      }

      if(sector >= 2 && sector < 3) {
        value = _BACKWARD_RIGHT;
      }

      if(sector >= 3 && sector < 5) {
        value = _BACKWARD;
      }

      if(sector >= 5 && sector < 6) {
        value = _BACKWARD_LEFT;
      }

      if(sector >= 6 && sector < 7) {
        value = _FORWARD_LEFT;
      }
    }

    print('OUT: ${ascii.encode('$value')}');
    widget.connection.output.add(ascii.encode('$value'));
  }
}
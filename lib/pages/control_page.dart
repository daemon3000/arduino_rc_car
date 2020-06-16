import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:arduino_rc_car/models/direction.dart';
import 'package:flutter/material.dart';
import 'package:control_pad/control_pad.dart';
import 'package:flutter/services.dart';
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
  Direction _direction = Direction.zero();

  @override
  void initState() {
    print('Connection in progress: ${widget.device.name ?? widget.device.address}');
    _subscription = widget.connection.input.listen((data) {
      print('IN: $data');
    });

    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
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

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Android RC - ${widget.device.name ?? widget.device.address}'),
      ),
      body: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            JoystickView(
              onDirectionChanged: _handleYJoystickChanged,
            ),
            JoystickView(
              onDirectionChanged: _handleXJoystickChanged,
            ),
          ],
        ),
      ),
    );
  }

  void _handleXJoystickChanged(double degrees, double distance) {
    int x = 0;

    if(distance.abs() > 0.5) {
      x = degrees >= 0.0 && degrees <= 180.0 ? 1 : -1;
    }

    _changeDirection(_direction.withX(x));
  }

  void _handleYJoystickChanged(double degrees, double distance) {
    int y = 0;

    if(distance.abs() > 0.5) {
      y = (degrees >= 270.0 && degrees <= 360) || (degrees >= 0 && degrees <= 90.0) ? 1 : -1;
    }

    _changeDirection(_direction.withY(y));
  }

  void _changeDirection(Direction direction) {
    int value = _STOP;

    if(direction.y > 0) {
      if(direction.x > 0){
        value = _FORWARD_RIGHT;
      }
      else if(direction.x < 0) {
        value = _FORWARD_LEFT;
      }
      else {
        value = _FORWARD;
      }
    }
    else if(direction.y < 0) {
      if(direction.x > 0){
        value = _BACKWARD_RIGHT;
      }
      else if(direction.x < 0) {
        value = _BACKWARD_LEFT;
      }
      else {
        value = _BACKWARD;
      }
    }
    else if(direction.x > 0){
      value = _FORWARD_RIGHT;
    }
    else if(direction.x < 0) {
      value = _FORWARD_LEFT;
    }

    print('OUT: ${ascii.encode('$value')}');
    widget.connection.output.add(ascii.encode('$value'));

    _direction = direction;
  }
}
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
  static final Uint8List _STOP = Uint8List.fromList([0, 0, 0]);

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
    Uint8List bytes = _STOP;

    if(distance.abs() > 0.5) {
      bytes = _encodeDegrees(degrees);
    }

    print('OUT: ${degrees.toInt()} degrees');
    widget.connection.output.add(bytes);
  }

  Uint8List _encodeDegrees(double degrees) {
    final bytes = Uint8List(3);
    int q = degrees.toInt();
    int k = bytes.length - 1;

    bytes[0] = 1;     // 1 means we are moving.

    while(q > 0) {
      final t = q ~/ 256;
      bytes[k--] = q - t * 256;

      q = t;
    }

    return bytes;
  }
}
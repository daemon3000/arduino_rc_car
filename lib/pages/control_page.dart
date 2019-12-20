
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ControlPage extends StatefulWidget {
  ControlPage({@required this.device, @required this.connection});

  final BluetoothDevice device;
  final BluetoothConnection connection;

  @override
  State<StatefulWidget> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  StreamSubscription<Uint8List> _subscription;
  int _dx = 0;
  int _dy = 0;

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
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildControlButton('Forward', 0, 1),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildControlButton('Forward Left', -1, 1),
                SizedBox(width: 20),
                _buildControlButton('Forward Right', 1, 1),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildControlButton('Backward Left', -1, -1),
                SizedBox(width: 20),
                _buildControlButton('Backward Right', 1, -1),
              ],
            ),
            SizedBox(height: 20),
            _buildControlButton('Backward', 0, -1),
          ],
        ),
      ),
    );
  }

  _buildControlButton(String title, int dx, int dy) {
    return GestureDetector(
      onTapDown: (details) => _addInput(dx, dy),
      onTapUp: (details) => _removeInput(dx, dy),
      child: Container(
        height: 46,
        width: 130,
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text(title)),
          ),
        ),
      ),
    );
  }

  void _addInput(int dx, int dy) {
    _dx = max(-1, min(1, _dx + dx));
    _dy = max(-1, min(1, _dy + dy));
    _sendUpdatedInput();
  }

  void _removeInput(int dx, int dy) {
    _dx = max(-1, min(1, _dx - dx));
    _dy = max(-1, min(1, _dy - dy));
    _sendUpdatedInput();
  }

  void _sendUpdatedInput() {
    int value = 0;
    if(_dy > 0 && _dx == 0) value = 1;        //  FORWARD
    else if(_dy < 0 && _dx == 0) value = 2;   //  BACKWARD
    else if(_dy > 0 && _dx > 0) value = 3;    //  FORWARD-RIGHT
    else if(_dy > 0 && _dx < 0) value = 4;    //  FORWARD-LEFT
    else if(_dy < 0 && _dx > 0) value = 5;    //  BACKWARD-RIGHT
    else if(_dy < 0 && _dx < 0) value = 6;    //  BACKWARD-LEFT

    print('OUT: ${ascii.encode('$value')}');
    widget.connection.output.add(ascii.encode('$value'));
  }
}
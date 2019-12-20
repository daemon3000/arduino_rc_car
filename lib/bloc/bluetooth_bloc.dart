
import 'dart:async';

import 'package:arduino_rc_car/bloc/bloc_base.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:rxdart/rxdart.dart';

class BluetoothBloc implements BlocBase {
  BluetoothBloc() {
    _isOnStream = BehaviorSubject<bool>.seeded(false);
    _isScanningStream = BehaviorSubject<bool>.seeded(false);
    _scanResultsStream = BehaviorSubject<List<BluetoothDiscoveryResult>>.seeded([]);

    FlutterBluetoothSerial.instance.isEnabled.then((enabled) {
      _isOnStream.add(enabled);
    });
  }

  BehaviorSubject<List<BluetoothDiscoveryResult>> _scanResultsStream;
  BehaviorSubject<bool> _isOnStream;
  BehaviorSubject<bool> _isScanningStream;
  bool _isScanning = false;
  List<BluetoothDiscoveryResult> _scanResults = [];
  StreamSubscription<BluetoothDiscoveryResult> _subscription;

  bool get isScanningNow => _isScanning;
  Stream<bool> get isOn => _isOnStream;
  Stream<bool> get isScanning => _isScanningStream;
  Stream<List<BluetoothDiscoveryResult>> get scanResults => _scanResultsStream;

  void refreshStatus() {
    FlutterBluetoothSerial.instance.isEnabled.then((enabled) {
      _isOnStream.add(enabled);
    });
  }

  void scan() async {
    if(!_isScanning) {
      _isScanning = true;
      _isScanningStream.add(true);
      _scanResults.clear();
      _scanResultsStream.add(_scanResults);

      _cancelSubscription();
      _subscription = FlutterBluetoothSerial.instance.startDiscovery().listen(_handleDeviceDiscovered);
      _subscription.onDone(() {
        _isScanning = false;
        _isScanningStream.add(false);
      });
    }
  }

  @override
  void dispose() {
    _cancelSubscription();
    _isOnStream.close();
    _isScanningStream.close();
    _scanResultsStream.close();
  }

  void _handleDeviceDiscovered(BluetoothDiscoveryResult result) {
    _scanResults.add(result);
    _scanResultsStream.add(_scanResults);
  }

  void _cancelSubscription() {
    if(_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }
}
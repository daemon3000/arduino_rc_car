import 'package:arduino_rc_car/bloc/bluetooth_bloc.dart';
import 'package:arduino_rc_car/pages/control_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BluetoothBloc _bluetoothBloc;

  @override
  void initState() {
    _bluetoothBloc = BluetoothBloc();
    super.initState();
  }

  @override
  void dispose() {
    _bluetoothBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Android RC'),
        actions: <Widget>[
          _buildRefreshButton(context)
        ],
      ),
      body: StreamBuilder<bool>(
        stream:_bluetoothBloc.isOn,
        builder: (context, snapshot) {
          if(snapshot.hasData && snapshot.data) {
            return _buildPage(context);
          }
          else {
            return _buildNoConnectionWarning(context);
          }
        },
      ),
    );
  }

  Widget _buildRefreshButton(context) {
    return StreamBuilder<bool>(
      stream: _bluetoothBloc.isScanning,
      builder: (context, snapshot) {
        bool isScanning = snapshot.data ?? false;
        if(isScanning) {
          return Container(
            width: 64,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.white)
              )
            ),
          );
        }
        else {
          return Container(
            width: 64,
            child: Center(
              child: IconButton(
                icon: Icon(Icons.refresh, size: 32, color: Colors.white),
                onPressed: _scanForDevices,
              )
            ),
          );
        }
      }
    );
  }

  Widget _buildPage(BuildContext context) {
    return StreamBuilder<List<BluetoothDiscoveryResult>>(
      stream: _bluetoothBloc.scanResults,
      builder: (context, snapshot) {
        if(!snapshot.hasData)
          return Container();

        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            final result = snapshot.data[index];
            return Card(
              elevation: 2,
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('${result.device.name ?? result.device.address}:'),
                    Text('${result.rssi}dBm', style: _getRSSIStyle(result.rssi))
                  ],
                ),
                onTap: () => _connectToDevice(result.device),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNoConnectionWarning(BuildContext context) {
    return GestureDetector(
      onTap: _bluetoothBloc.refreshStatus,
      child: Container(
        child: Center(
          child: Text('Please enable Bluetooth on your device.'),
        ),
      ),
    );
  }

  void _scanForDevices() {
    _bluetoothBloc.scan();
  }

  void _connectToDevice(BluetoothDevice device) async {
    if(_bluetoothBloc.isScanningNow)
      return;

    _showConnectionInProgressPopup();

    BluetoothConnection.toAddress(device.address).then((connection) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) { 
        return ControlPage(device: device, connection: connection);
      }));
    }).catchError((error) {
      print('ERROR: $error');
      Navigator.of(context).pop();
      _showConnectionErrorPopup(error.toString());
    });
  }

  void _showConnectionInProgressPopup() {
    showDialog(context: context, barrierDismissible: false, builder: (context) {
      return AlertDialog(
        title: Text('Connecting...'),
        content: Container(
          height: 50,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    });
  }

  void _showConnectionErrorPopup(String error) {
    showDialog(context: context, barrierDismissible: true, builder: (context) {
      return AlertDialog(
        title: Text('Error'),
        content: Text(error),
      );
    });
  }

  TextStyle _getRSSIStyle(int rssi) {
    if (rssi >= -35) return TextStyle(color: Colors.greenAccent[700]);
    else if (rssi >= -45) return TextStyle(color: Color.lerp(Colors.greenAccent[700], Colors.lightGreen,        -(rssi + 35) / 10));
    else if (rssi >= -55) return TextStyle(color: Color.lerp(Colors.lightGreen,       Colors.lime[600],         -(rssi + 45) / 10));
    else if (rssi >= -65) return TextStyle(color: Color.lerp(Colors.lime[600],        Colors.amber,             -(rssi + 55) / 10));
    else if (rssi >= -75) return TextStyle(color: Color.lerp(Colors.amber,            Colors.deepOrangeAccent,  -(rssi + 65) / 10));
    else if (rssi >= -85) return TextStyle(color: Color.lerp(Colors.deepOrangeAccent, Colors.redAccent,         -(rssi + 75) / 10));
    else /*code symetry*/ return TextStyle(color: Colors.redAccent);
  }
}
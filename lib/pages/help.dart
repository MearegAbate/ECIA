import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:sqflite/sqflite.dart';
class Help extends StatefulWidget {
  @override
  _HelpState createState() => _HelpState();
}

class _HelpState extends State<Help> {

  Database database;
  StreamSubscription<BluetoothDiscoveryResult> _streamSubscription;
  Future getPermission() async{

    print('*******blue getpermission -----------');
    Future.doWhile(() async {
      await FlutterBluetoothSerial.instance.requestEnable();
      // Wait if adapter not enabled
      if (await FlutterBluetoothSerial.instance.isEnabled) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      _startDiscovery();
    });
  }
  void _startDiscovery() {
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
          print(r.device.name);
        });


  }
@override
  void initState() {
    getPermission();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Help'),),
      body: Center(child: RaisedButton(onPressed: _startDiscovery,child: Icon(Icons.refresh),),),
    );
  }
}

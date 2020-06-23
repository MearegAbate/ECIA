import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:sqflite/sqflite.dart';

//class BluetoothService {
  Database database;
  StreamSubscription<BluetoothDiscoveryResult> _streamSubscription;
//  BluetoothService() {
//   constructor();
//  }
bluetoothService()async{
    await _initDb();
    print('BluetoothService**************');
    await getPermission();
  }
  Future<void> _initDb() async {

    print('*******blue initDb -----------');
    final dbFolder = await getDatabasesPath();
    if (!await Directory(dbFolder).exists()) {
      await Directory(dbFolder).create(recursive: true);
    }
    final dbPath = join(dbFolder, 'ecia.db');
    database = await openDatabase(
      dbPath,
      version: 1,

    );
  }
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
       getDevices();
    });
  }
  Future getDevices()async {

    List<BluetoothDiscoveryResult> results = List<BluetoothDiscoveryResult>();
    print('*******blue getdevices -----------');
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      results.add(r);
    });

    _streamSubscription.onDone(() async{
     await sendData(results);
    });
  }

  Future sendData(results)async {

    print('*******blue senddata -----------');
    if (false) {
      //if network available
      talkToSql();
      //send data to api
    } else {
      await database.transaction((txn) async {
        int id2 ;
        for(var result in results) {
          id2 = await txn.rawInsert(
              'INSERT INTO blue(name, address) VALUES(?,?)',
              [result.device.name.toString(), result.device.address.toString()]);
          print('inserted2: $id2');
        }
      });
    }
    print(results.toString());
  }

  talkToSql() {
    //if data in database
    //send data to api
    //complete with out error delete the database
    //then return true
    //else
    //return false
  }
//}

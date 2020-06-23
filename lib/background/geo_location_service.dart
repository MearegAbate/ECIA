import 'dart:io';

import 'package:geolocation/geolocation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//class GeoLocationService {
  Database database;
//  GeoLocationService() {
//   constructor();
//  }
geoLocationService()async{
    await _initDb();
    print('GeoLocationService***************');
    await getPermission();
  }
  Future<void> _initDb() async {
    print('*******geo initdb -----------');
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
  Future<void> getPermission() async {
    print('*******geo getpermission -----------');
    final GeolocationResult result =
        await Geolocation.requestLocationPermission(
      permission: const LocationPermission(
        android: LocationPermissionAndroid.fine,
      ),
      openSettingsIfDenied: true,
    );

    if (result.isSuccessful) {
      // location permission is granted (or was already granted before making the request)
      await getDevices();
    } else {
      // location permission is not granted
      // user might have denied, but it's also possible that location service is not enabled, restricted, and user never saw the permission request dialog. Check the result.error.type for details.
    }
  }

  Future getDevices() async{
    print('*******geo getdevices -----------');
    Geolocation.currentLocation(accuracy: LocationAccuracy.best)
        .listen((result) {
      if (result.isSuccessful) {
        sendData(result.location);
      }
    });
  }

  sendData(location) async {
    print('*******geo senddata -----------');
    if (false) {
      //if network available
     await talkToSql();
      //send data to api
    } else {
      await database.transaction((txn) async {
        int id2 = await txn.rawInsert(
            'INSERT INTO gps(latitude, longitude) VALUES(?,?)',
            [location.latitude.toString(), location.longitude.toString()]);
        print('inserted2: $id2');
      });
    }
  }

  talkToSql() async{
    //if data in database
    //send data to api
    //complete with out error delete the database
    //then return true
    //else
    //return false
  }
//}

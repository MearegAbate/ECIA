import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sql.dart';
import 'package:path/path.dart';

class LocalData extends StatefulWidget {
  @override
  _LocalDataState createState() => _LocalDataState();
}

class _LocalDataState extends State<LocalData> {
  Database database;
  List<Map<String, dynamic>> gps = [];
  List<Map<String, dynamic>> blue = [];
  initState() {
    _getData();
    super.initState();
  }

  Future<void> _initDb() async {
    final dbFolder = await getDatabasesPath();
    if (!await Directory(dbFolder).exists()) {
      await Directory(dbFolder).create(recursive: true);
    }
    final dbPath = join(dbFolder, 'ecia.db');
    this.database = await openDatabase(
      dbPath,
      version: 1,
    );
  }

  Future<void> _getData() async {
    await _initDb();
    List<Map<String, dynamic>> _gps =
        await this.database.rawQuery('SELECT * FROM gps');
    setState(() {
      gps = _gps != null ? _gps : [];
    });
    List<Map<String, dynamic>> _blue =
        await this.database.rawQuery('SELECT * FROM blue ');
    setState(() {
      blue = _blue != null ? _blue : [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Local Data'),
      ),
      body: Column(
        children: <Widget>[
          ListView.builder(
              shrinkWrap: true,
              itemCount: gps.length,
              itemBuilder: (context, index) {
                return Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(gps[index]['latitude']),
                Text(gps[index]['longitude']),
                  ],
                );
              }),
          Divider(height: 10,),
          ListView.builder(
              shrinkWrap: true,
              itemCount: blue.length,
              itemBuilder: (context, index) {
                return Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(blue[index]['name']),
                    Text(blue[index]['address']),
                  ],
                );
              }),
        ],
      ),
    );
  }
}

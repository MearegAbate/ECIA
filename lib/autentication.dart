import 'package:eciafinal/background/bluetooth_service.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:call_log/call_log.dart';

import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'mainPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'model/language.dart';

class Autentication extends StatefulWidget {
  final int index;
  Autentication({this.index});
  @override
  _AutenticationState createState() => _AutenticationState();
}

class _AutenticationState extends State<Autentication> {
  TextEditingController fName = new TextEditingController();
  TextEditingController lName = new TextEditingController();
  TextEditingController gName = new TextEditingController();
  TextEditingController phoneNumber = new TextEditingController();
  TextEditingController btnName = new TextEditingController();
  TextEditingController btnAddress = new TextEditingController();
  List<SimCard> simCards = [];
  Map language;
  String _address = "";
  String _name = "";
  Iterable<Contact> _contacts;
  Database database;
  Iterable<CallLogEntry> _callLogEntries;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    language = languageAll[widget.index];
    a();
    getContacts();
    Future.doWhile(() async {
      await FlutterBluetoothSerial.instance.requestEnable();
      // Wait if adapter not enabled
      if (await FlutterBluetoothSerial.instance.isEnabled) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name;
      });
    });
    _initDb();
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
      onCreate: (Database db, int version) async {
        await db.execute('''
        CREATE TABLE blue(
          id INTEGER PRIMARY KEY, 
          name TEXT NOT NULL,
          address TEXT NOT NULL)
        ''');
        await db.execute('''
        CREATE TABLE gps(
          id INTEGER PRIMARY KEY, 
          latitude TEXT NOT NULL,
          longitude TEXT NOT NULL)
        ''');
      },
    );
  }

  Future<void> getContacts() async {
    //We already have permissions for contact when we get to this page, so we
    // are now just retrieving it
    final Iterable<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts;
    });
  }

  Future<void> getAllCallLogs() async {
    var result = await CallLog.query();
    setState(() {
      _callLogEntries = result;
    });
  }

  a() async {
    List<SimCard> _simCards = await MobileNumber.getSimCards;
    setState(() {
      simCards = _simCards;
    });
  }

  String nameValidate(String value) {
    if (value.isEmpty) {
      return 'Please enter valid input';
    }
    return null;
  }

  register(context) {
    if (true /*_formKey.currentState.validate()*/) {
      Map put = {
        'fullName': '${fName.text} ${lName.text} ${gName.text}',
        'phoneNumber': [phoneNumber.text],
        'btName': btnName.text,
        'btAddress': btnAddress.text
      };
      if (put.isNotEmpty) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MainPage(index: widget.index)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Theme(
        data: ThemeData.light(),
        child: Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(30),
            child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    buildTextFormField(fName, language['name'], nameValidate),
                    buildTextFormField(
                        lName, language['fatherName'], nameValidate),
                    buildTextFormField(
                        gName, language['gFatherName'], nameValidate),
                    simCards.length == 0
                        ? buildTextFormField(
                            phoneNumber, language['phoneNumber'], nameValidate)
                        : mobileNumbers(),
                    _name == ''
                        ? buildTextFormField(
                            btnName, language['bluetoothName'], nameValidate)
                        : blue(_name),
                    _address == ''
                        ? buildTextFormField(btnAddress,
                            language['bluetoothAdress'], nameValidate)
                        : blue(_address),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      child: FlatButton(
                        onPressed: () => register(context),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.green[500],
                              borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.all(15),
                          alignment: Alignment.center,
                          child: Text(
                            language['register'],
                            style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                )),
          ),
        ),
      ),
    );
  }

  buildTextFormField(controller, lable, validator) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: TextFormField(
        controller: controller,
        style: TextStyle(fontSize: 19),
        decoration: InputDecoration(
          labelText: lable,
          labelStyle: TextStyle(fontSize: 18),
          border: OutlineInputBorder(
              borderSide: BorderSide(
            color: Colors.white,
          )),
        ),
        validator: validator,
      ),
    );
  }

  mobileNumbers() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: simCards.length,
      itemBuilder: (BuildContext context, index) {
        return Column(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                simCards[index].number.toString(),
                style: TextStyle(fontSize: 18),
              ),
            ),
            Divider(
              thickness: 3,
            ),
          ],
        );
      },
    );
  }

  blue(value) {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            value,
            style: TextStyle(fontSize: 18),
          ),
        ),
        Divider(
          thickness: 3,
        ),
      ],
    );
  }
}

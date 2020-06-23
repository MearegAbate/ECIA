import 'dart:io';
import 'dart:async';
import 'package:eciafinal/background/bluetooth_service.dart';
import 'package:eciafinal/background/geo_location_service.dart';
import 'package:flutter/material.dart';

import 'autentication.dart';
import 'package:mobile_number/mobile_number.dart';

import 'package:background_fetch/background_fetch.dart';

import 'package:permission_handler/permission_handler.dart';

/// This "Headless Task" is run when app is terminated.
void backgroundFetchHeadlessTask(String taskId) async {
  print("[BackgroundFetch] Headless event received: $taskId");
  DateTime timestamp = DateTime.now();

  await bluetoothService();
  await geoLocationService();
  BackgroundFetch.finish(taskId);

  if (taskId == 'flutter_background_fetch') {
    BackgroundFetch.scheduleTask(TaskConfig(
      taskId: "com.transistorsoft.customtask",
      delay: 5000,
      periodic: false,
      forceAlarmManager: true,
      stopOnTerminate: false,
      enableHeadless: true,
      startOnBoot: true,
    ));
  }
}

void main() {
  runApp(App());
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ethiopia Corona Investigation App',
      theme: ThemeData.dark(),
      home: Welcome(),
    );
  }
}

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  void initState() {
    Timer(Duration(seconds: 2), () {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => ChooseLanguage()))
          .whenComplete(() => exit(0));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/img/ECIA/ECIACover.jpg'),
                  fit: BoxFit.cover)),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(50),
              child: Image.asset('assets/img/ECIA/ECIApng.png'),
            ),
          )),
    );
  }
}

class ChooseLanguage extends StatefulWidget {
  ChooseLanguage({Key key}) : super(key: key);

  @override
  _ChooseLanguageState createState() => _ChooseLanguageState();
}

@override
void initState() {
  a();
  _getPermission();
}

Future<PermissionStatus> _getPermission() async {
  final PermissionStatus permission = await Permission.contacts.status;
  if (permission != PermissionStatus.granted &&
      permission != PermissionStatus.denied) {
    final Map<Permission, PermissionStatus> permissionStatus =
        await [Permission.contacts].request();
    return permissionStatus[Permission.contacts] ??
        PermissionStatus.undetermined;
  } else {
    return permission;
  }
}

a() async {
  if (!await MobileNumber.hasPhonePermission)
    await MobileNumber.requestPhonePermission;
}

class _ChooseLanguageState extends State<ChooseLanguage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 30, bottom: 40),
                child: Text(
                  'Choose Language'.toUpperCase(),
                  style: TextStyle(
                    fontSize: 30,
                    letterSpacing: 2,
                    wordSpacing: 2,
                    color: Color(0xff1d86b6),
                  ),
                ),
              ),
              buildContainer('Amharic', 0),
              buildContainer('Affan Oromo', 1),
              buildContainer('English', 2),
            ],
          ),
        ),
      ),
    );
  }

  buildContainer(language, index) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Autentication(index: index)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
            border: Border.all(color: Color(0xff5fbbfa)),
            borderRadius: BorderRadius.circular(30)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              language,
              style: TextStyle(
                fontSize: 22,
                // color: Color(0xff1d86b6),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Color(0xff5fbbfa),
              size: 25,
            )
          ],
        ),
      ),
    );
  }
}

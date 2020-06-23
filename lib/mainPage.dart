import 'dart:io';
import 'package:eciafinal/background/bluetooth_service.dart';
import 'package:eciafinal/background/geo_location_service.dart';
import 'package:eciafinal/pages/localData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'model/language.dart';
import 'pages/about.dart';
import 'pages/covid19Info.dart';
import 'pages/faq.dart';
import 'pages/help.dart';
import 'pages/home.dart';
import 'pages/selfTesting.dart';
import 'package:background_fetch/background_fetch.dart';

class MainPage extends StatefulWidget {
  final int index;
  MainPage({this.index});
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var _currentIndex = 0;
  Map language;

  int _status = 0;
  @override
  void initState() {
    language = languageAll[widget.index];

    initPlatformState();
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Load persisted fetch events from SharedPreferences

    // Configure BackgroundFetch.
    BackgroundFetch.configure(
            BackgroundFetchConfig(
              minimumFetchInterval: 15,
              forceAlarmManager: false,
              stopOnTerminate: false,
              startOnBoot: true,
              enableHeadless: true,
              requiresBatteryNotLow: false,
              requiresCharging: false,
              requiresStorageNotLow: false,
              requiresDeviceIdle: false,
              requiredNetworkType: NetworkType.NONE,
            ),
            _onBackgroundFetch)
        .then((int status) {
      print('[BackgroundFetch] configure success: $status');
      setState(() {
        _status = status;
      });
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
      setState(() {
        _status = e;
      });
    });

    // Schedule a "one-shot" custom-task in 10000ms.
    // These are fairly reliable on Android (particularly with forceAlarmManager) but not iOS,
    // where device must be powered (and delay will be throttled by the OS).
    BackgroundFetch.scheduleTask(TaskConfig(
      taskId: "com.transistorsoft.customtask",
      delay: 10000,
      periodic: false,
      forceAlarmManager: true,
      stopOnTerminate: false,
      enableHeadless: true,
      startOnBoot: true,
    ));

    // Optionally query the current BackgroundFetch status.
    int status = await BackgroundFetch.status;
    setState(() {
      _status = status;
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  void _onBackgroundFetch(String taskId) async {
    DateTime timestamp = new DateTime.now();
    // This is the fetch-event callback.
    print("[BackgroundFetch] Event received: $taskId");
    await bluetoothService();
    await geoLocationService();
    // Persist fetch events in SharedPreferences

    if (taskId == "flutter_background_fetch") {
      // Schedule a one-shot task when fetch event received (for testing).
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

    // IMPORTANT:  You must signal completion of your fetch task or the OS can punish your app
    // for taking too long in the background.
    BackgroundFetch.finish(taskId);
  }

  @override
  Widget build(BuildContext context) {
    var pages = [
      Home(),
      SelfTesting(index: widget.index),
      Covid19Info(index: widget.index),
      FAQ(index: widget.index),
    ];
    var titles = [
      language['welcome'],
      language['selfTesting'],
      language['covid19Info'],
      language['faq'],
    ];
    return Scaffold(
      appBar: buildAppBar(titles),
      body: pages[_currentIndex],
      drawer: buildDrawer(context),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  AppBar buildAppBar(titles) {
    return AppBar(
      title: Text(
        titles[_currentIndex],
      ),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 10),
            child: Image.asset('assets/img/ECIA/ECIApng2.png'),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                buildFlatButton(() {
                  Navigator.pop(context);
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Confermation'),
                      content: Text('Are you shoure you want to report'),
                      actions: <Widget>[
                        FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                              print('Cancel');
                            },
                            child: Text('Cancel')),
                        FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                              print('OK');
                            },
                            child: Text('OK')),
                      ],
                    ),
                  );
                }, Icons.add_alert, language['report']),
                buildFlatButton(() {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>LocalData()));
                }, Icons.dashboard, 'Data'),
                buildFlatButton(() {
                  Navigator.pop(context);
                  setState(() {
                    _currentIndex = 0;
                  });
                }, Icons.home, language['home']),
                buildFlatButton(() {
                  Navigator.pop(context);
                  setState(() {
                    _currentIndex = 1;
                  });
                }, Icons.spa, language['selfTesting']),
                buildFlatButton(() {
                  Navigator.pop(context);
                  setState(() {
                    _currentIndex = 2;
                  });
                }, Icons.info, language['updateCovidInfo']),
                buildFlatButton(() {
                  Navigator.pop(context);
                  setState(() {
                    _currentIndex = 3;
                  });
                }, Icons.question_answer, language['frequentlyAskedQuestion']),
                buildFlatButton(() {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Help()));
                }, Icons.help, language['help']),
                buildFlatButton(() {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => About()));
                }, Icons.border_right, language['about']),
                buildFlatButton(() {
                  exit(0);
                }, Icons.cancel, language['exit']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      selectedIconTheme: IconThemeData(size: 30, color: Color(0xff61bdfc)),
      unselectedIconTheme: IconThemeData(size: 20, color: Color(0xff016e97)),
      onTap: (currentIndex) {
        setState(() {
          _currentIndex = currentIndex;
        });
      },
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text(''),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.spa),
          title: Text(''),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info),
          title: Text(''),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.question_answer),
          title: Text(''),
        ),
      ],
    );
  }

  FlatButton buildFlatButton(onPressed, icon, title) {
    return FlatButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              color: Color(0xff5ebbfa),
            ),
            SizedBox(
              width: 20,
            ),
            Text(
              title,
              style: TextStyle(fontSize: 16),
            )
          ],
        ),
      ),
    );
  }

  resumeCallback(void Function() param0) {}
}

import '../model/language.dart';
import 'package:flutter/material.dart';

class Covid19Info extends StatefulWidget {
  final int index;
  Covid19Info({this.index});
  @override
  _Covid19InfoState createState() => _Covid19InfoState();
}

class _Covid19InfoState extends State<Covid19Info> {
  Map language;
  @override
  void initState() {
    language = languageAll[widget.index];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Column(
          children: <Widget>[
            TabBar(
              indicatorSize: TabBarIndicatorSize.label,
              tabs: <Widget>[
                Tab(child: Text(language['global'])),
                Tab(child: Text(language['local']))
              ],
            ),
            Expanded(
                child: TabBarView(
              children: <Widget>[
                Center(child: Text(language['global'])),
                Center(child: Text(language['local']))
              ],
            ))
          ],
        ),
      ),
    );
  }
}

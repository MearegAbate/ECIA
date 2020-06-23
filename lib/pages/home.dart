import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          padding: EdgeInsets.zero,
          // scrollDirection: Axis.horizontal,
          children: <Widget>[
            buildContainer('assets/img/help.jpg'),
            buildContainer('assets/img/tip.jpg'),
            buildContainer('assets/img/tip0.jpg'),
          ],
        ),
      ),
    );
  }

  Container buildContainer(img) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Image.asset(img));
  }
}

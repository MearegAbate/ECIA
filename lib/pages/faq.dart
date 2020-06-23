import '../model/language.dart';
import 'package:flutter/material.dart';

class FAQ extends StatefulWidget {
  final int index;
  FAQ({this.index});
  @override
  _FAQState createState() => _FAQState();
}

class _FAQState extends State<FAQ> {
  Map language;
  @override
  void initState() {
    language = languageAll[widget.index];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(language['faq'])),
    );
  }
}

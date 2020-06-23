import '../model/language.dart';
import 'package:flutter/material.dart';

class SelfTesting extends StatefulWidget {
  final int index;
  SelfTesting({this.index});
  @override
  _SelfTestingState createState() => _SelfTestingState();
}

class _SelfTestingState extends State<SelfTesting> {
  Map language;
  List group = [2, 2, 2, 2, 2, 2, 2];
  @override
  void initState() {
    language = languageAll[widget.index];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  language['covid19Test'],
                  style: TextStyle(fontSize: 35),
                ),
              ),
              buildContainer(language['name']),
              buildContainer(language['phoneNumber']),
              buildContainer(language['address']),
              buildContainerRadio(language['doYouHaveHighFever'], 0),
              buildContainerRadio(language['doYouHaveDryCough'], 1),
              buildContainerRadio(language['didBreathingProblemHappened'], 2),
              buildContainerRadio(language['didYouGetTired'], 3),
              buildContainerRadio(language['doYouHaveStomachake'], 4),
              buildContainerRadio(language['doYouHaveTravelHistory'], 5),
              buildContainerRadio(language['doYouHaveContactWithUnhelthy'], 6),
              Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.all(8.0),
                child: FlatButton(
                  onPressed: () {},
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.green[500],
                        borderRadius: BorderRadius.circular(30)),
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      language['submit'],
                      style: TextStyle(
                          color: Colors.white, fontSize: 20, letterSpacing: 1),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Container buildContainerRadio(question, value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            question,
            style: TextStyle(fontSize: 20),
          ),
          Column(
            children: [0, 1]
                .map((e) => Row(
                      children: <Widget>[
                        Radio(
                          value: e,
                          groupValue: group[value],
                          onChanged: (v) {
                            setState(() {
                              group[value] = v;
                            });
                          },
                        ),
                        Text(
                          e == 0 ? language['yes'] : language['no'],
                          style: TextStyle(fontSize: 18),
                        )
                      ],
                    ))
                .toList(),
          ),
          Divider()
        ],
      ),
    );
  }

  Container buildContainer(title) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: 20),
          ),
          TextFormField(
            decoration: InputDecoration(hintText: language['yourAnswer']),
          ),
        ],
      ),
    );
  }
}

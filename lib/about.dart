import 'package:flutter/material.dart';
import 'package:covidfen/advices.dart';
import 'package:covidfen/models/about.dart';

class AboutPage extends StatelessWidget {
  final About about = About.defaultAbout;

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];

    children.add(SectionCardWidget(
      title: 'About Me',
      description: about.title,
    ));

    about.copyrights.forEach((element) {
      children.add(SectionCardWidget(
        title: element.title,
        description: element.license,
      ));
    });

    return Center(
        child: Container(
            constraints: BoxConstraints(maxWidth: 768),
            child: ListView(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                children: children)));
  }
}

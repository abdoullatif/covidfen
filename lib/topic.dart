import 'package:flutter/material.dart';
import 'package:covidfen/advices.dart';
import 'package:covidfen/models/who_topic.dart';

class TopicDetailWidget extends StatelessWidget {
  final WHOTopic topic;

  TopicDetailWidget({required this.topic});

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];

    topic.questions!.forEach((element) {
      children.add(SectionCardWidget(
        title: element!.title,
        description: element.subtitle,
      ));
    });

    return Scaffold(
        appBar: AppBar(
          title: Text(topic.title),
        ),
        body: Center(
            child: Container(
                constraints: BoxConstraints(maxWidth: 768),
                child: ListView(
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    children: children))));
  }
}

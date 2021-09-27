import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:covidfen/models/who_advice.dart';
import 'package:covidfen/models/who_topic.dart';
import 'package:covidfen/topic.dart';

class AdvicesPage extends StatefulWidget {
  AdvicesPage({Key? key}) : super(key: key);

  @override
  _AdvicesPage createState() => _AdvicesPage();
}

class _AdvicesPage extends State<AdvicesPage> {
  late Future<WHOAdvice> _adviceFuture;

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  _fetchData() {
    _adviceFuture = _loadJSONFile();
  }

  Future<WHOAdvice> _loadJSONFile() async {
    final jsonString = await DefaultAssetBundle.of(context)
        .loadString("Assets/who_corona_advice.json");
    final json = await jsonDecode(jsonString);
    final advices = WHOAdvice.fromJson(json);
    return advices;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _adviceFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 16, bottom: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.error != null) {
          return const Center(
            child: Text('An error has occured'),
          );
        } else {
          final WHOAdvice advice = snapshot.data as WHOAdvice;
          var children = <Widget>[];

          advice.topics!.forEach((element) {
            children.add(TopicCardWidget(
              topic: element!,
            ));
          });

          children.add(SectionCardWidget(
            title: advice.title,
            description: advice.subtitle,
          ));

          advice.basics!.forEach((element) {
            children.add(SectionCardWidget(
              title: element!.title,
              description: element.subtitle,
            ));
          });

          return Center(
              child: Container(
                  constraints: const BoxConstraints(maxWidth: 768),
                  child: ListView(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      children: children)));
        }
      },
    );
  }
}

class TopicCardWidget extends StatelessWidget {
  final WHOTopic topic;

  const TopicCardWidget({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Card(
            child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TopicDetailWidget(
                        topic: topic,
                      )),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                trailing: Icon(Icons.arrow_forward),
                title: Text(topic.title),
              ),
            ],
          ),
        )));
  }
}

class SectionCardWidget extends StatelessWidget {
  final String title;
  final String description;

  SectionCardWidget({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 16),
        child: Card(
            child: Padding(
          padding: EdgeInsets.only(top: 16, bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(title),
                subtitle: Padding(
                    padding: EdgeInsets.only(top: 8), child: Text(description)),
              ),
            ],
          ),
        )));
  }
}

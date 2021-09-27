import 'package:flutter/material.dart';
import 'package:covidfen/about.dart';
import 'package:covidfen/advices.dart';
import 'package:covidfen/google_map_base.dart';
import 'package:covidfen/stats.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CovidFèn',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('CovidFèn'),
            bottom: const TabBar(
              tabs: <Widget>[
                Tab(
                  text: "Statistiques",
                ),
                Tab(
                  text: "Carte",
                ),
                Tab(
                  text: "Conseils",
                ),
                Tab(
                  text: "A propos",
                ),
              ],
            ),
          ),
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              const StatsPage(),
              BaseGoogleMap().getWidget(),
              AdvicesPage(),
              AboutPage()
            ],
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

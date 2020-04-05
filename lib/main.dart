import 'package:coronaModel/model/model.dart';
import 'package:coronaModel/model/parameters.dart';
import 'package:coronaModel/screens/progress.dart';
import 'package:coronaModel/screens/results.dart';
import 'package:coronaModel/screens/settings.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

enum _SimulationState { settings, calculating, result }

class _HomePageState extends State<HomePage> {
  _SimulationState simulationState = _SimulationState.settings;
  Model result;
  double progress = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Covid-19 Model'),
        ),
        body: buildScreen());
  }

  Widget buildScreen() {
    switch (simulationState) {
      case _SimulationState.settings:
        return SettingsScreen(startSimulation);
      case _SimulationState.calculating:
        return ProgressScreen(progress);
      case _SimulationState.result:
        return ResultsScreen(result);
    }
    throw Error();
  }

  Future<void> startSimulation(SimulationParameters params, Set<Modifier> modifiers) async {
    setState(() {
      simulationState = _SimulationState.calculating;
    });
    final model = Model(params, modifiers);
    for (int i = 0; i < params.length; i++) {
      await model.step();
      setState(() {
        progress = i / params.length;
      });
    }
    setState(() {
      result = model;
      simulationState = _SimulationState.result;
    });
  }
}

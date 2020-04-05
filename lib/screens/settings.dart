import 'package:coronaModel/model/model.dart';
import 'package:coronaModel/model/modifiers/close_schools.dart';
import 'package:coronaModel/model/modifiers/digital_contact_tracing.dart';
import 'package:coronaModel/model/modifiers/stay_home_if_sick.dart';
import 'package:coronaModel/model/parameters.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  final void Function(SimulationParameters params, Set<Modifier> modifiers) onClickedStartSimulation;
  SettingsScreen(this.onClickedStartSimulation);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SimulationParameters params = SimulationParameters();

  final Set<Modifier> availableModifiers = {StayHomeIfSick(), DigitalContactTracing(), CloseSchools()};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        buildHelp(),
        buildMainSettings(),
        ...buildModifiers(),
        buildStartButton(),
      ],
    );
  }

  buildStartButton() {
    return RaisedButton(
      child: Text('Start simulation'),
      onPressed: () => widget.onClickedStartSimulation(params, availableModifiers.where((m) => m.isEnabled).toSet()),
    );
  }

  buildMainSettings() {
    return Card(
      margin: EdgeInsets.all(30),
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Text('Simulation settings'),
            TextFormField(
              decoration: InputDecoration(labelText: 'Population size'),
              initialValue: params.persons.toString(),
              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
              onChanged: (String newValue) {
                setState(() {
                  params.persons = int.parse(newValue);
                });
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'How many days should we simulate?'),
              initialValue: params.length.toString(),
              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
              onChanged: (String newValue) {
                setState(() {
                  params.length = int.parse(newValue);
                });
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'How many colleagues has a worker?'),
              initialValue: params.numberOfColleagues.toString(),
              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
              onChanged: (String newValue) {
                setState(() {
                  params.numberOfColleagues = int.parse(newValue);
                });
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'How many classmates has a school child?'),
              initialValue: params.numberOfClassmates.toString(),
              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
              onChanged: (String newValue) {
                setState(() {
                  params.numberOfClassmates = int.parse(newValue);
                });
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Hospital beds (per 100.000)'),
              initialValue: params.hospitalBedsPer100000.toString(),
              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
              onChanged: (String newValue) {
                setState(() {
                  params.hospitalBedsPer100000 = int.parse(newValue);
                });
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Latency period'),
              initialValue: params.latencyPeriod.toString(),
              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
              onChanged: (String newValue) {
                setState(() {
                  params.latencyPeriod = int.parse(newValue);
                });
              },
            ),
            TextFormField(
              decoration:
                  InputDecoration(labelText: 'Probability of infection when meeting someone who is infectious (%)'),
              initialValue: params.probabilityOfInfectionWhenMeeting.toString(),
              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
              onChanged: (String newValue) {
                setState(() {
                  params.probabilityOfInfectionWhenMeeting = int.parse(newValue);
                });
              },
            ),
            TextFormField(
              decoration:
                  InputDecoration(labelText: 'How much does the disease affect the health? (per day after infection)'),
              initialValue: params.diseaseDeltaNegativeHealth.join(',').toString(),
              onChanged: (String newValue) {
                setState(() {
                  params.diseaseDeltaNegativeHealth = newValue.split(',').map((s) => int.parse(s)).toList();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildModifiers() {
    return availableModifiers.map((m) => m.getSettingsCard()).toList();
  }

  Widget buildHelp() {
    return Card(
        margin: EdgeInsets.all(30),
        elevation: 5,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text('Introduction', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('This is a model that can be used to simulate the spread of Covid-19 in a population.'),
            Text(
                'The main purpose of this model is to evaluate how well a digital contact tracing tool would work. For more details on digital contact tracing, check these links:'),
            GestureDetector(
              child: Text('https://medium.com/@linus_26223/how-we-can-prevent-the-next-pandemic-4afa7e03ecab'),
              onTap: () async =>
                  await launch('https://medium.com/@linus_26223/how-we-can-prevent-the-next-pandemic-4afa7e03ecab'),
            ),
            GestureDetector(
              child: Text('https://arstechnica.com/science/2020/04/pandemics-do-we-need-an-app-for-that/'),
              onTap: () async =>
                  await launch('https://arstechnica.com/science/2020/04/pandemics-do-we-need-an-app-for-that/'),
            ),
            Container(height: 20),
            Text('The model', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(
                'The population has this structure: people over 30 years live with a spouse and they have two children.'),
            Text(
                'These things happen every day: Kids go to school (unless they feel sick enough) where they meet their classmates. People of age 18-65 go to work (unless they feel sick enough) where they meet their colleagues. People over 30 will meet their spouse.'),
            Text(
                'Every time two people meet and one of them is infectious, there is a certain probability that the disease transmits.'),
            Text(
                "Old people has poorer health than younger people. When a person's health detoriates, he/she will go to the hospital and, if there are enough beds, receive a health bonus."),
          ]),
        ));
  }
}

class ModifierCard extends StatefulWidget {
  final Widget child;
  final Modifier modifier;

  ModifierCard(this.modifier, {this.child});

  @override
  _ModifierCardState createState() => _ModifierCardState();
}

class _ModifierCardState extends State<ModifierCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(30),
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Checkbox(
                  value: widget.modifier.isEnabled,
                  onChanged: (bool newValue) {
                    setState(() {
                      widget.modifier.isEnabled = newValue;
                    });
                  },
                ),
                Text(widget.modifier.getTitle()),
              ],
            ),
            if (widget.modifier.isEnabled) ...[
              Text(widget.modifier.getDescription()),
              TextFormField(
                decoration: InputDecoration(labelText: 'Starting on day'),
                initialValue: widget.modifier.startingAtDay.toString(),
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                onChanged: (String newValue) {
                  setState(() {
                    widget.modifier.startingAtDay = int.parse(newValue);
                  });
                },
              ),
              if (widget.child != null) widget.child,
            ],
          ],
        ),
      ),
    );
  }
}
/*
TODO:
test-kurva, vilka ska testas, testkapacitet
besöksförbud på ålderdomshem
uppmaning att inte besöka äldre

 */

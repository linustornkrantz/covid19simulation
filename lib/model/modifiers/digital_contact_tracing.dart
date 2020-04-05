import 'package:coronaModel/model/model.dart';
import 'package:coronaModel/model/person.dart';
import 'package:coronaModel/screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DigitalContactTracing implements Modifier {
  bool isEnabled = false;
  int startingAtDay = 35;
  int daysBack = 14;
  int daysInQuarantine = 14;
  int probabilityThatDeviceWillDetectMeeting = 90;
  int percentOfPopulationThatHasTheDevice = 80;

  Map<Person, Map<int, List<Person>>> bracelets = {};

  @override
  String getTitle() {
    return 'Digital contact tracing';
  }

  @override
  String getDescription() {
    return 'Distribute a smartphone app or a bracelet that will register persons that comes within short distance. Whenever anyone is confirmed to have been infected, the data can be used to find people at risk, and those will be quarantined.';
  }

  @override
  ModifierCard getSettingsCard() {
    return ModifierCard(
      this,
      child: Column(
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(labelText: 'After how many days should we forget the contact?'),
            initialValue: daysBack.toString(),
            inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
            onChanged: (String newValue) {
              daysBack = int.parse(newValue);
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'How long should contacts be quarantined?'),
            initialValue: daysInQuarantine.toString(),
            inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
            onChanged: (String newValue) {
              daysInQuarantine = int.parse(newValue);
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Probability that device will detect meeting (%)'),
            initialValue: probabilityThatDeviceWillDetectMeeting.toString(),
            inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
            onChanged: (String newValue) {
              probabilityThatDeviceWillDetectMeeting = int.parse(newValue);
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Share of the population that uses the device (%)'),
            initialValue: percentOfPopulationThatHasTheDevice.toString(),
            inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
            onChanged: (String newValue) {
              percentOfPopulationThatHasTheDevice = int.parse(newValue);
            },
          ),
        ],
      ),
    );
  }

  @override
  onDay(int day) {}

  @override
  onPersonWasTested(Person person, DiseaseCategory category) {
    if (day < startingAtDay) {
      return;
    }
    switch (category) {
      case DiseaseCategory.immune:
        return;
      case DiseaseCategory.notInfected:
        return;
      default:
        final _meetings = bracelets[person];
        if (_meetings == null) {
          return;
        }
        _meetings.forEach((key, persons) {
          if (key > day - daysBack) {
            persons.forEach((p) {
              p.informYouShouldQuarantineDays(daysInQuarantine);
            });
          }
        });
    }
  }

  @override
  onMeeting(Person a, Person b) {
    if (day + daysBack < startingAtDay) {
      return;
    }
    if (random.nextInt(100) > probabilityThatDeviceWillDetectMeeting) {
      return;
    }
    if (bracelets[a] == null || bracelets[b] == null) {
      // both persons must have the device
      return;
    }
    _registerMeeting(a, b);
    _registerMeeting(b, a);
  }

  void _registerMeeting(Person a, Person b) {
    final meetings = bracelets[a];
    if (meetings[day] == null) {
      meetings[day] = [];
    }
    meetings[day].add(b);
  }

  @override
  onInit(Model model) {
    if (probabilityThatDeviceWillDetectMeeting < 0 || probabilityThatDeviceWillDetectMeeting > 100) {
      throw Error();
    }
    if (percentOfPopulationThatHasTheDevice < 0 || percentOfPopulationThatHasTheDevice > 100) {
      throw Error();
    }
    model.persons.forEach((p) {
      bracelets[p] = random.nextInt(100) < percentOfPopulationThatHasTheDevice ? Map<int, List<Person>>() : null;
    });
  }

  @override
  bool preventGoToSchool() {
    return false;
  }
}

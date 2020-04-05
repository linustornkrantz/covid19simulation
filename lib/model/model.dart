import 'dart:math';

import 'package:coronaModel/model/hospital.dart';
import 'package:coronaModel/model/parameters.dart';
import 'package:coronaModel/model/person.dart';
import 'package:coronaModel/screens/settings.dart';

Random random = Random(4);

Hospital hospital;
int symptomThresholdForSkipWorkModifier = 0;
int day = 0;
int peopleQuarantined = 0;
int sumQuarantineDays = 0;
int sumSickDays = 0;
Set<Modifier> modifiers;

class Model {
  final persons = List<Person>();
  final historySick = List<int>();
  final historyDeath = List<int>();

  List<Person> alivePersons;

  final SimulationParameters params;

  Model(this.params, Set<Modifier> m) {
    modifiers = m;
    hospital = Hospital((params.hospitalBedsPer100000 * (params.persons / 100000)).round());
    createPopulation();
    getRandom(persons, 3).forEach((p) => p.expose());
    modifiers.forEach((m) => m.onInit(this));
  }

  Future<void> step() async {
    return Future(() {
      day++;
      modifiers.forEach((m) => m.onDay(day));

      alivePersons = persons.where((p) => p.isAlive).toList();
      alivePersons.forEach((p) {
        p.act();
        p.endOfTurn();
      });
      hospital.takeCareOfPatients();
      historySick.add(persons.where((p) => p.isSick).length);
      historyDeath.add(persons.where((p) => !p.isAlive).length);
    });
  }

  double calculateR0AtDay(int day, {bool debug = false}) {
    final infected = persons.where((p) => p.hasBeenInfected && p.wasInfectedAtDay <= day).toList();
    if (infected.length == 0) {
      return 0;
    }
    final sumSpreadTo = infected.map((p) => p.didSpreadTo.length).reduce((a, b) => a + b);
    if (debug) {
      print('R0 calculation sumSpreadTo: $sumSpreadTo, infected: ${infected.length}');
    }
    return sumSpreadTo / infected.length;
  }

  void createPopulation() {
    if (persons.length % 2 != 0) {
      persons.removeLast();
    }

    List<Person> middleAged = [];
    // Add two old people, give them two middle aged children
    for (int i = 0; i < params.persons / 3 / 2; i++) {
      final old1 = Person(i, params, age: 60 + random.nextInt(30));
      final old2 = Person(i, params, age: 60 + random.nextInt(30));
      old1.spouse = old2;
      old2.spouse = old1;
      final middleAge1 = Person(i, params, age: 30 + random.nextInt(30));
      final middleAge2 = Person(i, params, age: 30 + random.nextInt(30));
      old1.children = {middleAge1, middleAge2};
      old2.children = {middleAge1, middleAge2};
      persons.addAll({old1, old2, middleAge1, middleAge2});
      middleAged.addAll([middleAge1, middleAge2]);
    }

    // Pair the middle aged and give them two children
    for (int i = 0; i < middleAged.length / 2; i++) {
      final parent1 = middleAged[i];
      final parent2 = middleAged[middleAged.length - 1];
      parent1.spouse = parent2;
      parent2.spouse = parent1;
      final child1 = Person(i, params, age: random.nextInt(30));
      final child2 = Person(i, params, age: random.nextInt(30));
      parent1.children = {child1, child2};
      parent2.children = {child1, child2};
      persons.addAll({child1, child2});
    }

    final workingPersons = persons.where((p) => p.age > 18 && p.age <= 65).toList();
    workingPersons.forEach((p) {
      p.colleagues = getRandom(workingPersons, params.numberOfColleagues);
    });

    final schoolChildren = persons.where((p) => p.age <= 18).toList();
    schoolChildren.forEach((sc) {
      sc.colleagues = getRandom(schoolChildren, params.numberOfClassmates);
    });
  }
}

Set<Person> getRandom(List<Person> persons, int amount) {
  final Set<Person> selected = {};
  for (int i = 0; i < amount; i++) {
    selected.add(persons[random.nextInt(persons.length)]);
  }
  return selected;
}

abstract class Modifier {
  bool isEnabled;

  int startingAtDay;
  ModifierCard getSettingsCard();
  String getTitle();
  String getDescription();

  onInit(Model model);
  onDay(int day);
  onMeeting(Person a, Person b);
  onPersonWasTested(Person person, DiseaseCategory category);

  bool preventGoToSchool();
}

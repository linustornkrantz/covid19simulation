import 'package:coronaModel/model/model.dart';
import 'package:coronaModel/model/parameters.dart';
import 'package:flutter/cupertino.dart';

enum DiseaseCategory { notInfected, mildDisease, mediumDisease, severeDisease, immune }

class Person {
  final int id;
  final int age;
  final SimulationParameters params;
  DiseaseCategory diseaseCategory = DiseaseCategory.notInfected;
  int health;
  int originalHealth;

  bool isAlive = true;

  Set<Person> colleagues;
  Set<Person> children;

  int symptomThresholdForSkipWork;

  bool knowIHadCovid = false;

  Set<Person> didSpreadTo = {};

  int daysToQuarantine = 0;

  Person spouse;
  bool get hasBeenInfected => diseaseCategory != DiseaseCategory.notInfected;
  int wasInfectedAtDay;

  bool get isImmune => diseaseCategory == DiseaseCategory.immune;
  bool get isSick =>
      isAlive && (diseaseCategory != DiseaseCategory.notInfected && diseaseCategory != DiseaseCategory.immune);

  bool get hasSymptoms => health < originalHealth;
  bool get hasJob => age > 18 && age < 66;

  int _daysSinceInfection = 0;
  Person(this.id, this.params, {@required this.age}) {
    originalHealth = 100 - age;
    health = originalHealth;
    symptomThresholdForSkipWork = 1 + random.nextInt(4);
  }

  /// returns true if did get infected
  bool expose() {
    if (isSick) {
      return false;
    }
    if (random.nextInt(100) < params.probabilityOfInfectionWhenMeeting) diseaseCategory = DiseaseCategory.mildDisease;
    wasInfectedAtDay = day;
    return true;
  }

  void meetWith(Person otherPerson) {
    if (canTransmit() && otherPerson.expose()) {
      didSpreadTo.add(otherPerson);
    }
    if (otherPerson.canTransmit() && expose()) {
      otherPerson.didSpreadTo.add(this);
    }
    modifiers.forEach((m) => m.onMeeting(this, otherPerson));
  }

  bool canTransmit() {
    if (diseaseCategory == DiseaseCategory.notInfected) {
      return false;
    }
    if (diseaseCategory == DiseaseCategory.immune) {
      return false;
    }
    if (_daysSinceInfection < params.latencyPeriod) {
      return false;
    }
    return true;
  }

  void _diseaseDevelops() {
    if (!isSick) {
      return;
    }
    _daysSinceInfection++;
    if (_daysSinceInfection < params.diseaseDeltaNegativeHealth.length) {
      health = health - params.diseaseDeltaNegativeHealth[_daysSinceInfection];
    } else {
      health = health + 2;
    }
  }

  void act() {
    if (hasJob) {
      _work();
    }
    if (age <= 18) {
      _goToSchool();
    }
    _meetChildren();
    _meetSpouse();
    _considerHospital();
  }

  void endOfTurn() {
    _diseaseDevelops();
    if (health < 0) {
      isAlive = false;
    }
    if (health > originalHealth) {
      diseaseCategory = DiseaseCategory.immune;
    }
    if (originalHealth - health > 15) {
      knowIHadCovid = true;
    }
    if (daysToQuarantine > 0) {
      sumQuarantineDays++;
      daysToQuarantine--;
    }
  }

  void _work() {
    if (!hasJob) {
      return;
    }
    if (decidesToStayHomeDueToSickness()) {
      sumSickDays++;
      return;
    }
    colleagues.forEach((c) {
      if (!c.decidesToStayHomeDueToSickness()) {
        meetWith(c);
      }
    });
  }

  bool decidesToStayHomeDueToSickness() {
    if (knowIHadCovid && isSick) {
      return true;
    }
    if (daysToQuarantine > 0) {
      return true;
    }
    return originalHealth - health > symptomThresholdForSkipWork - symptomThresholdForSkipWorkModifier;
  }

  void _meetChildren() {
    if (daysToQuarantine > 0) {
      return;
    }
    if (children != null) {
      children.forEach((child) {
        meetWith(child);
      });
    }
  }

  void _considerHospital() {
    if (originalHealth - health > 10) {
      //print('to hospital after $_daysSinceInfection');
      hospital.seekCare(this);
    }
  }

  void informYouShouldQuarantineDays(int days) {
    if (daysToQuarantine == 0) {
      peopleQuarantined++;
    }
    daysToQuarantine = days;
  }

  void _goToSchool() {
    if (modifiers.any((m) => m.preventGoToSchool())) {
      return;
    }
    if (decidesToStayHomeDueToSickness()) {
      sumSickDays++;
      return;
    }
    colleagues.forEach((c) {
      if (!c.decidesToStayHomeDueToSickness()) {
        meetWith(c);
      }
    });
  }

  void _meetSpouse() {
    if (spouse == null) {
      return;
    }
    meetWith(spouse);
  }
}

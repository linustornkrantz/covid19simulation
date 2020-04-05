import 'package:coronaModel/model/model.dart';
import 'package:coronaModel/model/person.dart';

class Hospital {
  final int beds;
  Hospital(this.beds);

  final Set<Person> patients = {};

  void seekCare(Person person) {
    testForInfection(person);

    if (patients.length < beds) {
      patients.add(person);
    }
  }

  void takeCareOfPatients() {
    patients.removeWhere((p) => p.isImmune || !p.isAlive);
    patients.forEach((p) {
      p.health = p.health + 4;
    });
  }

  void testForInfection(Person person) {
    modifiers.forEach((m) => m.onPersonWasTested(person, person.diseaseCategory));
  }
}

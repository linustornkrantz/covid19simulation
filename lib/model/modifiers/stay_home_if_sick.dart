import 'package:coronaModel/model/model.dart';
import 'package:coronaModel/model/person.dart';
import 'package:coronaModel/screens/settings.dart';

class StayHomeIfSick implements Modifier {
  bool isEnabled = false;
  int startingAtDay = 35;

  @override
  String getTitle() {
    return 'Tell working people to stay home if they are sick';
  }

  @override
  String getDescription() {
    return 'Some persons with mild symptoms will normally go to work. If this is enabled, is is more likely that they will stay at home.';
  }

  @override
  ModifierCard getSettingsCard() {
    return ModifierCard(this);
  }

  @override
  onDay(int day) {
    if (day == startingAtDay) {
      symptomThresholdForSkipWorkModifier = 1;
    }
  }

  @override
  onMeeting(Person a, Person b) {}

  @override
  onPersonWasTested(Person person, DiseaseCategory category) {}

  @override
  onInit(Model model) {}

  @override
  bool preventGoToSchool() {
    return false;
  }
}

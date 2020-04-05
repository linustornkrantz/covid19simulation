import 'package:coronaModel/model/model.dart';
import 'package:coronaModel/model/person.dart';
import 'package:coronaModel/screens/settings.dart';

class CloseSchools implements Modifier {
  bool isEnabled = false;
  int startingAtDay = 35;

  @override
  String getTitle() {
    return 'Close schools';
  }

  @override
  String getDescription() {
    return 'People under 18 will no longer meet their classmates.';
  }

  @override
  ModifierCard getSettingsCard() {
    return ModifierCard(this);
  }

  @override
  onDay(int day) {}

  @override
  onMeeting(Person a, Person b) {}

  @override
  onPersonWasTested(Person person, DiseaseCategory category) {}

  @override
  onInit(Model model) {}

  @override
  bool preventGoToSchool() {
    return day >= startingAtDay;
  }
}

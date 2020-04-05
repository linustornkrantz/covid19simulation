class SimulationParameters {
  int length = 150;
  int persons = 10000;
  int numberOfColleagues = 4;
  int numberOfClassmates = 20;
  List<int> diseaseDeltaNegativeHealth = [0, 0, 0, 0, 1, 2, 3, 4, 5, 4, 3, 2, 1, 0];
  int hospitalBedsPer100000 = 500; // there were about 5 intensive care beds per 100000 in Sweden 2017
  int probabilityOfInfectionWhenMeeting = 20;
  int latencyPeriod = 5;
}

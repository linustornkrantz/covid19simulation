import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/flutter.dart';
import 'package:coronaModel/model/model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const double _chartHeight = 400;

class ResultsScreen extends StatefulWidget {
  final Model model;
  ResultsScreen(this.model);

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  @override
  void initState() {
    super.initState();
    print('Deaths: ${widget.model.historyDeath.last.toString()}');
    print('Total infected: ${widget.model.persons.where((p) => p.hasBeenInfected).length.toString()}');
    print('People quarantined: $peopleQuarantined, sum days:$sumQuarantineDays');
    print('Sick days: $sumSickDays');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      Container(child: InfectedChart(widget.model), height: _chartHeight),
      // Container(child: R0Chart(widget.model), height: _chartHeight), TODO: Not sure the calculation is correct
      Card(
        margin: EdgeInsets.all(30),
        elevation: 5,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Text('Total infected: ${widget.model.persons.where((p) => p.hasBeenInfected).length.toString()}'),
              Text('Deaths: ${widget.model.historyDeath.last.toString()}'),
            ],
          ),
        ),
      ),
    ]);
  }
}

class InfectedChart extends StatelessWidget {
  final List<charts.Series> seriesList1;
  final bool animate = false;

  InfectedChart(Model model) : seriesList1 = createSeriesList1(model);

  @override
  Widget build(BuildContext context) {
    return charts.LineChart(
      seriesList1,
      animate: animate,
      behaviors: [charts.SeriesLegend()],
      primaryMeasureAxis: new charts.NumericAxisSpec(
        tickProviderSpec: charts.StaticNumericTickProviderSpec(
          <charts.TickSpec<num>>[
            charts.TickSpec<num>(20),
            charts.TickSpec<num>(40),
            charts.TickSpec<num>(60),
            charts.TickSpec<num>(80),
            charts.TickSpec<num>(100),
          ],
        ),
      ),
    );
  }

  static List<charts.Series<TimeSeriesAmount, int>> createSeriesList1(Model model) {
    final population = model.persons.length;
    final sick = List<TimeSeriesAmount>();
    final deaths = List<TimeSeriesAmount>();
    model.historySick.asMap().forEach((step, amount) => sick.add(TimeSeriesAmount(step, (amount * 100 / population))));
    model.historyDeath
        .asMap()
        .forEach((step, amount) => deaths.add(TimeSeriesAmount(step, (amount * 100 / population))));
    return [
      new charts.Series<TimeSeriesAmount, int>(
        id: 'Total infected',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesAmount infected, _) => infected.step,
        measureFn: (TimeSeriesAmount infected, _) => infected.amount,
        data: sick,
      ),
      new charts.Series<TimeSeriesAmount, int>(
        id: 'Total deaths',
        colorFn: (_, __) => charts.MaterialPalette.black,
        domainFn: (TimeSeriesAmount infected, _) => infected.step,
        measureFn: (TimeSeriesAmount infected, _) => infected.amount,
        data: deaths,
      )
    ];
  }
}

class R0Chart extends StatelessWidget {
  final List<charts.Series> seriesList2;
  final Model model;
  final bool animate = false;

  R0Chart(this.model) : seriesList2 = createSeriesList2(model);

  @override
  Widget build(BuildContext context) {
    return charts.LineChart(
      seriesList2,
      animate: animate,
      behaviors: [charts.SeriesLegend()],
      selectionModels: [
        new charts.SelectionModelConfig(
          type: charts.SelectionModelType.info,
          changedListener: _onSelectionChanged,
        )
      ],
    );
  }

  static List<charts.Series<TimeSeriesAmount, int>> createSeriesList2(Model model) {
    final r0 = List<TimeSeriesAmount>();
    for (int d = 0; d < model.params.length; d++) {
      r0.add(TimeSeriesAmount(d, model.calculateR0AtDay(d)));
    }

    return [
      new charts.Series<TimeSeriesAmount, int>(
        id: 'R0',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesAmount infected, _) => infected.step,
        measureFn: (TimeSeriesAmount infected, _) => infected.amount,
        data: r0,
      ),
    ];
  }

  void _onSelectionChanged(SelectionModel<num> selectionModel) {
    final step = (selectionModel.selectedDatum.first.datum as TimeSeriesAmount).step;
    print('R0 until day $step: ${model.calculateR0AtDay(step, debug: true)}');
  }
}

class TimeSeriesAmount {
  final int step;
  final double amount;
  TimeSeriesAmount(this.step, this.amount);
}

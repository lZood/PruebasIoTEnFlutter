import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Random random = Random();
  List<double> barData = List.generate(5, (index) => Random().nextDouble() * 100);
  double gaugeValue = 50.0;
  double progressValue = 0.7;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    // Actualiza los datos cada 5 segundos
    timer = Timer.periodic(const Duration(seconds: 5), (_) => _generateRandomData());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  // Genera datos aleatorios
  void _generateRandomData() {
    setState(() {
      barData = List.generate(5, (index) => random.nextDouble() * 100);
      gaugeValue = random.nextDouble() * 100;
      progressValue = random.nextDouble();
    });
  }

  // Prueba de rendimiento: Actualización en tiempo real
  void testRealTimeUpdates() {
    final stopwatch = Stopwatch()..start();

    setState(() {
      barData = List.generate(5, (index) => random.nextDouble() * 100);
      gaugeValue = random.nextDouble() * 100;
      progressValue = random.nextDouble();
    });

    stopwatch.stop();
    print('Tiempo de actualización de gráficos: ${stopwatch.elapsedMilliseconds} ms');
  }

  // Prueba de rendimiento: Renderizar grandes volúmenes de datos
  void testLargeDataSets() {
    final stopwatch = Stopwatch()..start();

    setState(() {
      barData = List.generate(1000, (index) => random.nextDouble() * 100);
    });

    stopwatch.stop();
    print('Tiempo para renderizar 1000 datos: ${stopwatch.elapsedMilliseconds} ms');
  }

  @override
  Widget build(BuildContext context) {
    final stopwatch = Stopwatch()..start();

    final widgetTree = Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildBarChart(),
              const SizedBox(height: 20),
              _buildGauge(),
              const SizedBox(height: 20),
              _buildProgressIndicator(),
              const SizedBox(height: 20),
              _buildDataTable(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: testRealTimeUpdates,
                child: const Text('Prueba de Actualización en Tiempo Real'),
              ),
              ElevatedButton(
                onPressed: testLargeDataSets,
                child: const Text('Prueba con 1000 Datos Aleatorios'),
              ),
            ],
          ),
        ),
      ),
    );

    stopwatch.stop();
    print('Tiempo de renderizado: ${stopwatch.elapsedMilliseconds} ms');

    return widgetTree;
  }

  // Gráfico de barras
  Widget _buildBarChart() {
    return AspectRatio(
      aspectRatio: 2,
      child: BarChart(
        BarChartData(
          barGroups: barData
              .asMap()
              .entries
              .map((entry) => BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: Colors.blue,
                width: 20,
              ),
            ],
          ))
              .toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    'Item ${(value + 1).toInt()}',
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  // Medidor circular
  Widget _buildGauge() {
    return SizedBox(
      height: 200,
      child: SfRadialGauge(
        axes: [
          RadialAxis(
            minimum: 0,
            maximum: 100,
            pointers: [
              NeedlePointer(value: gaugeValue),
            ],
            annotations: [
              GaugeAnnotation(
                widget: Text(
                  '${gaugeValue.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                angle: 90,
                positionFactor: 0.5,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Indicador de progreso
  Widget _buildProgressIndicator() {
    return CircularPercentIndicator(
      radius: 100,
      lineWidth: 10,
      percent: progressValue,
      center: Text('${(progressValue * 100).toStringAsFixed(1)}%'),
      progressColor: Colors.green,
    );
  }

  // Tabla de datos
  Widget _buildDataTable() {
    return DataTable(
      columns: const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Valor')),
      ],
      rows: barData
          .asMap()
          .entries
          .map((entry) => DataRow(cells: [
        DataCell(Text('Item ${entry.key + 1}')),
        DataCell(Text(entry.value.toStringAsFixed(2))),
      ]))
          .toList(),
    );
  }
}

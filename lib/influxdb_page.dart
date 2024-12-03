import 'package:flutter/material.dart';
import 'influxdb_client.dart'; // Importa tu cliente de InfluxDB
import 'constants.dart'; // Importa las constantes necesarias para configurar InfluxDB

class InfluxDBPage extends StatelessWidget {
  InfluxDBPage({Key? key}) : super(key: key);

  // Instancia del cliente de InfluxDB
  final InfluxDBClient influxDBClient = InfluxDBClient(
    url: influxUrl,
    org: org,
    bucket: bucket,
    token: token,
  );

  // Función para escribir datos
  Future<void> writeData() async {
    try {
      await influxDBClient.writeData(
        'temperatura',
        {'value': 23.5}, // Campos (fields)
        {'ubicacion': 'sala'}, // Etiquetas (tags)
      );
      print('Datos almacenados exitosamente');
    } catch (e) {
      print('Error al almacenar datos: $e');
    }
  }

  // Función para recuperar datos
  Future<void> queryData() async {
    const fluxQuery = '''
      from(bucket: "$bucket")
        |> range(start: -1h)
        |> filter(fn: (r) => r["_measurement"] == "temperatura")
    ''';

    try {
      final result = await influxDBClient.queryData(fluxQuery);
      print('Datos recuperados: $result');
    } catch (e) {
      print('Error al recuperar datos: $e');
    }
  }

  // Prueba de rendimiento para escritura
  Future<void> testWritePerformance(int recordCount) async {
    final stopwatch = Stopwatch()..start();
    try {
      for (int i = 0; i < recordCount; i++) {
        await influxDBClient.writeData(
          'temperatura',
          {'value': 20.0 + i}, // Datos variados
          {'ubicacion': 'sala'},
        );
      }
      stopwatch.stop();
      print('Tiempo total para $recordCount registros: ${stopwatch.elapsedMilliseconds} ms');
    } catch (e) {
      print('Error durante la prueba de rendimiento de escritura: $e');
    }
  }

  // Prueba de rendimiento para consulta
  Future<void> testQueryPerformance(String filter) async {
    final stopwatch = Stopwatch()..start();
    try {
      final fluxQuery = '''
        from(bucket: "$bucket")
          |> range(start: -1h)
          $filter
      ''';

      final result = await influxDBClient.queryData(fluxQuery);
      stopwatch.stop();
      print('Tiempo de consulta con filtro "$filter": ${stopwatch.elapsedMilliseconds} ms');
      print('Resultado: $result');
    } catch (e) {
      print('Error durante la prueba de rendimiento de consulta: $e');
    }
  }

  // Simulación de carga elevada
  Future<void> simulateHighLoad(int concurrentRequests) async {
    final stopwatch = Stopwatch()..start();
    final List<Future> tasks = [];

    for (int i = 0; i < concurrentRequests; i++) {
      tasks.add(influxDBClient.writeData(
        'carga',
        {'value': i},
        {'ubicacion': 'prueba'},
      ));
    }

    try {
      await Future.wait(tasks);
      stopwatch.stop();
      print('Tiempo total para $concurrentRequests solicitudes concurrentes: ${stopwatch.elapsedMilliseconds} ms');
    } catch (e) {
      print('Error durante la simulación de carga: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InfluxDB Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: writeData,
              child: const Text('Escribir Datos en InfluxDB'),
            ),
            ElevatedButton(
              onPressed: queryData,
              child: const Text('Consultar Datos de InfluxDB'),
            ),
            ElevatedButton(
              onPressed: () => testWritePerformance(100),
              child: const Text('Prueba de Rendimiento - Escritura'),
            ),
            ElevatedButton(
              onPressed: () => testQueryPerformance(''),
              child: const Text('Prueba de Rendimiento - Consulta sin Filtro'),
            ),
            ElevatedButton(
              onPressed: () => testQueryPerformance(
                '|> filter(fn: (r) => r["ubicacion"] == "sala")',
              ),
              child: const Text('Prueba de Rendimiento - Consulta con Filtro'),
            ),
            ElevatedButton(
              onPressed: () => simulateHighLoad(50),
              child: const Text('Simulación de Carga (50 Solicitudes)'),
            ),
          ],
        ),
      ),
    );
  }
}

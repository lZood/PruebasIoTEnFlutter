import 'dart:convert';
import 'package:http/http.dart' as http;

class InfluxDBClient {
  final String url;
  final String org;
  final String bucket;
  final String token;

  InfluxDBClient({
    required this.url,
    required this.org,
    required this.bucket,
    required this.token,
  });

  Future<void> writeData(
      String measurement, Map<String, dynamic> fields, Map<String, String> tags) async {
    final String data = _prepareLineProtocol(measurement, fields, tags);
    final response = await http.post(
      Uri.parse('$url/api/v2/write?org=$org&bucket=$bucket&precision=s'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'text/plain',
      },
      body: data,
    );

    if (response.statusCode != 204) {
      throw Exception('Error al escribir datos: ${response.body}');
    }
  }

  Future<String> queryData(String fluxQuery) async {
    final response = await http.post(
      Uri.parse('$url/api/v2/query?org=$org'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/vnd.flux',
      },
      body: fluxQuery,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al consultar datos: ${response.body}');
    }
    return response.body;
  }

  // Generador de line protocol
  String _prepareLineProtocol(String measurement, Map<String, dynamic> fields, Map<String, String> tags) {
    final String tagString = tags.entries.map((e) => '${e.key}=${e.value}').join(',');
    final String fieldString = fields.entries.map((e) => '${e.key}=${e.value}').join(',');
    final int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return '$measurement,$tagString $fieldString $timestamp';
  }

  // Prueba de rendimiento para escritura
  Future<void> testWritePerformance(int recordCount) async {
    final stopwatch = Stopwatch()..start();
    try {
      for (int i = 0; i < recordCount; i++) {
        await writeData(
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

      final result = await queryData(fluxQuery);
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
      tasks.add(writeData(
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
}
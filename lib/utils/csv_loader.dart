import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

Future<List<List<String>>> loadQuestions() async {
  final data = await rootBundle.loadString('assets/pytania1z10.csv');
  final List<List<dynamic>> csvTable = const CsvToListConverter().convert(data);
  return csvTable.map((e) => [e[0].toString(), e[1].toString()]).toList();
}

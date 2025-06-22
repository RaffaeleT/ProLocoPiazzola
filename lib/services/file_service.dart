import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import '../model/booth_entry.dart';

class FileService {
  String defaultFileName = "proloco.csv";

  Future<String> getDefaultPath() async {
    final directory = await getDownloadsDirectory();
    return '${directory?.path}/$defaultFileName';
  }

  Future<List<BoothEntry>> loadEntries(String path) async {
    final file = File(path);
    if (!await file.exists()) return [];

    final content = await file.readAsString();
    final rows = const CsvToListConverter().convert(content);
    return rows.map((row) => BoothEntry.fromList(row)).toList();
  }

  Future<void> saveEntries(String path, List<BoothEntry> entries) async {
    final csv = const ListToCsvConverter().convert(
      entries.map((e) => e.toList()).toList(),
    );
    final file = File(path);
    await file.writeAsString(csv);
  }
}

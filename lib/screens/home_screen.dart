import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart'; // Import for HapticFeedback

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<List<dynamic>> _rows = [];

  @override
  void initState() {
    super.initState();
    _loadFileOrPick();
  }

  Future<void> _loadFileOrPick() async {
    final file = await _getInitialFile();
    if (file == null) return;

    final content = await file.readAsString();
    final rows = const CsvToListConverter().convert(content);
    setState(() => _rows = rows);
  }

  Future<File?> _getInitialFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/proloco.csv';
    final file = File(path);

    if (await file.exists()) return file;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }

    return null;
  }

  Future<void> _saveToFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/proloco.csv';
    final csv = const ListToCsvConverter().convert(_rows);
    final file = File(path);
    await file.writeAsString(csv);
  }

  Future<void> _exportToDownloads() async {
    final internalDir = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory('/storage/emulated/0/Download');
    final sourceFile = File('${internalDir.path}/proloco.csv');
    final targetFile = File('${downloadsDir.path}/proloco.csv');

    if (await sourceFile.exists()) {
      await sourceFile.copy(targetFile.path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Esportato in: ${targetFile.path}")),
      );
    }
  }

  Future<void> _saveAndExport() async {
    await _saveToFile();
    await _exportToDownloads();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ProLoco Piazzola')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text("Menu")),
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: const Text("Apri file"),
              onTap: () {
                Navigator.pop(context);
                _loadFileOrPick();
              },
            ),
            ListTile(
              leading: const Icon(Icons.save),
              title: const Text("Salva file"),
              onTap: () {
                Navigator.pop(context);
                _saveAndExport();
              },
            ),
            const Divider(),
            // Add a spacer and the exit option at the bottom
            SizedBox(height: 300), // Adjust height as needed for your layout
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Esci"),
              onTap: () {
                Navigator.pop(context);
                // Exit the app
                Future.delayed(const Duration(milliseconds: 200), () {
                  // Use SystemNavigator.pop() for Android, exit(0) for both platforms
                  // Import 'dart:io' at the top if not already present
                  exit(0);
                });
              },
            ),
          ],
        ),
      ),
      body: _rows.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      showCheckboxColumn: false,
                      // columns: _rows.first
                      //     .map((e) => DataColumn(label: Text(e.toString())))
                      //     .toList(),
                      columns: const [
                        DataColumn(label: Text("Stallo")),
                        DataColumn(label: Text("Espositore 1")),
                        DataColumn(label: Text("Espositore 2")),
                        DataColumn(label: Text("Verificato")),
                      ],
                      rows: _rows.skip(1).map((row) {
                        final index = _rows.indexOf(row);
                        final editableRow = List.from(row);

                        return DataRow(
                          cells: editableRow
                              .map((e) => DataCell(Text(e.toString())))
                              .toList(),
                          onSelectChanged: (_) async {
                            // Vibrate on tap
                            await HapticFeedback.vibrate();

                            final controller = TextEditingController(
                                text: editableRow[2].toString());
                            final focusNode = FocusNode();
                            bool currentChecked = editableRow.length > 3 &&
                                editableRow[3].toString().toLowerCase() ==
                                    'true';

                            showDialog(
                              context: context,
                              builder: (context) => StatefulBuilder(
                                builder: (context, setStateDialog) {
                                  // Request focus after the dialog is built
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    focusNode.requestFocus();
                                  });

                                  return AlertDialog(
                                    title: Text(
                                        "Gestione stallo ${editableRow[0]}"),
                                    content: SizedBox(
                                        width: MediaQuery.of(context)
                                                .size
                                                .width *
                                            0.8, // Set width to 80% of screen width
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8),
                                            Text(
                                                "Espositore 1: ${editableRow[1]}"),
                                            const SizedBox(height: 12),
                                            TextField(
                                              controller: controller,
                                              focusNode:
                                                  focusNode, // Attach the focus node here
                                              decoration: const InputDecoration(
                                                  labelText: "Espositore 2"),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .start, // Align to start (left)
                                              children: [
                                                const Text("Verificato"),
                                                const SizedBox(width: 12),
                                                GestureDetector(
                                                  onTap: () {
                                                    setStateDialog(() {
                                                      currentChecked =
                                                          !currentChecked;
                                                    });
                                                  },
                                                  child: Switch(
                                                    value: currentChecked,
                                                    onChanged: (value) {
                                                      setStateDialog(() {
                                                        currentChecked = value;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Annulla"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            editableRow[2] = controller.text;
                                            if (editableRow.length > 3) {
                                              editableRow[3] = currentChecked;
                                            } else {
                                              editableRow.add(currentChecked);
                                            }
                                            _rows[index] = editableRow;
                                          });
                                          Navigator.pop(context);
                                          _saveAndExport();
                                        },
                                        child: const Text("Salva"),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

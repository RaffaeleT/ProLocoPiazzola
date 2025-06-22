import 'package:flutter/material.dart';
import '../model/booth_entry.dart';
import '../services/file_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FileService fileService = FileService();
  List<BoothEntry> entries = [];
  String search = '';
  String sortBy = 'booth';

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  void _loadFile() async {
    final path = await fileService.getDefaultPath();
    final data = await fileService.loadEntries(path);
    setState(() => entries = data);
  }

  void _saveFile() async {
    final path = await fileService.getDefaultPath();
    await fileService.saveEntries(path, entries);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Salvato")));
  }

  List<BoothEntry> get filtered => entries
      .where((e) => e.booth.contains(search) || e.espositore1.contains(search) || e.espositore2.contains(search))
      .toList()
    ..sort((a, b) => a.booth.compareTo(b.booth));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ProLoco Piazzola')),
      body: Column(
        children: [
          TextField(
            onChanged: (value) => setState(() => search = value),
            decoration: const InputDecoration(labelText: 'Cerca...'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final entry = filtered[index];
                return ListTile(
                  title: Text('${entry.booth} - ${entry.espositore1}'),
                  subtitle: Text(entry.espositore2),
                  trailing: Checkbox(
                    value: entry.checked,
                    onChanged: (value) {
                      setState(() => entry.checked = value!);
                    },
                  ),
                  onTap: () => _editEntry(entry),
                );
              },
            ),
          ),
          ElevatedButton(onPressed: _saveFile, child: const Text('Salva'))
        ],
      ),
    );
  }

  void _editEntry(BoothEntry entry) {
    final controller = TextEditingController(text: entry.espositore2);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Modifica ${entry.booth}"),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
          TextButton(
            onPressed: () {
              setState(() => entry.espositore2 = controller.text);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

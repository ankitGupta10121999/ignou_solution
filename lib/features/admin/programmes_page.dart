import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/programme_model.dart';
import '../../service/programme_service.dart';

class ProgrammesPage extends StatefulWidget {
  const ProgrammesPage({super.key});

  @override
  State<ProgrammesPage> createState() => _ProgrammesPageState();
}

class _ProgrammesPageState extends State<ProgrammesPage> {
  final ProgrammeService _service = ProgrammeService();

  void _showProgrammeDialog({ProgrammeModel? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Add Programme' : 'Edit Programme'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Programme Name'),
              ),
              SizedBox(height: 10,),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final description = descriptionController.text.trim();
              if (name.isEmpty) return;
              final programme = ProgrammeModel(
                id: existing?.id ?? const Uuid().v4(),
                name: name,
                description: description,
              );
              if (existing == null) {
                await _service.addProgramme(programme);
              } else {
                await _service.updateProgramme(programme);
              }
            },
            child: Text(existing == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProgramme(String id) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Programme'),
        content: const Text('Are you sure you want to delete this programme?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _service.deleteProgramme(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProgrammeModel>>(
      stream: _service.getProgrammesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final programmes = snapshot.data ?? [];
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Programmes',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showProgrammeDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Programme'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: programmes.isEmpty
                        ? const Center(child: Text('No programmes added yet'))
                        : SingleChildScrollView(
                            child: SizedBox(
                              child: DataTable(
                                headingRowHeight: 40,
                                dataRowMinHeight: 30,
                                dataRowMaxHeight: 40,
                                columns: const [
                                  DataColumn(label: Text('Name')),
                                  DataColumn(label: Text('Description')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: programmes.map((programme) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(programme.name)),
                                      DataCell(Text(programme.description!)),
                                      DataCell(
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.blueAccent,
                                              ),
                                              onPressed: () =>
                                                  _showProgrammeDialog(
                                                    existing: programme,
                                                  ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.redAccent,
                                              ),
                                              onPressed: () =>
                                                  _deleteProgramme(programme.id),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

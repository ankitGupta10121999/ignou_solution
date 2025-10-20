import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:ignousolutionhub/constants/appRouter_constants.dart';
import 'package:ignousolutionhub/features/admin/subjects_page.dart';
import '../../service/firestore_course_service.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final FirestoreCourseService _service = FirestoreCourseService();
  final TextEditingController _nameController = TextEditingController();
  String? _editingId;

  void _saveCourse() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    if (_editingId == null) {
      await _service.createCourse(name);
    } else {
      await _service.updateCourse(_editingId!, name);
      _editingId = null;
    }
    _nameController.clear();
  }

  void _editCourse(DocumentSnapshot doc) {
    setState(() {
      _editingId = doc['id'];
      _nameController.text = doc['name'];
    });
  }

  void _deleteCourse(String id) async {
    await _service.deleteCourse(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Row(
            children: [
              Expanded(
                flex: isWide ? 1 : 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Course Name',
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _saveCourse,
                        child: Text(
                          _editingId == null ? 'Add Course' : 'Update Course',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _service.getCourses(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data!.docs;
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 380,
                        // Each card’s max width
                        mainAxisExtent: 100,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 3,
                      ),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(doc['name']),
                            subtitle: Text(
                              'Created: ${DateTime.fromMillisecondsSinceEpoch(doc['createdAt'])}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'View Subjects',
                                  icon: const Icon(Icons.menu_book_outlined),
                                  onPressed: () {
                                    final courseId = doc['id'];
                                    GoRouter.of(context).go(
                                      '${RouterConstant.adminSubjects}/$courseId',
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editCourse(doc),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteCourse(doc['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

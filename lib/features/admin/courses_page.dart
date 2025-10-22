import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ignousolutionhub/constants/appRouter_constants.dart';
import 'package:responsive_builder/responsive_builder.dart';

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
        title: Text(
          'Courses',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: ScreenTypeLayout.builder(
        mobile: (BuildContext context) => LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: Column(
              children: [
                _formSection(),
                SizedBox(height: 500, child: _coursesGrid(constraints)),
              ],
            ),
          ),
        ),
        tablet: (BuildContext context) => LayoutBuilder(
          builder: (context, constraints) => Row(
            children: [
              Expanded(flex: 1, child: _formSection()),
              Expanded(flex: 2, child: _coursesGrid(constraints)),
            ],
          ),
        ),
        desktop: (BuildContext context) => LayoutBuilder(
          builder: (context, constraints) => Row(
            children: [
              Expanded(flex: 1, child: _formSection()),
              Expanded(flex: 2, child: _coursesGrid(constraints)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _coursesGrid(BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;

    final double maxCardWidth = 350;
    final crossAxisCount = (screenWidth / maxCardWidth).floor().clamp(1, 4);

    final double cardHeight = screenWidth < 600 ? 140 : 200;
    return StreamBuilder<QuerySnapshot>(
      stream: _service.getCourses(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        return GridView.builder(
          padding: const EdgeInsets.all(32),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 24, // Increased spacing
            mainAxisSpacing: 24, // Increased spacing
            mainAxisExtent: cardHeight,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  final courseId = doc['id'];
                  GoRouter.of(
                    context,
                  ).go('${RouterConstant.adminSubjects}/$courseId');
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        doc['name'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Created: ${DateTime.fromMillisecondsSinceEpoch(doc['createdAt'])}',
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            tooltip: 'View Subjects',
                            icon: const Icon(Icons.menu_book_outlined),
                            onPressed: () {
                              final courseId = doc['id'];
                              GoRouter.of(
                                context,
                              ).go('${RouterConstant.adminSubjects}/$courseId');
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
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _formSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Course Name'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _saveCourse,
            child: Text(_editingId == null ? 'Add Course' : 'Update Course'),
          ),
        ],
      ),
    );
  }
}

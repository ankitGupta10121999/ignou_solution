import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ignousolutionhub/constants/appRouter_constants.dart';
import 'package:ignousolutionhub/core/locator.dart';
import 'package:ignousolutionhub/models/course_model.dart';
import 'package:ignousolutionhub/service/programme_service.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../models/programme_model.dart';
import '../../service/firestore_course_service.dart';
import '../../utils/common_utils.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final _service = locator<FirestoreCourseService>();
  final _programmeService = locator<ProgrammeService>();
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  ProgrammeModel? selectedProgramme;
  String? _editingId;

  void _saveCourse() async {
    if (_formKey.currentState!.validate() && selectedProgramme != null) {
      final name = _nameController.text.trim();
      if (_editingId == null) {
        await _service.createCourse(
          CourseModel(
            id: CommonUtils.generateUuid(),
            name: name,
            programId: selectedProgramme!.id,
            createdAt: CommonUtils.getCurrentTimeMillis(),
            updateAt: CommonUtils.getCurrentTimeMillis(),
          ),
        );
      } else {
        await _service.updateCourse(
          _editingId!,
          CourseModel(
            id: _editingId!,
            name: name,
            programId: selectedProgramme!.id,
            updateAt: CommonUtils.getCurrentTimeMillis()
          ),
        );
        _editingId = null;
      }
      _nameController.clear();
      selectedProgramme = null;
    } else if (selectedProgramme == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one programme')),
      );
    }
  }

  void _editCourse(CourseModel courseModel) async {
    if (courseModel.programId != null && courseModel.programId!.isNotEmpty) {
      final programme = _programmeService.getProgrammeById(
        courseModel.programId!,
      );
      selectedProgramme = await programme.first;
    } else {
      selectedProgramme = null;
    }
    setState(() {
      _editingId = courseModel.id;
      _nameController.text = courseModel.name;
    });
  }

  void _deleteCourse(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: const Text('Are you sure you want to delete this course?'),
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
      await _service.deleteCourse(id);
    }
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
    return StreamBuilder<List<CourseModel>>(
      stream: _service.getCourseList(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!;
        return GridView.builder(
          padding: const EdgeInsets.all(32),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            mainAxisExtent: cardHeight,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final CourseModel doc = docs[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  final courseId = doc.id;
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
                        doc.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Created: ${DateTime.fromMillisecondsSinceEpoch(doc.createdAt!)}',
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            tooltip: 'View Subjects',
                            icon: const Icon(Icons.menu_book_outlined),
                            onPressed: () {
                              final courseId = doc.id;
                              GoRouter.of(
                                context,
                              ).go('${RouterConstant.adminSubjects}/$courseId');
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                _editCourse(doc),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteCourse(doc.id),
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
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Course Name'),
              validator: (val) => val!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<ProgrammeModel>>(
              stream: _programmeService.getProgrammesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                final programmes = snapshot.data ?? [];
                return DropdownSearch<ProgrammeModel>(
                  items: (f, cs) => programmes,
                  compareFn: (a, b) => a.id == b.id,
                  itemAsString: (programme) => programme.name,
                  selectedItem: selectedProgramme,
                  onChanged: (value) => selectedProgramme = value,
                  popupProps: PopupPropsMultiSelection.menu(
                    showSearchBox: true,
                    constraints: const BoxConstraints(maxHeight: 300),
                    emptyBuilder: (context, searchEntry) => Container(
                      height: 80,
                      alignment: Alignment.center,
                      child: const Text(
                        'No programme found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    searchFieldProps: const TextFieldProps(
                      decoration: InputDecoration(
                        hintText: 'Search programme...',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  decoratorProps: DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: 'Select Programme',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveCourse,
              child: Text(_editingId == null ? 'Add Course' : 'Update Course'),
            ),
          ],
        ),
      ),
    );
  }
}

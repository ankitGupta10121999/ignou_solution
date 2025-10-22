// Keep all previous imports
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../core/locator.dart';
import '../../models/course_model.dart';
import '../../models/subject_model.dart';
import '../../service/firestore_course_service.dart';
import '../../constants/firebase_collections.dart';

class SubjectsPage extends StatefulWidget {
  final String? courseId;

  const SubjectsPage({super.key, this.courseId});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirestoreCourseService _courseService =
      locator<FirestoreCourseService>();
  List<CourseModel> selectedCourses = [];

  Stream<List<SubjectModel>> getSubjectsStream() {
    Query query = FirebaseFirestore.instance.collection(
      FirebaseCollections.subjects,
    );
    if (widget.courseId != null && widget.courseId!.isNotEmpty) {
      query = query.where('courseIds', arrayContains: widget.courseId);
    }
    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) => SubjectModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList(),
    );
  }

  Future<void> addSubject() async {
    if (_formKey.currentState!.validate() && selectedCourses.isNotEmpty) {
      final newSubject = SubjectModel(
        id: '',
        name: _nameController.text,
        code: _codeController.text,
        courseIds: selectedCourses.map((e) => e.id).toList(),
      );
      await FirebaseFirestore.instance
          .collection(FirebaseCollections.subjects)
          .add(newSubject.toMap());
      _nameController.clear();
      _codeController.clear();
      setState(() => selectedCourses = []);
    }
  }

  Future<void> editSubjectDialog(SubjectModel subject) async {
    final editNameController = TextEditingController(text: subject.name);
    final editCodeController = TextEditingController(text: subject.code);
    List<CourseModel> editSelectedCourses = [];

    // Fetch all courses to prefill selected courses
    final coursesSnapshot = await _courseService.getCourseList().first;
    editSelectedCourses = coursesSnapshot
        .where((c) => subject.courseIds.contains(c.id))
        .toList();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Subject'),
        content: SingleChildScrollView(
          child: Form(
            key: GlobalKey<FormState>(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: editNameController,
                  decoration: const InputDecoration(labelText: 'Subject Name'),
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: editCodeController,
                  decoration: const InputDecoration(labelText: 'Subject Code'),
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                DropdownSearch<CourseModel>.multiSelection(
                  items: (f, cs) => coursesSnapshot,
                  compareFn: (a, b) => a.id == b.id,
                  itemAsString: (course) => course.name,
                  selectedItems: editSelectedCourses,
                  onChanged: (value) => editSelectedCourses = value,
                  popupProps: PopupPropsMultiSelection.menu(
                    showSearchBox: true,
                    constraints: const BoxConstraints(maxHeight: 300),
                    emptyBuilder: (context, searchEntry) => Container(
                      height: 80,
                      alignment: Alignment.center,
                      child: const Text(
                        'No course found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    searchFieldProps: const TextFieldProps(
                      decoration: InputDecoration(
                        hintText: 'Search course...',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  decoratorProps: DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: 'Select Course',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  dropdownBuilder: (context, selectedItems) => Wrap(
                    spacing: 6,
                    children: selectedItems
                        .map((e) => Chip(label: Text(e.name)))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (editNameController.text.isEmpty ||
                  editCodeController.text.isEmpty ||
                  editSelectedCourses.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All fields and courses are required'),
                  ),
                );
                return;
              }
              await FirebaseFirestore.instance
                  .collection(FirebaseCollections.subjects)
                  .doc(subject.id)
                  .update({
                    'name': editNameController.text,
                    'code': editCodeController.text,
                    'courseIds': editSelectedCourses.map((e) => e.id).toList(),
                  });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteSubjectDialog(SubjectModel subject) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete "${subject.name}"?'),
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
    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection(FirebaseCollections.subjects)
          .doc(subject.id)
          .delete();
    }
  }

  Widget buildSubjectsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Subjects List",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<SubjectModel>>(
          stream: getSubjectsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            final subjects = snapshot.data ?? [];
            if (subjects.isEmpty) {
              return const SizedBox(
                height: 500,
                width: 800,
                child: Center(
                  child: Text(
                    'No subjects found',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final s = subjects[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(s.name),
                    subtitle: Text(s.code),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => editSubjectDialog(s),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteSubjectDialog(s),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget buildAddSubjectForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Add Subject",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Subject Name'),
            validator: (val) => val!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _codeController,
            decoration: const InputDecoration(labelText: 'Subject Code'),
            validator: (val) => val!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<CourseModel>>(
            stream: _courseService.getCourseList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              final courses = snapshot.data ?? [];
              return DropdownSearch<CourseModel>.multiSelection(
                items: (f, cs) => courses,
                compareFn: (a, b) => a.id == b.id,
                itemAsString: (course) => course.name,
                selectedItems: selectedCourses,
                onChanged: (value) => selectedCourses = value,
                popupProps: PopupPropsMultiSelection.menu(
                  showSearchBox: true,
                  constraints: const BoxConstraints(maxHeight: 300),
                  emptyBuilder: (context, searchEntry) => Container(
                    height: 80,
                    alignment: Alignment.center,
                    child: const Text(
                      'No course found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  searchFieldProps: const TextFieldProps(
                    decoration: InputDecoration(
                      hintText: 'Search course...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),

                ),
                decoratorProps: DropDownDecoratorProps(
                  decoration: InputDecoration(
                    labelText: 'Select Course',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                dropdownBuilder: (context, selectedItems) => Wrap(
                  spacing: 6,
                  children: selectedItems
                      .map((e) => Chip(label: Text(e.name)))
                      .toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: addSubject,
            child: const Text('Add Subject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.courseId == null ? 'Subjects' : 'Subjects for Course',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent,
        ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          if (isWide) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.courseId == null)
                    Expanded(flex: 1, child: buildAddSubjectForm()),
                  if (widget.courseId == null) const SizedBox(width: 24),
                  Expanded(flex: 2, child: buildSubjectsList()),
                ],
              ),
            );
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.courseId == null) buildAddSubjectForm(),
                  if (widget.courseId == null) const SizedBox(height: 32),
                  buildSubjectsList(),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/department_model.dart';
import '../../models/course_model.dart';
import '../../service/department_service.dart';
import '../../service/firestore_course_service.dart';
import '../../core/locator.dart';

class DepartmentPage extends StatefulWidget {
  const DepartmentPage({super.key});

  @override
  State<DepartmentPage> createState() => _DepartmentPageState();
}

class _DepartmentPageState extends State<DepartmentPage> {
  final DepartmentService _service = DepartmentService();
  final _courseService = locator<FirestoreCourseService>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _editingId;
  CourseModel? selectedCourse;

  void _saveDepartment() async {
    if (_formKey.currentState!.validate() && selectedCourse != null) {
      final name = _nameController.text.trim();
      final code = _codeController.text.trim();

      final now = DateTime.now().millisecondsSinceEpoch;
      final department = DepartmentModel(
        id: _editingId ?? FirebaseFirestore.instance.collection('tmp').doc().id,
        name: name,
        code: code,
        createdAt: now,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (_editingId == null) {
          await _service.createDepartment(department);
        } else {
          await _service.updateDepartment(department);
          _editingId = null;
        }
        _nameController.clear();
        _codeController.clear();
        setState(() {
          selectedCourse = null;
        });
      });
    } else if (selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a course')),
      );
    }
  }

  void _editDepartment(DepartmentModel dept) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _editingId = dept.id;
        _nameController.text = dept.name;
        _codeController.text = dept.code;
        // Set selectedCourse if you have the courseId stored
      });
    });
  }

  void _deleteDepartment(String id) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _service.deleteDepartment(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Departments',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 600;
          if (isDesktop) {
            return _buildDesktopLayout();
          } else {
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Divider(
            color: Colors.grey[400],
            thickness: 1.0,
            indent: 16.0,
            endIndent: 16.0,
          ),
          Padding(padding: const EdgeInsets.all(16.0), child: _formSection()),
          Divider(
            color: Colors.grey[400],
            thickness: 1.0,
            indent: 16.0,
            endIndent: 16.0,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _departmentsMobileList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        Divider(
          color: Colors.grey[400],
          thickness: 1.0,
          indent: 16.0,
          endIndent: 16.0,
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 350,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: _formSection(),
                ),
              ),
              VerticalDivider(color: Colors.grey[400], thickness: 1.0),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _departmentsGrid(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _departmentsMobileList() {
    return StreamBuilder<List<DepartmentModel>>(
      stream: _service.getAllDepartments(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final depts = snapshot.data!;
        if (depts.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text('No departments yet')),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: depts.length,
          itemBuilder: (context, index) {
            final dept = depts[index];
            return Card(
              elevation: 5,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dept.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Department Code: ${dept.code}",
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              Future.microtask(() => _editDepartment(dept)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => Future.microtask(
                                () => _deleteDepartment(dept.id),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _departmentsGrid() {
    return StreamBuilder<List<DepartmentModel>>(
      stream: _service.getAllDepartments(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final depts = snapshot.data!;
        if (depts.isEmpty) {
          return const Center(child: Text('No departments yet'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 150,
          ),
          itemCount: depts.length,
          itemBuilder: (context, index) {
            final dept = depts[index];
            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dept.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Department Code: ${dept.code}",
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              Future.microtask(() => _editDepartment(dept)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => Future.microtask(
                                () => _deleteDepartment(dept.id),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _formSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _editingId == null ? "Add Department" : "Edit Department",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Department Name"),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: "Department Code"),
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
                  return DropdownSearch<CourseModel>(
                    items: (f, cs) => courses,
                    compareFn: (a, b) => a.id == b.id,
                    itemAsString: (course) => course.name,
                    selectedItem: selectedCourse,
                    onChanged: (value) => selectedCourse = value,
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
                  );
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _saveDepartment,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _editingId == null ? "Add Department" : "Update Department",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
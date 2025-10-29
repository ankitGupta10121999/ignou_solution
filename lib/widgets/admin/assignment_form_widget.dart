import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../../models/assignment_model.dart';
import '../../models/subject_model.dart';
import '../../service/subject_service.dart';
import '../../constants/session_constants.dart';

class AssignmentFormWidget extends StatefulWidget {
  final AssignmentModel? assignment;
  final Function(AssignmentModel) onAssignmentChanged;
  final VoidCallback? onSubmit;
  final bool isEditing;

  const AssignmentFormWidget({
    super.key,
    this.assignment,
    required this.onAssignmentChanged,
    this.onSubmit,
    this.isEditing = false,
  });

  @override
  State<AssignmentFormWidget> createState() => _AssignmentFormWidgetState();
}

class _AssignmentFormWidgetState extends State<AssignmentFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _subjectService = SubjectService();

  late final TextEditingController _pdfPriceController;
  late final TextEditingController _handwrittenPriceController;
  late final TextEditingController _discountController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagsController;

  SubjectModel? _selectedSubject;
  String _selectedMedium = '';
  String _selectedSession = '';
  String _selectedDifficulty = 'Medium';
  String _selectedStatus = 'Active';
  DateTime? _selectedDueDate;
  List<String> _tags = [];
  bool _requiresApproval = false;

  List<SubjectModel> _subjects = [];
  List<String> _availableMediums = [];

  final List<String> _difficultyLevels = ['Easy', 'Medium', 'Hard'];
  final List<String> _statusOptions = ['Active', 'Draft', 'Inactive'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadSubjects();
    _populateFormFromAssignment();
  }

  void _initializeControllers() {
    _pdfPriceController = TextEditingController();
    _handwrittenPriceController = TextEditingController();
    _discountController = TextEditingController(text: '0');
    _descriptionController = TextEditingController();
    _tagsController = TextEditingController();
  }

  void _populateFormFromAssignment() {
    if (widget.assignment != null) {
      final assignment = widget.assignment!;
      _pdfPriceController.text = assignment.pdfPrice.toString();
      _handwrittenPriceController.text = assignment.handwrittenPrice.toString();
      _discountController.text = assignment.discountPercentage.toString();
      _descriptionController.text = assignment.description;
      _selectedMedium = assignment.medium;
      _selectedSession = assignment.session;
      _selectedDifficulty = assignment.difficulty;
      _selectedStatus = assignment.status;
      _selectedDueDate = assignment.dueDate;
      _tags = List.from(assignment.tags);
      _tagsController.text = _tags.join(', ');
      _requiresApproval = assignment.requiresApproval;
    } else {
      // Set default session to current session for new assignments
      _selectedSession = SessionConstants.getCurrentSession();
    }
  }

  void _loadSubjects() async {
    _subjectService.getSubjects().listen((subjects) {
      setState(() {
        _subjects = subjects;
        if (widget.assignment != null) {
          _selectedSubject = subjects.firstWhere(
            (s) => s.id == widget.assignment!.subjectId,
            orElse: () => subjects.isNotEmpty
                ? subjects.first
                : SubjectModel(id: '', name: '', code: '', courseIds: []),
          );
          _updateAvailableMediums();
        }
      });
    });
  }

  void _updateAvailableMediums() {
    if (_selectedSubject != null) {

        _availableMediums = _selectedSubject!.availableMediums;
        if (!_availableMediums.contains(_selectedMedium) &&
            _availableMediums.isNotEmpty) {
          _selectedMedium = _availableMediums.first;
        }
      _notifyAssignmentChanged();
    }
  }

  void _notifyAssignmentChanged() {
    if (_selectedSubject == null) return;

    final assignment = AssignmentModel(
      id: widget.assignment?.id ?? '',
      subjectId: _selectedSubject!.id,
      subjectName: _selectedSubject!.name,
      medium: _selectedMedium,
      session: _selectedSession,
      pdfPrice: double.tryParse(_pdfPriceController.text) ?? 0.0,
      handwrittenPrice:
          double.tryParse(_handwrittenPriceController.text) ?? 0.0,
      discountPercentage: double.tryParse(_discountController.text) ?? 0.0,
      description: _descriptionController.text,
      difficulty: _selectedDifficulty,
      status: _selectedStatus,
      dueDate: _selectedDueDate,
      tags: _tags,
      requiresApproval: _requiresApproval,
      createdAt: widget.assignment?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onAssignmentChanged(assignment);
  }

  void _updateTags(String value) {
    setState(() {
      _tags = value
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
    });
    _notifyAssignmentChanged();
  }

  Widget _buildSubjectDropdown() {
    return DropdownSearch<SubjectModel>(
      items: (filter, infiniteScrollProps) => _subjects,
      itemAsString: (subject) => '${subject.name} (${subject.code})',
      selectedItem: _selectedSubject,
      onChanged: (subject) {
          _selectedSubject = subject;
          _selectedMedium = '';
        _updateAvailableMediums();
      },
      compareFn: (a, b) => a.id == b.id,
      validator: (value) => value == null ? 'Please select a subject' : null,
      popupProps: PopupProps.menu(
        showSearchBox: true,
        constraints: const BoxConstraints(maxHeight: 300),
        searchFieldProps: const TextFieldProps(
          decoration: InputDecoration(
            hintText: 'Search subjects...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
      ),
      decoratorProps: const DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: 'Subject *',
          prefixIcon: Icon(Icons.menu_book),
        ),
      ),
    );
  }

  Widget _buildMediumDropdown() {
    return DropdownButtonFormField<String>(
      value: _availableMediums.contains(_selectedMedium)
          ? _selectedMedium
          : null,
      decoration: const InputDecoration(
        labelText: 'Medium *',
        prefixIcon: Icon(Icons.language),
      ),
      items: _availableMediums.map((medium) {
        return DropdownMenuItem(value: medium, child: Text(medium));
      }).toList(),
      onChanged: _selectedSubject == null
          ? null
          : (value) {
              setState(() {
                _selectedMedium = value ?? '';
              });
              _notifyAssignmentChanged();
            },
      validator: (value) =>
          value == null || value.isEmpty ? 'Please select a medium' : null,
    );
  }

  Widget _buildSessionDropdown() {
    final sessions = SessionConstants.getActiveSessions();
    return DropdownButtonFormField<String>(
      value: sessions.contains(_selectedSession) ? _selectedSession : null,
      decoration: const InputDecoration(
        labelText: 'Session *',
        prefixIcon: Icon(Icons.event),
        helperText: 'Academic session for this assignment',
      ),
      items: sessions.map((session) {
        final isCurrentSession = session == SessionConstants.getCurrentSession();
        return DropdownMenuItem(
          value: session,
          child: Row(
            children: [
              Expanded(
                child: Text(SessionConstants.formatSessionDisplay(session)),
              ),
              if (isCurrentSession)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'Current',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
          _selectedSession = value ?? '';
        _notifyAssignmentChanged();
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Please select a session' : null,
    );
  }

  Widget _buildPriceField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '$label *',
        prefixIcon: Icon(icon),
        prefixText: '₹ ',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) {
          return 'Enter a valid price';
        }
        final price = double.tryParse(value);
        if (price == null || price <= 0) {
          return 'Price must be greater than 0';
        }
        return null;
      },
      onChanged: (_) => _notifyAssignmentChanged(),
    );
  }

  Widget _buildDiscountField() {
    return TextFormField(
      controller: _discountController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Discount Percentage',
        prefixIcon: Icon(Icons.percent),
        suffixText: '%',
        helperText: 'Enter 0-100',
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) {
            return 'Enter a valid percentage';
          }
          final discount = double.tryParse(value);
          if (discount == null || discount < 0 || discount > 100) {
            return 'Discount must be between 0-100%';
          }
        }
        return null;
      },
      onChanged: (_) => _notifyAssignmentChanged(),
    );
  }

  Widget _buildDifficultyDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDifficulty,
      decoration: const InputDecoration(
        labelText: 'Difficulty Level',
        prefixIcon: Icon(Icons.speed),
      ),
      items: _difficultyLevels.map((difficulty) {
        return DropdownMenuItem(
          value: difficulty,
          child: Row(
            children: [
              Icon(
                difficulty == 'Easy'
                    ? Icons.looks_one
                    : difficulty == 'Medium'
                    ? Icons.looks_two
                    : Icons.looks_3,
                color: difficulty == 'Easy'
                    ? Colors.green
                    : difficulty == 'Medium'
                    ? Colors.orange
                    : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(difficulty),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedDifficulty = value ?? 'Medium';
        });
        _notifyAssignmentChanged();
      },
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: const InputDecoration(
        labelText: 'Status',
        prefixIcon: Icon(Icons.flag),
      ),
      items: _statusOptions.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Row(
            children: [
              Icon(
                status == 'Active'
                    ? Icons.check_circle
                    : status == 'Draft'
                    ? Icons.edit
                    : Icons.cancel,
                color: status == 'Active'
                    ? Colors.green
                    : status == 'Draft'
                    ? Colors.orange
                    : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(status),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedStatus = value ?? 'Active';
        });
        _notifyAssignmentChanged();
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Description',
        prefixIcon: Icon(Icons.description),
        helperText: 'Brief description of the assignment',
      ),
      onChanged: (_) => _notifyAssignmentChanged(),
    );
  }

  Widget _buildTagsField() {
    return TextFormField(
      controller: _tagsController,
      decoration: const InputDecoration(
        labelText: 'Tags',
        prefixIcon: Icon(Icons.local_offer),
        helperText: 'Separate tags with commas (e.g., important, urgent)',
      ),
      onChanged: _updateTags,
    );
  }

  Widget _buildDueDateField() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate:
              _selectedDueDate ?? DateTime.now().add(const Duration(days: 30)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() {
            _selectedDueDate = date;
          });
          _notifyAssignmentChanged();
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Due Date',
          prefixIcon: Icon(Icons.calendar_today),
          suffixIcon: Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          _selectedDueDate != null
              ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
              : 'Select due date (optional)',
          style: TextStyle(
            color: _selectedDueDate != null ? null : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildApprovalSwitch() {
    return SwitchListTile(
      title: const Text('Requires Approval'),
      subtitle: const Text('Assignment needs admin approval before going live'),
      value: _requiresApproval,
      onChanged: (value) {
        setState(() {
          _requiresApproval = value;
        });
        _notifyAssignmentChanged();
      },
      secondary: const Icon(Icons.admin_panel_settings),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.assignment,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.isEditing
                        ? 'Edit Assignment'
                        : 'Create New Assignment',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Subject and Medium Row
              Row(
                children: [
                  Expanded(child: _buildSubjectDropdown()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMediumDropdown()),
                ],
              ),
              const SizedBox(height: 16),

              // Session Row
              // _buildSessionDropdown(),
              // const SizedBox(height: 16),

              // Price Fields Row
              Row(
                children: [
                  Expanded(
                    child: _buildPriceField(
                      controller: _pdfPriceController,
                      label: 'PDF Price',
                      icon: Icons.picture_as_pdf,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPriceField(
                      controller: _handwrittenPriceController,
                      label: 'Handwritten Price',
                      icon: Icons.edit,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Discount and Difficulty Row
              Row(
                children: [
                  Expanded(child: _buildDiscountField()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDifficultyDropdown()),
                ],
              ),
              const SizedBox(height: 16),

              // Status and Due Date Row
              Row(
                children: [
                  Expanded(child: _buildStatusDropdown()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDueDateField()),
                ],
              ),
              const SizedBox(height: 16),

              _buildDescriptionField(),
              const SizedBox(height: 16),

              _buildTagsField(),
              const SizedBox(height: 16),

              _buildApprovalSwitch(),
              const SizedBox(height: 24),

              if (widget.onSubmit != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSubmit!();
                      }
                    },
                    icon: Icon(widget.isEditing ? Icons.save : Icons.add),
                    label: Text(
                      widget.isEditing
                          ? 'Update Assignment'
                          : 'Create Assignment',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pdfPriceController.dispose();
    _handwrittenPriceController.dispose();
    _discountController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}

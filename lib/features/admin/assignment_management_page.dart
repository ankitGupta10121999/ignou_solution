import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../models/assignment_model.dart';
import '../../service/assignment_service.dart';
import '../../widgets/admin/assignment_form_widget.dart';
import '../../widgets/admin/assignment_preview_widget.dart';
import '../../widgets/admin/assignment_list_widget.dart';

class AssignmentManagementPage extends StatefulWidget {
  const AssignmentManagementPage({super.key});

  @override
  State<AssignmentManagementPage> createState() =>
      _AssignmentManagementPageState();
}

class _AssignmentManagementPageState extends State<AssignmentManagementPage> {
  final _assignmentService = AssignmentService();

  AssignmentModel? _currentAssignment;
  bool _isEditing = false;
  bool _showForm = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          return _buildBody(context, sizingInformation);
        },
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Assignment Management',
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
      centerTitle: false,
      backgroundColor: Colors.transparent,
      actions: [
        if (_isEditing) ...[
          IconButton(
            icon: Icon(Icons.cancel, color: Theme.of(context).primaryColor),
            onPressed: _cancelEditing,
            tooltip: 'Cancel Edit',
          ),
        ],
        IconButton(
          icon: Icon(
            _showForm ? Icons.visibility : Icons.edit,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            setState(() {
              _showForm = !_showForm;
            });
          },
          tooltip: _showForm ? 'View Only' : 'Show Form',
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          iconColor: Theme.of(context).primaryColor,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'templates',
              child: ListTile(
                leading: Icon(Icons.save_alt),
                title: Text('Manage Templates'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('Export Data'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'stats',
              child: ListTile(
                leading: Icon(Icons.analytics),
                title: Text('View Statistics'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, SizingInformation sizingInformation) {
    if (sizingInformation.deviceScreenType == DeviceScreenType.mobile) {
      return _buildMobileLayout(context);
    } else if (sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
      return _buildTabletLayout(context);
    } else {
      return _buildDesktopLayout(context);
    }
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_showForm) ...[
            _buildFormSection(context),
            const SizedBox(height: 16),
            _buildPreviewSection(context),
            const SizedBox(height: 16),
          ],
          _buildListSection(context),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_showForm) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildFormSection(context)),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildPreviewSection(context)),
              ],
            ),
            const SizedBox(height: 24),
          ],
          _buildListSection(context),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_showForm) ...[
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFormSection(context),
                    const SizedBox(height: 16),
                    // _buildPreviewSection(context),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
          ],
          // Expanded(flex: 3, child: _buildListSection(context)),
        ],
      ),
    );
  }

  Widget _buildFormSection(BuildContext context) {
    return AssignmentFormWidget(
      key: _formKey,
      assignment: _currentAssignment,
      isEditing: _isEditing,
      onAssignmentChanged: (assignment) {
          _currentAssignment = assignment;
      },
      onSubmit: _handleSubmit,
    );
  }

  Widget _buildPreviewSection(BuildContext context) {
    return AssignmentPreviewWidget(
      assignment: _currentAssignment,
      showTitle: true,
    );
  }

  Widget _buildListSection(BuildContext context) {
    return AssignmentListWidget(
      onEdit: _editAssignment,
      onDelete: _deleteAssignment,
      onDuplicate: _duplicateAssignment,
      onBulkAction: _handleBulkAction,
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _createNewAssignment,
      icon: Icon(_isEditing ? Icons.add : Icons.add),
      label: Text(_isEditing ? 'New Assignment' : 'Create Assignment'),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
    );
  }

  // Action Handlers
  void _handleSubmit() async {
    if (_currentAssignment == null) return;

    try {
      if (_isEditing) {
        await _assignmentService.updateAssignment(_currentAssignment!);
        _showSuccessMessage('Assignment updated successfully');
      } else {
        await _assignmentService.addAssignment(_currentAssignment!);
        _showSuccessMessage('Assignment created successfully');
      }

      _resetForm();
    } catch (e) {
      _showErrorMessage('Error saving assignment: $e');
    }
  }

  void _editAssignment(AssignmentModel assignment) {
    setState(() {
      _currentAssignment = assignment;
      _isEditing = true;
      _showForm = true;
    });

    // Scroll to top on mobile
    if (MediaQuery.of(context).size.width < 600) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _deleteAssignment(AssignmentModel assignment) async {
    final confirmed = await _showDeleteConfirmation(context, assignment);
    if (confirmed == true) {
      try {
        await _assignmentService.deleteAssignment(assignment.id);
        _showSuccessMessage('Assignment deleted successfully');

        // Clear form if editing this assignment
        if (_isEditing && _currentAssignment?.id == assignment.id) {
          _resetForm();
        }
      } catch (e) {
        _showErrorMessage('Error deleting assignment: $e');
      }
    }
  }

  void _duplicateAssignment(AssignmentModel assignment) async {
    try {
      await _assignmentService.duplicateAssignment(assignment.id);
      _showSuccessMessage('Assignment duplicated successfully');
    } catch (e) {
      _showErrorMessage('Error duplicating assignment: $e');
    }
  }

  void _handleBulkAction(List<AssignmentModel> assignments) {
    // Handle bulk actions if needed
    _showInfoMessage(
      'Bulk action completed for ${assignments.length} assignments',
    );
  }

  void _createNewAssignment() {
    _resetForm();
    setState(() {
      _showForm = true;
    });
  }

  void _cancelEditing() {
    _resetForm();
  }

  void _resetForm() {
    setState(() {
      _currentAssignment = null;
      _isEditing = false;
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'templates':
        _showTemplatesDialog(context);
        break;
      case 'export':
        _showExportDialog(context);
        break;
      case 'stats':
        _showStatsDialog(context);
        break;
    }
  }

  // Dialog Methods
  Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    AssignmentModel assignment,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete this assignment?'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.subjectName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Medium: ${assignment.medium}'),
                  Text('Status: ${assignment.status}'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showTemplatesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assignment Templates'),
        content: const SizedBox(
          width: 400,
          height: 300,
          child: Center(child: Text('Template management coming soon...')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Assignments'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export to CSV'),
              onTap: () {
                Navigator.pop(context);
                _showInfoMessage('CSV export coming soon...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export to PDF'),
              onTap: () {
                Navigator.pop(context);
                _showInfoMessage('PDF export coming soon...');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assignment Statistics'),
        content: FutureBuilder<Map<String, int>>(
          future: _assignmentService.getAssignmentStats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final stats = snapshot.data ?? {};
            return SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatRow('Total Assignments', stats['total'] ?? 0),
                  _buildStatRow('Active', stats['active'] ?? 0),
                  _buildStatRow('Draft', stats['draft'] ?? 0),
                  _buildStatRow('Inactive', stats['inactive'] ?? 0),
                  _buildStatRow('With Discount', stats['withDiscount'] ?? 0),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Snackbar Methods
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

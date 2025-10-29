import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../models/assignment_model.dart';
import '../../models/subject_model.dart';
import '../../service/assignment_service.dart';
import '../../service/subject_service.dart';
import '../../constants/session_constants.dart';

class AssignmentListWidget extends StatefulWidget {
  final Function(AssignmentModel) onEdit;
  final Function(AssignmentModel) onDelete;
  final Function(AssignmentModel)? onDuplicate;
  final Function(List<AssignmentModel>)? onBulkAction;

  const AssignmentListWidget({
    super.key,
    required this.onEdit,
    required this.onDelete,
    this.onDuplicate,
    this.onBulkAction,
  });

  @override
  State<AssignmentListWidget> createState() => _AssignmentListWidgetState();
}

class _AssignmentListWidgetState extends State<AssignmentListWidget> {
  final _assignmentService = AssignmentService();
  final _subjectService = SubjectService();
  
  String _filterStatus = '';
  String _filterMedium = '';
  String _filterSubject = '';
  String _filterSession = '';
  String _searchQuery = '';
  String _sortBy = 'createdAt';
  bool _sortAscending = false;
  
  List<AssignmentModel> _selectedAssignments = [];
  bool _selectAll = false;
  
  final List<String> _statusOptions = ['', 'Active', 'Draft', 'Inactive'];
  final List<String> _mediumOptions = ['', 'English', 'Hindi'];
  final List<String> _sortOptions = ['createdAt', 'subjectName', 'pdfPrice', 'discountPercentage'];
  
  List<String> get _sessionOptions => ['', ...SessionConstants.getActiveSessions()];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildFiltersAndSearch(context),
          _buildBulkActions(context),
          _buildAssignmentsList(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.list_alt,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'Assignments List',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const Spacer(),
          StreamBuilder<Map<String, int>>(
            stream: _getStatsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final stats = snapshot.data!;
                return Row(
                  children: [
                    _buildStatChip('Total', stats['total'] ?? 0, Colors.blue),
                    const SizedBox(width: 8),
                    _buildStatChip('Active', stats['active'] ?? 0, Colors.green),
                    const SizedBox(width: 8),
                    _buildStatChip('Draft', stats['draft'] ?? 0, Colors.orange),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFiltersAndSearch(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Search assignments...',
              prefixIcon: Icon(Icons.search),
              suffixIcon: Icon(Icons.filter_list),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Filters Row
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              SizedBox(
                width: 150,
                child: DropdownButtonFormField<String>(
                  value: _filterStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    isDense: true,
                  ),
                  items: _statusOptions.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.isEmpty ? 'All Status' : status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _filterStatus = value ?? '';
                    });
                  },
                ),
              ),
              
              SizedBox(
                width: 150,
                child: DropdownButtonFormField<String>(
                  value: _filterMedium,
                  decoration: const InputDecoration(
                    labelText: 'Medium',
                    isDense: true,
                  ),
                  items: _mediumOptions.map((medium) {
                    return DropdownMenuItem(
                      value: medium,
                      child: Text(medium.isEmpty ? 'All Mediums' : medium),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _filterMedium = value ?? '';
                    });
                  },
                ),
              ),
              
              SizedBox(
                width: 200,
                child: StreamBuilder<List<SubjectModel>>(
                  stream: _subjectService.getSubjects(),
                  builder: (context, snapshot) {
                    final subjects = snapshot.data ?? [];
                    return DropdownSearch<String>(
                      items: (filter, infiniteScrollProps) => ['', ...subjects.map((s) => s.id)],
                      itemAsString: (subjectId) {
                        if (subjectId.isEmpty) return 'All Subjects';
                        final subject = subjects.firstWhere(
                          (s) => s.id == subjectId,
                          orElse: () => SubjectModel(id: '', name: 'Unknown', code: '', courseIds: []),
                        );
                        return subject.name;
                      },
                      selectedItem: _filterSubject,
                      onChanged: (value) {
                        setState(() {
                          _filterSubject = value ?? '';
                        });
                      },
                      decoratorProps: const DropDownDecoratorProps(
                        decoration: InputDecoration(
                          labelText: 'Subject',
                          isDense: true,
                        ),
                      ),
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        constraints: BoxConstraints(maxHeight: 200),
                      ),
                    );
                  },
                ),
              ),
              
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String>(
                  value: _filterSession,
                  decoration: const InputDecoration(
                    labelText: 'Session',
                    isDense: true,
                  ),
                  items: _sessionOptions.map((session) {
                    return DropdownMenuItem(
                      value: session,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              session.isEmpty 
                                  ? 'All Sessions' 
                                  : SessionConstants.formatSessionDisplay(session),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (session.isNotEmpty && session == SessionConstants.getCurrentSession())
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.green.withOpacity(0.3)),
                              ),
                              child: const Text(
                                'Now',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _filterSession = value ?? '';
                    });
                  },
                ),
              ),
              
              SizedBox(
                width: 160,
                child: DropdownButtonFormField<String>(
                  value: _sortBy,
                  decoration: const InputDecoration(
                    labelText: 'Sort By',
                    isDense: true,
                  ),
                  items: _sortOptions.map((sort) {
                    String label;
                    switch (sort) {
                      case 'createdAt':
                        label = 'Date Created';
                        break;
                      case 'subjectName':
                        label = 'Subject';
                        break;
                      case 'pdfPrice':
                        label = 'PDF Price';
                        break;
                      case 'discountPercentage':
                        label = 'Discount';
                        break;
                      default:
                        label = sort;
                    }
                    return DropdownMenuItem(
                      value: sort,
                      child: Text(label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value ?? 'createdAt';
                    });
                  },
                ),
              ),
              
              IconButton(
                icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                onPressed: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                  });
                },
                tooltip: _sortAscending ? 'Sort Ascending' : 'Sort Descending',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActions(BuildContext context) {
    if (_selectedAssignments.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).primaryColor.withOpacity(0.05),
      child: Row(
        children: [
          Text(
            '${_selectedAssignments.length} selected',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showBulkStatusDialog(context),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Change Status'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showBulkDiscountDialog(context),
                icon: const Icon(Icons.local_offer, size: 16),
                label: const Text('Apply Discount'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showBulkDeleteDialog(context),
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedAssignments.clear();
                    _selectAll = false;
                  });
                },
                child: const Text('Clear Selection'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentsList(BuildContext context) {
    return StreamBuilder<List<AssignmentModel>>(
      stream: _getFilteredAssignmentsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.error, size: 48, color: Colors.red.shade400),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            ),
          );
        }
        
        final assignments = _filterAndSortAssignments(snapshot.data ?? []);
        
        if (assignments.isEmpty) {
          return _buildEmptyState(context);
        }
        
        return Column(
          children: [
            // Select All Checkbox
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _selectAll,
                    onChanged: (value) {
                      setState(() {
                        _selectAll = value ?? false;
                        if (_selectAll) {
                          _selectedAssignments = List.from(assignments);
                        } else {
                          _selectedAssignments.clear();
                        }
                      });
                    },
                  ),
                  const Text('Select All'),
                ],
              ),
            ),
            
            // Assignments List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final assignment = assignments[index];
                final isSelected = _selectedAssignments.contains(assignment);
                
                return _buildAssignmentTile(context, assignment, isSelected);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAssignmentTile(BuildContext context, AssignmentModel assignment, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : null,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: ListTile(
        leading: Checkbox(
          value: isSelected,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedAssignments.add(assignment);
              } else {
                _selectedAssignments.remove(assignment);
              }
              _selectAll = _selectedAssignments.length == _selectedAssignments.length;
            });
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    assignment.subjectName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(assignment.status),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.language, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  assignment.medium,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.speed, size: 16, color: _getDifficultyColor(assignment.difficulty)),
                const SizedBox(width: 4),
                Text(
                  assignment.difficulty,
                  style: TextStyle(
                    color: _getDifficultyColor(assignment.difficulty),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.event, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  SessionConstants.formatSessionDisplay(assignment.session),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                if (assignment.session == SessionConstants.getCurrentSession()) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
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
              ],
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              _buildPriceInfo('PDF', assignment.pdfPrice, assignment.discountedPdfPrice),
              const SizedBox(width: 16),
              _buildPriceInfo('HW', assignment.handwrittenPrice, assignment.discountedHandwrittenPrice),
              if (assignment.hasDiscount) ...[
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${assignment.discountPercentage.toStringAsFixed(0)}% OFF',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: widget.onDuplicate != null ? () => widget.onDuplicate!(assignment) : null,
              tooltip: 'Duplicate',
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => widget.onEdit(assignment),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => widget.onDelete(assignment),
              tooltip: 'Delete',
            ),
          ],
        ),
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedAssignments.remove(assignment);
            } else {
              _selectedAssignments.add(assignment);
            }
          });
        },
      ),
    );
  }

  Widget _buildPriceInfo(String label, double originalPrice, double finalPrice) {
    final hasDiscount = originalPrice != finalPrice;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
        if (hasDiscount) ...[
          Text(
            '₹${originalPrice.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
        Text(
          '₹${finalPrice.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: hasDiscount ? Colors.green.shade700 : null,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Active':
        color = Colors.green;
        break;
      case 'Draft':
        color = Colors.orange;
        break;
      case 'Inactive':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.assignment,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No assignments found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first assignment to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  Stream<List<AssignmentModel>> _getFilteredAssignmentsStream() {
    return _assignmentService.getAssignments(
      subjectId: _filterSubject.isNotEmpty ? _filterSubject : null,
      status: _filterStatus.isNotEmpty ? _filterStatus : null,
      medium: _filterMedium.isNotEmpty ? _filterMedium : null,
      session: _filterSession.isNotEmpty ? _filterSession : null,
    );
  }

  Stream<Map<String, int>> _getStatsStream() {
    return _assignmentService.getAssignments().asyncMap((assignments) async {
      return {
        'total': assignments.length,
        'active': assignments.where((a) => a.status == 'Active').length,
        'draft': assignments.where((a) => a.status == 'Draft').length,
        'inactive': assignments.where((a) => a.status == 'Inactive').length,
      };
    });
  }

  List<AssignmentModel> _filterAndSortAssignments(List<AssignmentModel> assignments) {
    List<AssignmentModel> filtered = assignments;

    // Apply filters
    if (_filterSession.isNotEmpty) {
      filtered = filtered.where((assignment) => assignment.session == _filterSession).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((assignment) {
        return assignment.subjectName.toLowerCase().contains(_searchQuery) ||
               assignment.description.toLowerCase().contains(_searchQuery) ||
               assignment.session.toLowerCase().contains(_searchQuery) ||
               assignment.tags.any((tag) => tag.toLowerCase().contains(_searchQuery));
      }).toList();
    }

    // Sort assignments
    filtered.sort((a, b) {
      dynamic aValue, bValue;
      switch (_sortBy) {
        case 'subjectName':
          aValue = a.subjectName;
          bValue = b.subjectName;
          break;
        case 'pdfPrice':
          aValue = a.pdfPrice;
          bValue = b.pdfPrice;
          break;
        case 'discountPercentage':
          aValue = a.discountPercentage;
          bValue = b.discountPercentage;
          break;
        default:
          aValue = a.createdAt;
          bValue = b.createdAt;
      }

      int comparison = aValue.compareTo(bValue);
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Bulk Action Dialogs
  void _showBulkStatusDialog(BuildContext context) {
    String selectedStatus = 'Active';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Status'),
        content: DropdownButtonFormField<String>(
          value: selectedStatus,
          items: ['Active', 'Draft', 'Inactive'].map((status) {
            return DropdownMenuItem(value: status, child: Text(status));
          }).toList(),
          onChanged: (value) => selectedStatus = value ?? 'Active',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _assignmentService.bulkUpdateStatus(
                _selectedAssignments.map((a) => a.id).toList(),
                selectedStatus,
              );
              Navigator.pop(context);
              setState(() {
                _selectedAssignments.clear();
                _selectAll = false;
              });
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showBulkDiscountDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply Discount'),
        content: TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Discount Percentage',
            suffixText: '%',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final discount = double.tryParse(controller.text) ?? 0;
              if (discount >= 0 && discount <= 100) {
                await _assignmentService.bulkApplyDiscount(
                  _selectedAssignments.map((a) => a.id).toList(),
                  discount,
                );
                Navigator.pop(context);
                setState(() {
                  _selectedAssignments.clear();
                  _selectAll = false;
                });
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showBulkDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignments'),
        content: Text('Are you sure you want to delete ${_selectedAssignments.length} assignments?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              for (final assignment in _selectedAssignments) {
                await _assignmentService.deleteAssignment(assignment.id);
              }
              Navigator.pop(context);
              setState(() {
                _selectedAssignments.clear();
                _selectAll = false;
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
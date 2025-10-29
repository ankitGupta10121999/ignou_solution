import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assignment_model.dart';

class AssignmentService {
  final CollectionReference _assignmentRef = FirebaseFirestore.instance.collection(
    'assignments',
  );

  Stream<List<AssignmentModel>> getAssignments({
    String? subjectId,
    String? status,
    String? medium,
    String? session,
  }) {
    Query query = _assignmentRef;
    
    if (subjectId != null && subjectId.isNotEmpty) {
      query = query.where('subjectId', isEqualTo: subjectId);
    }
    
    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }
    
    if (medium != null && medium.isNotEmpty) {
      query = query.where('medium', isEqualTo: medium);
    }
    
    if (session != null && session.isNotEmpty) {
      query = query.where('session', isEqualTo: session);
    }
    
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => AssignmentModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    });
  }

  Stream<List<AssignmentModel>> getActiveAssignments() {
    return getAssignments(status: 'Active');
  }

  Stream<List<AssignmentModel>> getDraftAssignments() {
    return getAssignments(status: 'Draft');
  }

  Stream<List<AssignmentModel>> getAssignmentsBySubject(String subjectId) {
    return getAssignments(subjectId: subjectId);
  }

  Stream<List<AssignmentModel>> getAssignmentsBySession(String session) {
    return getAssignments(session: session);
  }

  Stream<List<AssignmentModel>> getCurrentSessionAssignments() {
    // This would need the session constants import
    // For now, return all assignments and filter client-side
    return getAssignments();
  }

  Future<void> addAssignment(AssignmentModel assignment) async {
    final now = DateTime.now();
    final assignmentData = assignment.copyWith(
      createdAt: now,
      updatedAt: now,
    );
    await _assignmentRef.add(assignmentData.toMap());
  }

  Future<void> updateAssignment(AssignmentModel assignment) async {
    final updatedAssignment = assignment.copyWith(
      updatedAt: DateTime.now(),
    );
    await _assignmentRef.doc(assignment.id).update(updatedAssignment.toMap());
  }

  Future<void> deleteAssignment(String id) async {
    await _assignmentRef.doc(id).delete();
  }

  Future<void> bulkUpdateStatus(List<String> assignmentIds, String status) async {
    final batch = FirebaseFirestore.instance.batch();
    
    for (String id in assignmentIds) {
      batch.update(_assignmentRef.doc(id), {
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }
    
    await batch.commit();
  }

  Future<void> bulkApplyDiscount(
    List<String> assignmentIds, 
    double discountPercentage,
  ) async {
    final batch = FirebaseFirestore.instance.batch();
    
    for (String id in assignmentIds) {
      batch.update(_assignmentRef.doc(id), {
        'discountPercentage': discountPercentage,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }
    
    await batch.commit();
  }

  Future<void> approveAssignment(String assignmentId, String approvedBy) async {
    await _assignmentRef.doc(assignmentId).update({
      'approvedBy': approvedBy,
      'approvedAt': DateTime.now().toIso8601String(),
      'status': 'Active',
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<AssignmentModel?> getAssignmentById(String id) async {
    final doc = await _assignmentRef.doc(id).get();
    if (doc.exists) {
      return AssignmentModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }
    return null;
  }

  Future<List<AssignmentModel>> searchAssignments(String searchTerm) async {
    final snapshot = await _assignmentRef
        .where('subjectName', isGreaterThanOrEqualTo: searchTerm)
        .where('subjectName', isLessThanOrEqualTo: '$searchTerm\uf8ff')
        .get();
    
    return snapshot.docs
        .map((doc) => AssignmentModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ))
        .toList();
  }

  Future<List<AssignmentModel>> getAssignmentsByTags(List<String> tags) async {
    final snapshot = await _assignmentRef
        .where('tags', arrayContainsAny: tags)
        .get();
    
    return snapshot.docs
        .map((doc) => AssignmentModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ))
        .toList();
  }

  Future<Map<String, int>> getAssignmentStats() async {
    final snapshot = await _assignmentRef.get();
    final assignments = snapshot.docs
        .map((doc) => AssignmentModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ))
        .toList();

    return {
      'total': assignments.length,
      'active': assignments.where((a) => a.status == 'Active').length,
      'draft': assignments.where((a) => a.status == 'Draft').length,
      'inactive': assignments.where((a) => a.status == 'Inactive').length,
      'withDiscount': assignments.where((a) => a.hasDiscount).length,
    };
  }

  Future<void> duplicateAssignment(String assignmentId) async {
    final original = await getAssignmentById(assignmentId);
    if (original != null) {
      final duplicate = original.copyWith(
        id: '',
        status: 'Draft',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        approvedBy: null,
        approvedAt: null,
      );
      await addAssignment(duplicate);
    }
  }

  Future<void> createTemplate(AssignmentModel assignment, String templateName) async {
    final templateData = assignment.toMap();
    templateData['templateName'] = templateName;
    templateData['isTemplate'] = true;
    templateData['createdAt'] = DateTime.now().toIso8601String();
    
    await FirebaseFirestore.instance
        .collection('assignment_templates')
        .add(templateData);
  }

  Stream<List<Map<String, dynamic>>> getTemplates() {
    return FirebaseFirestore.instance
        .collection('assignment_templates')
        .where('isTemplate', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    });
  }

  Future<AssignmentModel?> createFromTemplate(String templateId) async {
    final templateDoc = await FirebaseFirestore.instance
        .collection('assignment_templates')
        .doc(templateId)
        .get();
    
    if (templateDoc.exists) {
      final templateData = templateDoc.data() as Map<String, dynamic>;
      templateData.remove('templateName');
      templateData.remove('isTemplate');
      templateData['status'] = 'Draft';
      templateData['createdAt'] = DateTime.now().toIso8601String();
      templateData['updatedAt'] = DateTime.now().toIso8601String();
      
      return AssignmentModel.fromMap(templateData, '');
    }
    return null;
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ignousolutionhub/constants/firebase_collections.dart';
import '../models/department_model.dart';

class DepartmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createDepartment(DepartmentModel department) async {
    await _firestore
        .collection(FirebaseCollections.departments)
        .doc(department.id)
        .set(department.toMap());
  }

  Future<DepartmentModel?> getDepartmentById(String id) async {
    final doc = await _firestore
        .collection(FirebaseCollections.departments)
        .doc(id)
        .get();
    if (!doc.exists) return null;
    return DepartmentModel.fromMap(doc.data()!, doc.id);
  }

  Stream<List<DepartmentModel>> getAllDepartments() {
    return _firestore
        .collection(FirebaseCollections.departments)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DepartmentModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> updateDepartment(DepartmentModel department) async {
    await _firestore
        .collection(FirebaseCollections.departments)
        .doc(department.id)
        .update(department.toMap());
  }

  Future<void> deleteDepartment(String id) async {
    await _firestore
        .collection(FirebaseCollections.departments)
        .doc(id)
        .delete();
  }
}

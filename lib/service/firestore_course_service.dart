import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';

class FirestoreCourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createCourse(CourseModel courseModel) async {
    await _firestore.collection('courses').doc(courseModel.id).set({
      'id': courseModel.id,
      'name': courseModel.name,
      'programId': courseModel.programId,
      'createdAt': courseModel.createdAt,
      'updatedAt': courseModel.updateAt,
    });
  }

  Future<void> updateCourse(String id, CourseModel courseModel) async {
    await _firestore.collection('courses').doc(id).update({
      'name': courseModel.name,
      'programId': courseModel.programId,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> deleteCourse(String id) async {
    await _firestore.collection('courses').doc(id).delete();
  }

  Stream<QuerySnapshot> getCourses() {
    return _firestore
        .collection('courses')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<List<CourseModel>> getCourseList() {
    return _firestore
        .collection('courses')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CourseModel.fromMap(doc.data());
      }).toList();
    });
  }

}

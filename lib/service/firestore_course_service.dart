import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/commmon_utils.dart';

class FirestoreCourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createCourse(String name) async {
    final id = CommonUtils.generateUuid();
    final now = DateTime.now().millisecondsSinceEpoch;

    await _firestore.collection('courses').doc(id).set({
      'id': id,
      'name': name,
      'subjectIds': [],
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Future<void> updateCourse(String id, String name) async {
    await _firestore.collection('courses').doc(id).update({
      'name': name,
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

  Future<void> createSubject(String name, List<String> courseIds) async {
    final id = CommonUtils.generateUuid();
    final now = DateTime.now().millisecondsSinceEpoch;

    await _firestore.collection('subjects').doc(id).set({
      'id': id,
      'name': name,
      'courseIds': courseIds,
      'createdAt': now,
      'updatedAt': now,
    });

    for (var courseId in courseIds) {
      await _firestore.collection('courses').doc(courseId).update({
        'subjectIds': FieldValue.arrayUnion([id]),
      });
    }
  }

  Future<void> updateSubject(
    String id,
    String name,
    List<String> courseIds,
  ) async {
    await _firestore.collection('subjects').doc(id).update({
      'name': name,
      'courseIds': courseIds,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> deleteSubject(String id) async {
    final subjectRef = _firestore.collection('subjects').doc(id);
    final subjectDoc = await subjectRef.get();
    if (subjectDoc.exists) {
      final data = subjectDoc.data()!;
      final courseIds = List<String>.from(data['courseIds']);
      for (var courseId in courseIds) {
        await _firestore.collection('courses').doc(courseId).update({
          'subjectIds': FieldValue.arrayRemove([id]),
        });
      }
    }
    await subjectRef.delete();
  }

  Stream<QuerySnapshot> getSubjects() {
    return _firestore
        .collection('subjects')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}

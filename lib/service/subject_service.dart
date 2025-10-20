import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subject_model.dart';

class SubjectService {
  final CollectionReference _subjectRef = FirebaseFirestore.instance.collection(
    'subjects',
  );

  Stream<List<SubjectModel>> getSubjects() {
    return _subjectRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => SubjectModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    });
  }

  Future<void> addSubject(SubjectModel subject) async {
    await _subjectRef.add(subject.toMap());
  }

  Future<void> updateSubject(SubjectModel subject) async {
    await _subjectRef.doc(subject.id).update(subject.toMap());
  }

  Future<void> deleteSubject(String id) async {
    await _subjectRef.doc(id).delete();
  }
}

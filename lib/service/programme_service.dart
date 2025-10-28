import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firebase_collections.dart';
import '../models/programme_model.dart';

class ProgrammeService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> addProgramme(ProgrammeModel programme) async {
    await _firestore
        .collection(FirebaseCollections.programmes)
        .doc(programme.id)
        .set(programme.toMap());
  }

  Future<void> updateProgramme(ProgrammeModel programme) async {
    await _firestore
        .collection(FirebaseCollections.programmes)
        .doc(programme.id)
        .update(programme.toMap());
  }

  Future<void> deleteProgramme(String id) async {
    await _firestore
        .collection(FirebaseCollections.programmes)
        .doc(id)
        .delete();
  }

  Stream<List<ProgrammeModel>> getProgrammesStream() {
    return _firestore
        .collection(FirebaseCollections.programmes)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProgrammeModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Stream<ProgrammeModel?> getProgrammeById(String id) {
    return  FirebaseFirestore.instance
        .collection(FirebaseCollections.programmes)
        .doc(id)
        .snapshots()
        .map(
          (doc) => doc.exists ? ProgrammeModel.fromMap(doc.data()!, id) : null,
        );
  }
}

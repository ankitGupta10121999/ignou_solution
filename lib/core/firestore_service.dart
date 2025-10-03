import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ignousolutionhub/constants/firebase_collections.dart';
import 'package:ignousolutionhub/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addUser(UserModel user) {
    return _db
        .collection(FirebaseCollections.users)
        .doc(user.uid)
        .set(user.toMap());
  }

  Future<UserModel?> getUserFromCache(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_$uid');
    if (userJson != null) {
      return UserModel.fromMap(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> saveUserToCache(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_${user.uid}', jsonEncode(user.toMap()));
  }

  Future<UserModel> getUser(String uid) async {
    final user = await _db
        .collection(FirebaseCollections.users)
        .doc(uid)
        .get()
        .then((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>));
    return user;
  }

  Stream<List<UserModel>> getAllUsers() {
    return _db
        .collection(FirebaseCollections.users)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<String?> getUserRole(String uid) async {
    final user = await _db
        .collection(FirebaseCollections.users)
        .doc(uid)
        .get()
        .then((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>));
    return user.role;
  }

  Future<void> deleteUser(String userId) {

    return _db
        .collection(FirebaseCollections.users)
        .doc(userId)
        .delete();
  }
}

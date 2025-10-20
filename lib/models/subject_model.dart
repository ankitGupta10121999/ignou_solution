import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectModel {
  final String id;
  final String name;
  final String code;
  final List<String> courseIds;

  SubjectModel({
    required this.id,
    required this.name,
    required this.code,
    required this.courseIds,
  });

  factory SubjectModel.fromMap(Map<String, dynamic> map, String id) {
    return SubjectModel(
      id: id,
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      courseIds: List<String>.from(map['courseIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'courseIds': courseIds,
    };
  }
}

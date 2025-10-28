class CourseModel {
  final String id;
  final String name;
  final String? programId;
  final int? createdAt;
  final int updateAt;

  CourseModel({
    required this.id,
    required this.name,
    this.programId,
    this.createdAt,
    required this.updateAt,
  });

  factory CourseModel.fromMap(Map<String, dynamic> data) {
    return CourseModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      programId: data['programId'] ?? '',
      createdAt: data['createdAt'] ?? 0,
      updateAt: data['updateAt'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'programId': programId,
      'createdAt': createdAt,
      'updatedAt': updateAt,
    };
  }
}

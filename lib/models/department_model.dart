class DepartmentModel {
  final String id;
  final String name;
  final String code;
  final List<String>? courseIds;
  final int createdAt;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.code,
    this.courseIds,
    required this.createdAt
  });

  factory DepartmentModel.fromMap(Map<String, dynamic> map, String id) {
    return DepartmentModel(
      id: id,
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      courseIds: List<String>.from(map['courseIds'] ?? []),
      createdAt: map['createdAt']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'name': name,
      'code': code,
      'courseIds': courseIds,
      'createdAt' : createdAt
    };
  }
}
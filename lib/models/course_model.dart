class CourseModel {
  final String id;
  final String name;

  CourseModel({
    required this.id,
    required this.name,
  });

  factory CourseModel.fromMap(Map<String, dynamic> data) {
    return CourseModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
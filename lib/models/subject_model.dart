class SubjectModel {
  final String id;
  final String name;
  final String code;
  final List<String> courseIds;
  final List<String> availableMediums;

  SubjectModel({
    required this.id,
    required this.name,
    required this.code,
    required this.courseIds,
    this.availableMediums = const ['English', 'Hindi'],
  });

  factory SubjectModel.fromMap(Map<String, dynamic> map, String id) {
    return SubjectModel(
      id: id,
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      courseIds: List<String>.from(map['courseIds'] ?? []),
      availableMediums: List<String>.from(map['availableMediums'] ?? ['English', 'Hindi']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'courseIds': courseIds,
      'availableMediums': availableMediums,
    };
  }
}

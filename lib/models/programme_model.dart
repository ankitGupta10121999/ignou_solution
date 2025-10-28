class ProgrammeModel {
  final String id;
  final String name;
  final String? description;

  ProgrammeModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory ProgrammeModel.fromMap(Map<String, dynamic> map, String id) {
    return ProgrammeModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'name': name,
      'description': description,
    };
  }
}
class AssignmentModel {
  final String id;
  final String subjectId;
  final String subjectName;
  final String medium;
  final String session;
  final double pdfPrice;
  final double handwrittenPrice;
  final double discountPercentage;
  final String description;
  final String difficulty;
  final String status;
  final DateTime? dueDate;
  final List<String> tags;
  final String? templateId;
  final bool requiresApproval;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  AssignmentModel({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.medium,
    required this.session,
    required this.pdfPrice,
    required this.handwrittenPrice,
    this.discountPercentage = 0.0,
    this.description = '',
    this.difficulty = 'Medium',
    this.status = 'Active',
    this.dueDate,
    this.tags = const [],
    this.templateId,
    this.requiresApproval = false,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  double get discountedPdfPrice {
    if (discountPercentage <= 0) return pdfPrice;
    return pdfPrice * (1 - discountPercentage / 100);
  }

  double get discountedHandwrittenPrice {
    if (discountPercentage <= 0) return handwrittenPrice;
    return handwrittenPrice * (1 - discountPercentage / 100);
  }

  double get pdfSavings => pdfPrice - discountedPdfPrice;
  double get handwrittenSavings => handwrittenPrice - discountedHandwrittenPrice;

  bool get hasDiscount => discountPercentage > 0;
  bool get isActive => status == 'Active';
  bool get isDraft => status == 'Draft';
  bool get isApproved => approvedBy != null && approvedAt != null;

  factory AssignmentModel.fromMap(Map<String, dynamic> map, String id) {
    return AssignmentModel(
      id: id,
      subjectId: map['subjectId'] ?? '',
      subjectName: map['subjectName'] ?? '',
      medium: map['medium'] ?? '',
      session: map['session'] ?? '',
      pdfPrice: (map['pdfPrice'] ?? 0.0).toDouble(),
      handwrittenPrice: (map['handwrittenPrice'] ?? 0.0).toDouble(),
      discountPercentage: (map['discountPercentage'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      difficulty: map['difficulty'] ?? 'Medium',
      status: map['status'] ?? 'Active',
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      tags: List<String>.from(map['tags'] ?? []),
      templateId: map['templateId'],
      requiresApproval: map['requiresApproval'] ?? false,
      approvedBy: map['approvedBy'],
      approvedAt: map['approvedAt'] != null ? DateTime.parse(map['approvedAt']) : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subjectId': subjectId,
      'subjectName': subjectName,
      'medium': medium,
      'session': session,
      'pdfPrice': pdfPrice,
      'handwrittenPrice': handwrittenPrice,
      'discountPercentage': discountPercentage,
      'description': description,
      'difficulty': difficulty,
      'status': status,
      'dueDate': dueDate?.toIso8601String(),
      'tags': tags,
      'templateId': templateId,
      'requiresApproval': requiresApproval,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  AssignmentModel copyWith({
    String? id,
    String? subjectId,
    String? subjectName,
    String? medium,
    String? session,
    double? pdfPrice,
    double? handwrittenPrice,
    double? discountPercentage,
    String? description,
    String? difficulty,
    String? status,
    DateTime? dueDate,
    List<String>? tags,
    String? templateId,
    bool? requiresApproval,
    String? approvedBy,
    DateTime? approvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      medium: medium ?? this.medium,
      session: session ?? this.session,
      pdfPrice: pdfPrice ?? this.pdfPrice,
      handwrittenPrice: handwrittenPrice ?? this.handwrittenPrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      tags: tags ?? this.tags,
      templateId: templateId ?? this.templateId,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
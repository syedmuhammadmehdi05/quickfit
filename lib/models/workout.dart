class Workout {
  final String id;
  final String coachId;
  final String studentId;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isCompleted;
  final String? studentNotes;
  final DateTime? completedAt;

  Workout({
    required this.id,
    required this.coachId,
    required this.studentId,
    required this.title,
    required this.description,
    required this.createdAt,
    this.isCompleted = false,
    this.studentNotes,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coachId': coachId,
      'studentId': studentId,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'studentNotes': studentNotes,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] ?? '',
      coachId: json['coachId'] ?? '',
      studentId: json['studentId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      isCompleted: json['isCompleted'] ?? false,
      studentNotes: json['studentNotes'],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  Workout copyWith({
    String? id,
    String? coachId,
    String? studentId,
    String? title,
    String? description,
    DateTime? createdAt,
    bool? isCompleted,
    String? studentNotes,
    DateTime? completedAt,
  }) {
    return Workout(
      id: id ?? this.id,
      coachId: coachId ?? this.coachId,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      studentNotes: studentNotes ?? this.studentNotes,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String createdByCoachId;
  final List<ChallengeParticipant> participants;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.createdByCoachId,
    this.participants = const [],
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get isUpcoming => DateTime.now().isBefore(startDate);
  bool get isEnded => DateTime.now().isAfter(endDate);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'createdByCoachId': createdByCoachId,
        'participants': participants.map((p) => p.toJson()).toList(),
      };

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        createdByCoachId: json['createdByCoachId'] ?? '',
        participants: (json['participants'] as List<dynamic>? ?? [])
            .map((p) => ChallengeParticipant.fromJson(p))
            .toList(),
      );

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? createdByCoachId,
    List<ChallengeParticipant>? participants,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdByCoachId: createdByCoachId ?? this.createdByCoachId,
      participants: participants ?? this.participants,
    );
  }
}

class ChallengeParticipant {
  final String userId;
  final String userName;
  final int score;
  final bool isWinner;

  ChallengeParticipant({
    required this.userId,
    required this.userName,
    this.score = 0,
    this.isWinner = false,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userName': userName,
        'score': score,
        'isWinner': isWinner,
      };

  factory ChallengeParticipant.fromJson(Map<String, dynamic> json) =>
      ChallengeParticipant(
        userId: json['userId'] ?? '',
        userName: json['userName'] ?? '',
        score: json['score'] ?? 0,
        isWinner: json['isWinner'] ?? false,
      );

  ChallengeParticipant copyWith({
    String? userId,
    String? userName,
    int? score,
    bool? isWinner,
  }) {
    return ChallengeParticipant(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      score: score ?? this.score,
      isWinner: isWinner ?? this.isWinner,
    );
  }
}

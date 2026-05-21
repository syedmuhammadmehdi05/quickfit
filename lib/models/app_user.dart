enum UserRole { student, coach }

class AppUser {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? profileImageUrl;
  final String? employeeId;   // coaches only
  final String? coachId;      // students only — UID of their chosen coach

  final StudentStats? studentStats;
  final CoachStats? coachStats;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.profileImageUrl,
    this.employeeId,
    this.coachId,
    this.studentStats,
    this.coachStats,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role.name,
      'profileImageUrl': profileImageUrl,
      'employeeId': employeeId,
      'coachId': coachId,
      'studentStats': studentStats?.toJson(),
      'coachStats': coachStats?.toJson(),
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] == 'coach' ? UserRole.coach : UserRole.student,
      profileImageUrl: json['profileImageUrl'],
      employeeId: json['employeeId'],
      coachId: json['coachId'],
      studentStats: json['studentStats'] != null
          ? StudentStats.fromJson(json['studentStats'])
          : null,
      coachStats: json['coachStats'] != null
          ? CoachStats.fromJson(json['coachStats'])
          : null,
    );
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? name,
    UserRole? role,
    String? profileImageUrl,
    String? employeeId,
    String? coachId,
    StudentStats? studentStats,
    CoachStats? coachStats,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      employeeId: employeeId ?? this.employeeId,
      coachId: coachId ?? this.coachId,
      studentStats: studentStats ?? this.studentStats,
      coachStats: coachStats ?? this.coachStats,
    );
  }
}

class StudentStats {
  final int workoutsCompleted;
  final int challengesJoined;
  final int challengesWon;
  final double weeklyCompletionRate;

  StudentStats({
    this.workoutsCompleted = 0,
    this.challengesJoined = 0,
    this.challengesWon = 0,
    this.weeklyCompletionRate = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'workoutsCompleted': workoutsCompleted,
        'challengesJoined': challengesJoined,
        'challengesWon': challengesWon,
        'weeklyCompletionRate': weeklyCompletionRate,
      };

  factory StudentStats.fromJson(Map<String, dynamic> json) => StudentStats(
        workoutsCompleted: json['workoutsCompleted'] ?? 0,
        challengesJoined: json['challengesJoined'] ?? 0,
        challengesWon: json['challengesWon'] ?? 0,
        weeklyCompletionRate:
            (json['weeklyCompletionRate'] ?? 0).toDouble(),
      );
}

class CoachStats {
  final int totalStudentsTrained;
  final double rating;
  final int totalWorkoutsCreated;

  CoachStats({
    this.totalStudentsTrained = 0,
    this.rating = 0.0,
    this.totalWorkoutsCreated = 0,
  });

  Map<String, dynamic> toJson() => {
        'totalStudentsTrained': totalStudentsTrained,
        'rating': rating,
        'totalWorkoutsCreated': totalWorkoutsCreated,
      };

  factory CoachStats.fromJson(Map<String, dynamic> json) => CoachStats(
        totalStudentsTrained: json['totalStudentsTrained'] ?? 0,
        rating: (json['rating'] ?? 0).toDouble(),
        totalWorkoutsCreated: json['totalWorkoutsCreated'] ?? 0,
      );
}

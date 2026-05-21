import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// All students in the platform (used for coach to browse/assign)
  Stream<List<AppUser>> getAllStudents() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'student')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AppUser.fromJson(d.data()))
            .toList());
  }

  /// Only students who chose this coach
  Stream<List<AppUser>> studentsForCoach(String coachId) {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'student')
        .where('coachId', isEqualTo: coachId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AppUser.fromJson(d.data()))
            .toList());
  }

  /// All registered coaches — forced server fetch, never reads from local cache
  Future<List<AppUser>> getAllCoaches() async {
    final snap = await _db
        .collection('users')
        .where('role', isEqualTo: 'coach')
        .get(const GetOptions(source: Source.server));
    return snap.docs.map((d) => AppUser.fromJson(d.data())).toList();
  }

  Future<AppUser?> getUserById(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromJson(doc.data()!);
  }

  Future<List<AppUser>> getStudentsForCoach(String coachId) async {
    final workouts = await _db
        .collection('workouts')
        .where('coachId', isEqualTo: coachId)
        .get();

    final studentIds =
        workouts.docs.map((d) => d['studentId'] as String).toSet().toList();

    if (studentIds.isEmpty) return [];

    final users = await Future.wait(
        studentIds.map((id) => getUserById(id)));
    return users.whereType<AppUser>().toList();
  }
}

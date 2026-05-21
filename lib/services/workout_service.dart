import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/workout.dart';

class WorkoutService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  CollectionReference get _col => _db.collection('workouts');

  Future<Workout> createWorkout({
    required String coachId,
    required String studentId,
    required String title,
    required String description,
  }) async {
    final id = _uuid.v4();
    final workout = Workout(
      id: id,
      coachId: coachId,
      studentId: studentId,
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );
    await _col.doc(id).set(workout.toJson());

    // Increment coach's totalWorkoutsCreated
    await _db.collection('users').doc(coachId).update({
      'coachStats.totalWorkoutsCreated':
          FieldValue.increment(1),
    });

    return workout;
  }

  Stream<List<Workout>> studentWorkouts(String studentId) {
    return _col
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Workout.fromJson(d.data() as Map<String, dynamic>)).toList());
  }

  Stream<List<Workout>> coachWorkouts(String coachId) {
    return _col
        .where('coachId', isEqualTo: coachId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Workout.fromJson(d.data() as Map<String, dynamic>)).toList());
  }

  Stream<List<Workout>> workoutsForStudent({
    required String coachId,
    required String studentId,
  }) {
    return _col
        .where('coachId', isEqualTo: coachId)
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Workout.fromJson(d.data() as Map<String, dynamic>)).toList());
  }

  Future<void> completeWorkout(
      String workoutId, String studentId, String? notes) async {
    await _col.doc(workoutId).update({
      'isCompleted': true,
      'completedAt': DateTime.now().toIso8601String(),
      'studentNotes': notes,
    });

    // Increment student workoutsCompleted
    await _db.collection('users').doc(studentId).update({
      'studentStats.workoutsCompleted': FieldValue.increment(1),
    });

    // Recalculate weekly completion rate
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final snap = await _col
        .where('studentId', isEqualTo: studentId)
        .where('createdAt',
            isGreaterThanOrEqualTo: weekAgo.toIso8601String())
        .get();
    final all = snap.docs.length;
    final done = snap.docs
        .where((d) => (d.data() as Map<String, dynamic>)['isCompleted'] == true)
        .length;
    final rate = all > 0 ? (done / all) : 0.0;
    await _db.collection('users').doc(studentId).update({
      'studentStats.weeklyCompletionRate': rate,
    });
  }

  Future<void> deleteWorkout(String workoutId) async {
    await _col.doc(workoutId).delete();
  }
}

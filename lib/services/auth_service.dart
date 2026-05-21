import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await getUser(user.uid);
  }

  Future<AppUser?> getUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? employeeId,
    String? coachId,
  }) async {
    // ── Coach gate: validate Employee ID against Firestore ──────────────
    if (role == UserRole.coach) {
      if (employeeId == null || employeeId.trim().isEmpty) {
        throw Exception('Employee ID is required for coaches.');
      }
      final code = employeeId.trim().toUpperCase();
      final codeDoc =
          await _db.collection('employee_codes').doc(code).get();
      if (!codeDoc.exists) {
        throw Exception(
            'invalid-employee-id: This Employee ID is not registered.');
      }
      if (codeDoc.data()?['used'] == true) {
        throw Exception(
            'employee-id-used: This Employee ID has already been used.');
      }
    }

    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = AppUser(
      uid: cred.user!.uid,
      email: email,
      name: name,
      role: role,
      employeeId:
          role == UserRole.coach ? employeeId?.trim().toUpperCase() : null,
      coachId: role == UserRole.student ? coachId : null,
      studentStats: role == UserRole.student ? StudentStats() : null,
      coachStats: role == UserRole.coach ? CoachStats() : null,
    );

    await _db.collection('users').doc(user.uid).set(user.toJson());

    // Mark the employee code as used so it cannot be reused
    if (role == UserRole.coach && employeeId != null) {
      await _db
          .collection('employee_codes')
          .doc(employeeId.trim().toUpperCase())
          .update({'used': true});
    }

    return user;
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = await getUser(cred.user!.uid);
    if (user == null) throw Exception('User profile not found.');
    return user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updateStudentStats(String uid, StudentStats stats) async {
    await _db.collection('users').doc(uid).update({
      'studentStats': stats.toJson(),
    });
  }

  Future<void> updateCoachStats(String uid, CoachStats stats) async {
    await _db.collection('users').doc(uid).update({
      'coachStats': stats.toJson(),
    });
  }
}

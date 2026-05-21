import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/challenge.dart';

class ChallengeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  CollectionReference get _col => _db.collection('challenges');

  Future<Challenge> createChallenge({
    required String coachId,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final id = _uuid.v4();
    final challenge = Challenge(
      id: id,
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      createdByCoachId: coachId,
    );
    await _col.doc(id).set(challenge.toJson());
    return challenge;
  }

  Stream<List<Challenge>> allChallenges() {
    return _col
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Challenge.fromJson(d.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<Challenge>> coachChallenges(String coachId) {
    return _col
        .where('createdByCoachId', isEqualTo: coachId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Challenge.fromJson(d.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> joinChallenge(
      String challengeId, String userId, String userName) async {
    final doc = await _col.doc(challengeId).get();
    final challenge =
        Challenge.fromJson(doc.data() as Map<String, dynamic>);

    final alreadyJoined =
        challenge.participants.any((p) => p.userId == userId);
    if (alreadyJoined) return;

    final newParticipant = ChallengeParticipant(
      userId: userId,
      userName: userName,
    );

    final updated = challenge.copyWith(
      participants: [...challenge.participants, newParticipant],
    );
    await _col.doc(challengeId).update({'participants': updated.participants.map((p) => p.toJson()).toList()});

    // Update student stats
    await _db.collection('users').doc(userId).update({
      'studentStats.challengesJoined': FieldValue.increment(1),
    });
  }

  Future<void> addScore(
      String challengeId, String userId, int points) async {
    final doc = await _col.doc(challengeId).get();
    final challenge =
        Challenge.fromJson(doc.data() as Map<String, dynamic>);

    final updatedParticipants = challenge.participants.map((p) {
      if (p.userId == userId) {
        return p.copyWith(score: p.score + points);
      }
      return p;
    }).toList();

    await _col.doc(challengeId).update({
      'participants':
          updatedParticipants.map((p) => p.toJson()).toList(),
    });
  }

  Future<void> finalizeChallenge(String challengeId) async {
    final doc = await _col.doc(challengeId).get();
    final challenge =
        Challenge.fromJson(doc.data() as Map<String, dynamic>);

    if (challenge.participants.isEmpty) return;

    final sorted = [...challenge.participants]
      ..sort((a, b) => b.score.compareTo(a.score));

    final winnerId = sorted.first.userId;
    final updatedParticipants = challenge.participants.map((p) {
      return p.copyWith(isWinner: p.userId == winnerId);
    }).toList();

    await _col.doc(challengeId).update({
      'participants':
          updatedParticipants.map((p) => p.toJson()).toList(),
    });

    // Update winner's stats
    await _db.collection('users').doc(winnerId).update({
      'studentStats.challengesWon': FieldValue.increment(1),
    });
  }

  Future<void> deleteChallenge(String challengeId) async {
    await _col.doc(challengeId).delete();
  }
}

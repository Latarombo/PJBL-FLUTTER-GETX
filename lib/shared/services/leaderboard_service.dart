import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:santarana/shared/models/leaderboard_model.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<LeaderboardModel>> leaderboardStream() {
    return _firestore
        .collection('leaderboard')
        .orderBy('totalPoints', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          final entries = snapshot.docs
              .map(LeaderboardModel.fromFirestore)
              .toList();
          return List.generate(
            entries.length,
            (i) => entries[i].copyWith(rank: i + 1),
          );
        });
  }

  Future<void> updateLeaderboardEntry(
    String uid,
    String username,
    int totalPoints, {
    String? avatarUrl,
  }) async {
    try {
      await _firestore.collection('leaderboard').doc(uid).set({
        'uid': uid,
        'username': username,
        'avatarUrl': avatarUrl,
        'totalPoints': totalPoints,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Gagal update leaderboard: $e');
    }
  }
}

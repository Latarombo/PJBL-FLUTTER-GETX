import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardModel {
  final String uid;
  final String username;
  final String? avatarUrl;
  final int totalPoints;
  final int rank;
  final DateTime? lastUpdated;

  const LeaderboardModel({
    required this.uid,
    required this.username,
    this.avatarUrl,
    required this.totalPoints,
    this.rank = 0,
    this.lastUpdated,
  });

  factory LeaderboardModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaderboardModel(
      uid: data['uid'] ?? doc.id,
      username: data['username'] ?? '',
      avatarUrl: data['avatarUrl'],
      totalPoints: data['totalPoints'] ?? 0,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'uid': uid,
    'username': username,
    'avatarUrl': avatarUrl,
    'totalPoints': totalPoints,
    'lastUpdated': FieldValue.serverTimestamp(),
  };

  LeaderboardModel copyWith({int? rank}) => LeaderboardModel(
    uid: uid,
    username: username,
    avatarUrl: avatarUrl,
    totalPoints: totalPoints,
    rank: rank ?? this.rank,
    lastUpdated: lastUpdated,
  );
}

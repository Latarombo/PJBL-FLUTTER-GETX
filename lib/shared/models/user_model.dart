import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String role;
  final String? avatarUrl;
  final int totalPoints;
  final int rank;
  final double correctRate;
  final int quizCompleted;
  final int streak;
  final DateTime? lastActiveAt;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.role = 'user',
    this.avatarUrl,
    this.totalPoints = 0,
    this.rank = 0,
    this.correctRate = 0.0,
    this.quizCompleted = 0,
    this.streak = 0,
    this.lastActiveAt,
    this.createdAt,
  });

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};

    return UserModel(
      uid: (data['uid'] as String?) ?? snapshot.id,
      username: (data['username'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      role: (data['role'] as String?) ?? 'user',
      avatarUrl: data['avatarUrl'] as String?,
      totalPoints: (data['totalPoints'] as num?)?.toInt() ?? 0,
      rank: (data['rank'] as num?)?.toInt() ?? 0,
      correctRate: (data['correctRate'] as num?)?.toDouble() ?? 0.0,
      quizCompleted: (data['quizCompleted'] as num?)?.toInt() ?? 0,
      streak: (data['streak'] as num?)?.toInt() ?? 0,
      lastActiveAt: _dateTimeFromFirestore(data['lastActiveAt']),
      createdAt: _dateTimeFromFirestore(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'role': role,
      'avatarUrl': avatarUrl,
      'totalPoints': totalPoints,
      'rank': rank,
      'correctRate': correctRate,
      'quizCompleted': quizCompleted,
      'streak': streak,
      'lastActiveAt': _timestampFromDateTime(lastActiveAt),
      'createdAt': _timestampFromDateTime(createdAt),
    };
  }

  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? role,
    String? avatarUrl,
    int? totalPoints,
    int? rank,
    double? correctRate,
    int? quizCompleted,
    int? streak,
    DateTime? lastActiveAt,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalPoints: totalPoints ?? this.totalPoints,
      rank: rank ?? this.rank,
      correctRate: correctRate ?? this.correctRate,
      quizCompleted: quizCompleted ?? this.quizCompleted,
      streak: streak ?? this.streak,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime? _dateTimeFromFirestore(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static Timestamp? _timestampFromDateTime(DateTime? value) {
    if (value == null) return null;
    return Timestamp.fromDate(value);
  }
}

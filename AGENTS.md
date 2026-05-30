# Backend Plan — Misi Eksplor Harian
> Santarana Quiz · Firestore + Flutter/GetX

---

## Daftar Isi

1. [Ringkasan Keputusan Desain](#1-ringkasan-keputusan-desain)
2. [Struktur Collection Firestore](#2-struktur-collection-firestore)
3. [Aturan Unlock & Expire](#3-aturan-unlock--expire)
4. [Model Dart](#4-model-dart)
5. [Service Dart](#5-service-dart)
6. [Controller Dart](#6-controller-dart)
7. [Update UI — HomeView & KategoriKuisView](#7-update-ui--homeview--kategorikuisview)
8. [Seed Data Firestore (Admin)](#8-seed-data-firestore-admin)
9. [Urutan Eksekusi Penulisan Kode](#9-urutan-eksekusi-penulisan-kode)
10. [Checklist QA](#10-checklist-qa)

---

## 1. Ringkasan Keputusan Desain

| Keputusan | Pilihan | Alasan |
|---|---|---|
| Generate misi | Campuran: template admin + unlock otomatis | Admin kontrol konten, app kontrol waktu |
| Relasi dengan quiz | Misi = challenge khusus (bukan kategori biasa) | Konten berbeda, tidak menimpa flow quiz existing |
| Progress tracking | Global (semua user lihat misi sama) + per-user streak/badge | Hemat read Firestore, streak tetap individual |
| Reset waktu | Setiap 00:00 WIB | Konsisten, mudah di-debug |
| Logika unlock/expire | Client-side (`DateTime.now()` vs `unlock_at`/`expires_at`) | Tidak butuh Cloud Function, lebih murah |
| Expire rule | `expires_at` misi N = `unlock_at` misi N+1; misi ke-7 = 00:00 hari berikutnya | Sesuai permintaan |
| Reward | Poin per misi + badge jika streak 7 hari tanpa skip | Badge masuk ke `users/{uid}` medals |

---

## 2. Struktur Collection Firestore

### 2.1 `daily_mission_templates`
> Dibuat admin sekali. Tidak pernah dihapus/reset.

```
daily_mission_templates/{templateId}
├── title            : String       // "Misi Nusantara #1"
├── description      : String       // Deskripsi singkat challenge
├── difficulty       : String       // "Mudah" | "Sedang" | "Sulit" | "Sangat Sulit"
├── mission_number   : int          // 1–7 (7 = misi spesial)
├── unlock_hour      : int          // jam unlock WIB (0–23), contoh: 0,4,8,12,16,20,22
├── reward_points    : int          // poin yang didapat jika selesai
├── is_special       : bool         // true hanya untuk misi ke-7
├── is_active        : bool         // false = tidak masuk ke daily_missions
├── image_path       : String?      // opsional, asset path gambar kartu
└── created_at       : Timestamp
```

**Contoh dokumen (misi ke-3):**
```json
{
  "title": "Tebak Senjata Tradisional",
  "description": "Jawab 5 soal tentang senjata adat nusantara",
  "difficulty": "Sedang",
  "mission_number": 3,
  "unlock_hour": 8,
  "reward_points": 200,
  "is_special": false,
  "is_active": true,
  "image_path": "assets/images/senjata_adat_tradisional.png",
  "created_at": "2025-01-01T00:00:00Z"
}
```

---

### 2.2 `daily_missions`
> Satu dokumen per hari. Doc ID = tanggal (`yyyy-MM-dd`).  
> Dibuat otomatis oleh `DailyMissionService.generateDailyMissions()` saat app pertama kali dibuka hari itu.

```
daily_missions/{yyyy-MM-dd}
├── date             : String       // "2025-01-21"
├── reset_at         : Timestamp    // 00:00 WIB hari ini
├── next_reset_at    : Timestamp    // 00:00 WIB hari berikutnya
├── completed_count  : int          // berapa user yang selesai semua 7 misi (opsional, untuk statistik)
└── missions         : List<Map>    // 7 slot misi
    └── [
          {
            "template_id"  : String,    // ref ke daily_mission_templates
            "mission_number": int,
            "title"        : String,    // di-copy dari template saat generate
            "description"  : String,
            "difficulty"   : String,
            "reward_points": int,
            "is_special"   : bool,
            "image_path"   : String?,
            "unlock_at"    : Timestamp, // tanggal hari ini + unlock_hour
            "expires_at"   : Timestamp  // = unlock_at misi berikutnya; misi ke-7 = next_reset_at
          },
          ...
        ]
```

---

### 2.3 `user_mission_streaks`
> Satu dokumen per user. Doc ID = `uid`.  
> Update setiap kali user menyelesaikan semua 7 misi dalam satu hari.

```
user_mission_streaks/{uid}
├── uid                   : String
├── current_streak        : int          // hari berturut-turut selesai semua 7 misi
├── longest_streak        : int          // rekor terpanjang
├── last_completed_date   : String       // "2025-01-21" — tanggal terakhir selesai 7/7
├── badge_earned          : bool         // true jika pernah mencapai streak 7
├── badge_earned_at       : Timestamp?   // kapan pertama kali dapat badge
├── total_missions_done   : int          // total akumulasi misi yang diselesaikan
└── daily_completions     : Map<String, int>
                            // key: "yyyy-MM-dd", value: jumlah misi selesai hari itu
                            // contoh: {"2025-01-21": 7, "2025-01-20": 5}
```

---

### 2.4 `user_mission_completions`
> Satu dokumen per user per hari. Doc ID = `{uid}_{yyyy-MM-dd}`.  
> Menyimpan misi mana yang sudah diselesaikan user hari ini.

```
user_mission_completions/{uid}_{yyyy-MM-dd}
├── uid                  : String
├── date                 : String        // "2025-01-21"
├── completed_missions   : List<int>     // [1, 2, 3] — nomor misi yang sudah selesai
├── points_earned_today  : int           // akumulasi poin dari misi hari ini
├── all_7_completed      : bool          // true jika List berisi [1,2,3,4,5,6,7]
└── last_updated_at      : Timestamp
```

---

## 3. Aturan Unlock & Expire

### Contoh jadwal unlock (bisa diubah admin via `unlock_hour`):

| Misi | `unlock_hour` | Unlock at | Expires at |
|------|--------------|-----------|------------|
| 1 | 0 | 00:00 | 04:00 |
| 2 | 4 | 04:00 | 08:00 |
| 3 | 8 | 08:00 | 12:00 |
| 4 | 12 | 12:00 | 16:00 |
| 5 | 16 | 16:00 | 20:00 |
| 6 | 20 | 20:00 | 22:00 |
| 7 (spesial) | 22 | 22:00 | 00:00 (besok) |

### Logika status misi (client-side, computed):

```dart
MissionStatus computeStatus({
  required DateTime now,
  required DateTime unlockAt,
  required DateTime expiresAt,
  required bool isCompleted,
}) {
  if (isCompleted) return MissionStatus.completed;
  if (now.isBefore(unlockAt)) return MissionStatus.locked;
  if (now.isAfter(expiresAt)) return MissionStatus.expired;
  return MissionStatus.inProgress; // unlock & belum selesai & belum expire
}
```

### Aturan streak:
- Streak +1 jika `all_7_completed = true` pada hari ini DAN `last_completed_date` = kemarin
- Streak reset ke 0 jika ada hari yang di-skip (last_completed_date bukan kemarin)
- Badge diberikan saat `current_streak` mencapai 7 untuk pertama kalinya (`badge_earned = false` → `true`)

---

## 4. Model Dart

### File: `lib/shared/models/mission_template_model.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MissionTemplateModel {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final int missionNumber;
  final int unlockHour;      // jam WIB (0–23)
  final int rewardPoints;
  final bool isSpecial;
  final bool isActive;
  final String? imagePath;
  final DateTime? createdAt;

  const MissionTemplateModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.missionNumber,
    required this.unlockHour,
    required this.rewardPoints,
    required this.isSpecial,
    required this.isActive,
    this.imagePath,
    this.createdAt,
  });

  factory MissionTemplateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MissionTemplateModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      difficulty: data['difficulty'] ?? 'Mudah',
      missionNumber: (data['mission_number'] as num?)?.toInt() ?? 1,
      unlockHour: (data['unlock_hour'] as num?)?.toInt() ?? 0,
      rewardPoints: (data['reward_points'] as num?)?.toInt() ?? 10,
      isSpecial: data['is_special'] ?? false,
      isActive: data['is_active'] ?? true,
      imagePath: data['image_path'] as String?,
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'description': description,
    'difficulty': difficulty,
    'mission_number': missionNumber,
    'unlock_hour': unlockHour,
    'reward_points': rewardPoints,
    'is_special': isSpecial,
    'is_active': isActive,
    'image_path': imagePath,
    'created_at': FieldValue.serverTimestamp(),
  };
}
```

---

### File: `lib/shared/models/daily_mission_model.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

// ── Status computed client-side ──────────────────────────────────────────────
enum DailyMissionStatus { locked, inProgress, completed, expired }

// ── Satu slot misi dalam dokumen daily_missions ───────────────────────────────
class MissionSlot {
  final String templateId;
  final int missionNumber;
  final String title;
  final String description;
  final String difficulty;
  final int rewardPoints;
  final bool isSpecial;
  final String? imagePath;
  final DateTime unlockAt;
  final DateTime expiresAt;

  const MissionSlot({
    required this.templateId,
    required this.missionNumber,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.rewardPoints,
    required this.isSpecial,
    this.imagePath,
    required this.unlockAt,
    required this.expiresAt,
  });

  factory MissionSlot.fromMap(Map<String, dynamic> data) {
    return MissionSlot(
      templateId: data['template_id'] ?? '',
      missionNumber: (data['mission_number'] as num?)?.toInt() ?? 1,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      difficulty: data['difficulty'] ?? 'Mudah',
      rewardPoints: (data['reward_points'] as num?)?.toInt() ?? 10,
      isSpecial: data['is_special'] ?? false,
      imagePath: data['image_path'] as String?,
      unlockAt: (data['unlock_at'] as Timestamp).toDate(),
      expiresAt: (data['expires_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'template_id': templateId,
    'mission_number': missionNumber,
    'title': title,
    'description': description,
    'difficulty': difficulty,
    'reward_points': rewardPoints,
    'is_special': isSpecial,
    'image_path': imagePath,
    'unlock_at': Timestamp.fromDate(unlockAt),
    'expires_at': Timestamp.fromDate(expiresAt),
  };

  // ── Computed status (tidak disimpan ke Firestore) ─────────────────────────
  DailyMissionStatus computeStatus({
    required DateTime now,
    required bool isCompleted,
  }) {
    if (isCompleted) return DailyMissionStatus.completed;
    if (now.isBefore(unlockAt)) return DailyMissionStatus.locked;
    if (now.isAfter(expiresAt)) return DailyMissionStatus.expired;
    return DailyMissionStatus.inProgress;
  }
}

// ── Dokumen harian (daily_missions/{yyyy-MM-dd}) ──────────────────────────────
class DailyMissionDocument {
  final String date;           // "2025-01-21"
  final DateTime resetAt;
  final DateTime nextResetAt;
  final List<MissionSlot> missions;
  final int completedCount;

  const DailyMissionDocument({
    required this.date,
    required this.resetAt,
    required this.nextResetAt,
    required this.missions,
    this.completedCount = 0,
  });

  factory DailyMissionDocument.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawMissions = (data['missions'] as List<dynamic>?) ?? [];
    return DailyMissionDocument(
      date: data['date'] ?? doc.id,
      resetAt: (data['reset_at'] as Timestamp).toDate(),
      nextResetAt: (data['next_reset_at'] as Timestamp).toDate(),
      missions: rawMissions
          .map((m) => MissionSlot.fromMap(m as Map<String, dynamic>))
          .toList(),
      completedCount: (data['completed_count'] as num?)?.toInt() ?? 0,
    );
  }
}
```

---

### File: `lib/shared/models/user_mission_streak_model.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserMissionStreakModel {
  final String uid;
  final int currentStreak;
  final int longestStreak;
  final String? lastCompletedDate;   // "yyyy-MM-dd"
  final bool badgeEarned;
  final DateTime? badgeEarnedAt;
  final int totalMissionsDone;
  final Map<String, int> dailyCompletions;

  const UserMissionStreakModel({
    required this.uid,
    required this.currentStreak,
    required this.longestStreak,
    this.lastCompletedDate,
    required this.badgeEarned,
    this.badgeEarnedAt,
    required this.totalMissionsDone,
    required this.dailyCompletions,
  });

  factory UserMissionStreakModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserMissionStreakModel(
      uid: data['uid'] ?? doc.id,
      currentStreak: (data['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (data['longest_streak'] as num?)?.toInt() ?? 0,
      lastCompletedDate: data['last_completed_date'] as String?,
      badgeEarned: data['badge_earned'] ?? false,
      badgeEarnedAt: (data['badge_earned_at'] as Timestamp?)?.toDate(),
      totalMissionsDone: (data['total_missions_done'] as num?)?.toInt() ?? 0,
      dailyCompletions: Map<String, int>.from(
        (data['daily_completions'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, (v as num).toInt())),
      ),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'uid': uid,
    'current_streak': currentStreak,
    'longest_streak': longestStreak,
    'last_completed_date': lastCompletedDate,
    'badge_earned': badgeEarned,
    'badge_earned_at':
        badgeEarnedAt != null ? Timestamp.fromDate(badgeEarnedAt!) : null,
    'total_missions_done': totalMissionsDone,
    'daily_completions': dailyCompletions,
  };
}
```

---

### File: `lib/shared/models/user_mission_completion_model.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserMissionCompletionModel {
  final String uid;
  final String date;                  // "yyyy-MM-dd"
  final List<int> completedMissions;  // [1, 2, 3]
  final int pointsEarnedToday;
  final bool all7Completed;
  final DateTime? lastUpdatedAt;

  const UserMissionCompletionModel({
    required this.uid,
    required this.date,
    required this.completedMissions,
    required this.pointsEarnedToday,
    required this.all7Completed,
    this.lastUpdatedAt,
  });

  // Doc ID: "{uid}_{yyyy-MM-dd}"
  static String docId(String uid, String date) => '${uid}_$date';

  factory UserMissionCompletionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserMissionCompletionModel(
      uid: data['uid'] ?? '',
      date: data['date'] ?? '',
      completedMissions: List<int>.from(
        (data['completed_missions'] as List<dynamic>? ?? [])
            .map((e) => (e as num).toInt()),
      ),
      pointsEarnedToday: (data['points_earned_today'] as num?)?.toInt() ?? 0,
      all7Completed: data['all_7_completed'] ?? false,
      lastUpdatedAt: (data['last_updated_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'uid': uid,
    'date': date,
    'completed_missions': completedMissions,
    'points_earned_today': pointsEarnedToday,
    'all_7_completed': all7Completed,
    'last_updated_at': FieldValue.serverTimestamp(),
  };
}
```

---

## 5. Service Dart

### File: `lib/shared/services/daily_mission_service.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:santarana/shared/models/daily_mission_model.dart';
import 'package:santarana/shared/models/mission_template_model.dart';
import 'package:santarana/shared/models/user_mission_completion_model.dart';
import 'package:santarana/shared/models/user_mission_streak_model.dart';

class DailyMissionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Helper: tanggal hari ini sebagai string "yyyy-MM-dd" WIB ──────────────
  String get todayKey {
    // WIB = UTC+7
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    return DateFormat('yyyy-MM-dd').format(now);
  }

  DateTime get _nowWib =>
      DateTime.now().toUtc().add(const Duration(hours: 7));

  // ── 1. STREAM dokumen harian (real-time, untuk UI) ────────────────────────
  Stream<DailyMissionDocument?> dailyMissionStream() {
    return _db
        .collection('daily_missions')
        .doc(todayKey)
        .snapshots()
        .map((snap) {
      if (!snap.exists) return null;
      return DailyMissionDocument.fromFirestore(snap);
    });
  }

  // ── 2. GENERATE dokumen harian jika belum ada ─────────────────────────────
  // Dipanggil di DailyMissionController.onInit()
  Future<void> generateTodayIfNeeded() async {
    final docRef = _db.collection('daily_missions').doc(todayKey);
    final snap = await docRef.get();
    if (snap.exists) return; // sudah ada, skip

    // Ambil semua template aktif
    final templatesSnap = await _db
        .collection('daily_mission_templates')
        .where('is_active', isEqualTo: true)
        .orderBy('mission_number')
        .get();

    if (templatesSnap.docs.isEmpty) return;

    final templates = templatesSnap.docs
        .map(MissionTemplateModel.fromFirestore)
        .toList();

    // Hitung reset_at = 00:00 WIB hari ini (dalam UTC)
    final now = _nowWib;
    final resetAt = DateTime.utc(now.year, now.month, now.day)
        .subtract(const Duration(hours: 7)); // balik ke UTC
    final nextResetAt = resetAt.add(const Duration(days: 1));

    // Build list MissionSlot
    final slots = <Map<String, dynamic>>[];
    for (int i = 0; i < templates.length; i++) {
      final t = templates[i];
      final unlockAt = DateTime.utc(now.year, now.month, now.day,
              t.unlockHour)
          .subtract(const Duration(hours: 7));

      // expires_at = unlock_at misi berikutnya; misi terakhir = next_reset_at
      DateTime expiresAt;
      if (i < templates.length - 1) {
        final nextTemplate = templates[i + 1];
        expiresAt = DateTime.utc(now.year, now.month, now.day,
                nextTemplate.unlockHour)
            .subtract(const Duration(hours: 7));
      } else {
        expiresAt = nextResetAt;
      }

      slots.add(MissionSlot(
        templateId: t.id,
        missionNumber: t.missionNumber,
        title: t.title,
        description: t.description,
        difficulty: t.difficulty,
        rewardPoints: t.rewardPoints,
        isSpecial: t.isSpecial,
        imagePath: t.imagePath,
        unlockAt: unlockAt,
        expiresAt: expiresAt,
      ).toMap());
    }

    await docRef.set({
      'date': todayKey,
      'reset_at': Timestamp.fromDate(resetAt),
      'next_reset_at': Timestamp.fromDate(nextResetAt),
      'completed_count': 0,
      'missions': slots,
    });
  }

  // ── 3. AMBIL completion user hari ini ─────────────────────────────────────
  Future<UserMissionCompletionModel?> getTodayCompletion(String uid) async {
    final docId = UserMissionCompletionModel.docId(uid, todayKey);
    final snap =
        await _db.collection('user_mission_completions').doc(docId).get();
    if (!snap.exists) return null;
    return UserMissionCompletionModel.fromFirestore(snap);
  }

  // ── 4. TANDAI misi selesai ────────────────────────────────────────────────
  Future<void> completeMission({
    required String uid,
    required int missionNumber,
    required int rewardPoints,
    required int totalMissionsInDay,
  }) async {
    final date = todayKey;
    final docId = UserMissionCompletionModel.docId(uid, date);
    final completionRef =
        _db.collection('user_mission_completions').doc(docId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(completionRef);

      List<int> completedList = [];
      int pointsToday = 0;

      if (snap.exists) {
        final existing = UserMissionCompletionModel.fromFirestore(snap);
        // Jika misi sudah dicatat, skip (idempotent)
        if (existing.completedMissions.contains(missionNumber)) return;
        completedList = List<int>.from(existing.completedMissions);
        pointsToday = existing.pointsEarnedToday;
      }

      completedList.add(missionNumber);
      pointsToday += rewardPoints;
      final all7 = completedList.length >= totalMissionsInDay;

      tx.set(completionRef, {
        'uid': uid,
        'date': date,
        'completed_missions': completedList,
        'points_earned_today': pointsToday,
        'all_7_completed': all7,
        'last_updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update poin user
      tx.update(_db.collection('users').doc(uid), {
        'totalPoints': FieldValue.increment(rewardPoints),
        'lastActiveAt': FieldValue.serverTimestamp(),
      });

      // Jika semua misi selesai, trigger streak update
      if (all7) {
        _updateStreakAfterCompletion(uid, date);
      }
    });
  }

  // ── 5. UPDATE STREAK ──────────────────────────────────────────────────────
  Future<void> _updateStreakAfterCompletion(
      String uid, String completedDate) async {
    final streakRef = _db.collection('user_mission_streaks').doc(uid);
    final snap = await streakRef.get();

    int currentStreak = 1;
    int longestStreak = 1;
    bool badgeEarned = false;
    DateTime? badgeEarnedAt;

    if (snap.exists) {
      final existing = UserMissionStreakModel.fromFirestore(snap);

      // Cek apakah last_completed_date adalah kemarin
      final yesterday = _getYesterdayKey();
      final isConsecutive = existing.lastCompletedDate == yesterday;

      currentStreak = isConsecutive ? existing.currentStreak + 1 : 1;
      longestStreak =
          currentStreak > existing.longestStreak ? currentStreak : existing.longestStreak;
      badgeEarned = existing.badgeEarned;
      badgeEarnedAt = existing.badgeEarnedAt;

      // Badge: streak mencapai 7 untuk pertama kali
      if (currentStreak >= 7 && !badgeEarned) {
        badgeEarned = true;
        badgeEarnedAt = DateTime.now();
        // Tambahkan badge ke user
        await _db.collection('users').doc(uid).update({
          // Simpan badge ke medals — sesuaikan dengan sistem medals existing
          'missionBadgeEarned': true,
          'missionBadgeEarnedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    await streakRef.set({
      'uid': uid,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_completed_date': completedDate,
      'badge_earned': badgeEarned,
      'badge_earned_at':
          badgeEarnedAt != null ? Timestamp.fromDate(badgeEarnedAt) : null,
      'total_missions_done': FieldValue.increment(1),
      'daily_completions.$completedDate': 7,
    }, SetOptions(merge: true));
  }

  // ── 6. AMBIL STREAK USER ──────────────────────────────────────────────────
  Future<UserMissionStreakModel?> getUserStreak(String uid) async {
    final snap =
        await _db.collection('user_mission_streaks').doc(uid).get();
    if (!snap.exists) return null;
    return UserMissionStreakModel.fromFirestore(snap);
  }

  // ── Helper: kemarin dalam format "yyyy-MM-dd" ─────────────────────────────
  String _getYesterdayKey() {
    final yesterday =
        _nowWib.subtract(const Duration(days: 1));
    return DateFormat('yyyy-MM-dd').format(yesterday);
  }
}
```

> **Catatan:** tambahkan `intl: ^0.19.0` ke `pubspec.yaml` dependencies jika belum ada.

---

## 6. Controller Dart

### File: `lib/app/modules/daily_mission/controllers/daily_mission_controller.dart`

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:santarana/shared/controllers/auth_controller.dart';
import 'package:santarana/shared/models/daily_mission_model.dart';
import 'package:santarana/shared/models/user_mission_completion_model.dart';
import 'package:santarana/shared/services/daily_mission_service.dart';

class DailyMissionController extends GetxController {
  final DailyMissionService _service = DailyMissionService();
  AuthController get _auth => Get.find<AuthController>();

  // ── State ──────────────────────────────────────────────────────────────────
  final isLoading = true.obs;
  final dailyDoc = Rxn<DailyMissionDocument>();
  final completion = Rxn<UserMissionCompletionModel>();
  final isSaving = false.obs;

  StreamSubscription<DailyMissionDocument?>? _missionSub;

  // ── Computed: misi dengan status masing-masing ─────────────────────────────
  List<MissionSlotWithStatus> get missionsWithStatus {
    final doc = dailyDoc.value;
    if (doc == null) return [];
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final completed = completion.value?.completedMissions ?? [];

    return doc.missions.map((slot) {
      final status = slot.computeStatus(
        now: now,
        isCompleted: completed.contains(slot.missionNumber),
      );
      return MissionSlotWithStatus(slot: slot, status: status);
    }).toList();
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    isLoading.value = true;
    try {
      // Generate dokumen hari ini jika belum ada
      await _service.generateTodayIfNeeded();

      // Stream real-time
      _missionSub = _service.dailyMissionStream().listen((doc) {
        dailyDoc.value = doc;
      });

      // Ambil completion user
      final uid = _auth.uid;
      if (uid != null) {
        completion.value = await _service.getTodayCompletion(uid);
      }
    } catch (e) {
      // Non-critical: UI tetap tampil
      debugPrint('DailyMissionController init error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Tap misi ───────────────────────────────────────────────────────────────
  void onMissionTap(MissionSlotWithStatus item) {
    switch (item.status) {
      case DailyMissionStatus.locked:
        Get.snackbar(
          '🔒 Misi Terkunci',
          'Misi ini akan terbuka pada jam ${_formatHour(item.slot.unlockAt)}',
          backgroundColor: const Color(0xFF8B3A3A),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 14,
          duration: const Duration(seconds: 2),
        );
        break;

      case DailyMissionStatus.expired:
        Get.snackbar(
          '⏰ Misi Berakhir',
          'Waktu untuk misi ini sudah habis. Coba lagi besok!',
          backgroundColor: const Color(0xFF5D4037),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 14,
          duration: const Duration(seconds: 2),
        );
        break;

      case DailyMissionStatus.completed:
        Get.snackbar(
          '✅ Misi Selesai',
          'Kamu sudah menyelesaikan misi ini. Luar biasa!',
          backgroundColor: const Color(0xFF2E7D32),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 14,
          duration: const Duration(seconds: 2),
        );
        break;

      case DailyMissionStatus.inProgress:
        // TODO: Navigasi ke halaman challenge misi
        // Get.toNamed(Routes.MISSION_CHALLENGE, arguments: {'slot': item.slot});
        _doCompleteMission(item.slot); // Sementara: langsung complete (untuk testing)
        break;
    }
  }

  // ── Selesaikan misi (dipanggil setelah user menyelesaikan challenge) ────────
  Future<void> _doCompleteMission(MissionSlot slot) async {
    final uid = _auth.uid;
    if (uid == null) return;

    try {
      isSaving.value = true;
      await _service.completeMission(
        uid: uid,
        missionNumber: slot.missionNumber,
        rewardPoints: slot.rewardPoints,
        totalMissionsInDay: dailyDoc.value?.missions.length ?? 7,
      );

      // Refresh completion
      completion.value = await _service.getTodayCompletion(uid);

      // Refresh poin di AuthController
      await _auth.refreshUser();

      Get.snackbar(
        '🎉 Misi Selesai!',
        '+${slot.rewardPoints} poin berhasil didapat',
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan, coba lagi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // ── Helper ─────────────────────────────────────────────────────────────────
  String _formatHour(DateTime dt) {
    final wib = dt.toUtc().add(const Duration(hours: 7));
    final h = wib.hour.toString().padLeft(2, '0');
    return '$h:00 WIB';
  }

  @override
  void onClose() {
    _missionSub?.cancel();
    super.onClose();
  }
}

// ── ViewModel: slot + computed status ────────────────────────────────────────
class MissionSlotWithStatus {
  final MissionSlot slot;
  final DailyMissionStatus status;
  const MissionSlotWithStatus({required this.slot, required this.status});
}
```

### File: `lib/app/modules/daily_mission/bindings/daily_mission_binding.dart`

```dart
import 'package:get/get.dart';
import '../controllers/daily_mission_controller.dart';

class DailyMissionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DailyMissionController>(() => DailyMissionController());
  }
}
```

---

## 7. Update UI — HomeView & KategoriKuisView

### 7.1 Perubahan di `home_controller.dart`

Tambahkan di `HomeController`:

```dart
// Tambah di atas class HomeController
import 'package:santarana/app/modules/daily_mission/controllers/daily_mission_controller.dart';

// Tambah di dalam onInit()
@override
void onInit() {
  super.onInit();
  fetchCategories();
  fetchUserProgress();
  // Pastikan DailyMissionController sudah di-inject via AppShellBinding
}
```

### 7.2 Inject `DailyMissionController` di `app_shell_binding.dart`

Tambahkan di `AppShellBinding.dependencies()`:

```dart
import 'package:santarana/app/modules/daily_mission/controllers/daily_mission_controller.dart';
import 'package:santarana/app/modules/daily_mission/bindings/daily_mission_binding.dart';

// Di dalam dependencies():
Get.lazyPut<DailyMissionController>(() => DailyMissionController());
```

### 7.3 Perubahan di `home_view.dart` — `_buildMisiEksplorHarian()`

Ganti fungsi `_buildMisiEksplorHarian()` dan `_buildMissionGrid()` dengan versi yang membaca dari `DailyMissionController`:

```dart
// Tambah import di atas home_view.dart
import 'package:santarana/app/modules/daily_mission/controllers/daily_mission_controller.dart';

// Ganti _buildMisiEksplorHarian() — bagian _buildMissionGrid() saja:
Widget _buildMissionGrid() {
  final missionCtrl = Get.find<DailyMissionController>();

  return Obx(() {
    if (missionCtrl.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFB347)),
      );
    }

    final items = missionCtrl.missionsWithStatus;
    final regular = items.where((m) => !m.slot.isSpecial).toList();
    final special = items.cast<MissionSlotWithStatus?>()
        .firstWhere((m) => m?.slot.isSpecial == true, orElse: () => null);

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.15,
          ),
          itemCount: regular.length,
          itemBuilder: (_, i) => _buildMissionCard(
            regular[i],
            onTap: () => missionCtrl.onMissionTap(regular[i]),
          ),
        ),
        if (special != null) ...[
          const SizedBox(height: 14),
          _buildSpecialMissionCard(
            special,
            onTap: () => missionCtrl.onMissionTap(special),
          ),
        ],
      ],
    );
  });
}
```

> **Catatan:** Signature `_buildMissionCard` dan `_buildSpecialMissionCard` perlu ditambahkan parameter `onTap: VoidCallback` dan `MissionSlotWithStatus` sebagai pengganti `_DailyMission`. Perubahan detail ini dikerjakan saat step coding aktual.

---

## 8. Seed Data Firestore (Admin)

Jalankan sekali melalui Firestore console atau script Dart berikut untuk mengisi `daily_mission_templates`:

```dart
// Script: seed_daily_mission_templates.dart (jalankan sekali)
// Letakkan di tools/ atau jalankan via Flutter test

import 'package:cloud_firestore/cloud_firestore.dart';

final templates = [
  {
    'title': 'Senjata Adat Nusantara',
    'description': 'Jawab 5 soal tentang senjata tradisional Indonesia',
    'difficulty': 'Mudah',
    'mission_number': 1,
    'unlock_hour': 0,      // 00:00 WIB
    'reward_points': 15,
    'is_special': false,
    'is_active': true,
    'image_path': 'assets/images/senjata_adat_tradisional.png',
  },
  {
    'title': 'Musik Nusantara',
    'description': 'Tebak alat musik tradisional dari deskripsinya',
    'difficulty': 'Mudah',
    'mission_number': 2,
    'unlock_hour': 4,      // 04:00 WIB
    'reward_points': 15,
    'is_special': false,
    'is_active': true,
    'image_path': 'assets/images/musik_nusantara.png',
  },
  {
    'title': 'Tarian Adat',
    'description': 'Cocokkan tarian dengan daerah asalnya',
    'difficulty': 'Sedang',
    'mission_number': 3,
    'unlock_hour': 8,      // 08:00 WIB
    'reward_points': 20,
    'is_special': false,
    'is_active': true,
    'image_path': 'assets/images/tarian_adat.png',
  },
  {
    'title': 'Makanan Nusantara',
    'description': 'Kenali makanan tradisional dari namanya',
    'difficulty': 'Sedang',
    'mission_number': 4,
    'unlock_hour': 12,     // 12:00 WIB
    'reward_points': 20,
    'is_special': false,
    'is_active': true,
    'image_path': 'assets/images/makanan_nusantara.png',
  },
  {
    'title': 'Rumah Adat',
    'description': 'Tebak rumah adat dari siluet gambarnya',
    'difficulty': 'Sulit',
    'mission_number': 5,
    'unlock_hour': 16,     // 16:00 WIB
    'reward_points': 25,
    'is_special': false,
    'is_active': true,
    'image_path': null,
  },
  {
    'title': 'Pakaian Adat',
    'description': 'Identifikasi pakaian adat dari daerah mana',
    'difficulty': 'Sulit',
    'mission_number': 6,
    'unlock_hour': 20,     // 20:00 WIB
    'reward_points': 25,
    'is_special': false,
    'is_active': true,
    'image_path': null,
  },
  {
    'title': 'Master Nusantara',
    'description': 'Tantangan spesial: semua kategori dalam satu misi!',
    'difficulty': 'Sangat Sulit',
    'mission_number': 7,
    'unlock_hour': 22,     // 22:00 WIB
    'reward_points': 50,
    'is_special': true,
    'is_active': true,
    'image_path': 'assets/images/senjata_adat_tradisional.png',
  },
];

Future<void> seedTemplates() async {
  final db = FirebaseFirestore.instance;
  final batch = db.batch();

  for (final t in templates) {
    final ref = db.collection('daily_mission_templates').doc();
    batch.set(ref, {
      ...t,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  await batch.commit();
  print('Seed selesai: ${templates.length} templates ditambahkan');
}
```

---

## 9. Urutan Eksekusi Penulisan Kode

Ikuti urutan ini agar tidak ada dependency error:

```
1. pubspec.yaml
   └── Tambahkan: intl: ^0.19.0

2. Models (tidak ada dependency antar-model)
   ├── lib/shared/models/mission_template_model.dart
   ├── lib/shared/models/daily_mission_model.dart
   ├── lib/shared/models/user_mission_streak_model.dart
   └── lib/shared/models/user_mission_completion_model.dart

3. Service
   └── lib/shared/services/daily_mission_service.dart

4. Controller + Binding
   ├── lib/app/modules/daily_mission/controllers/daily_mission_controller.dart
   └── lib/app/modules/daily_mission/bindings/daily_mission_binding.dart

5. Inject ke shell
   └── lib/app/app_shell_binding.dart  (tambah DailyMissionController)

6. Update HomeView
   └── lib/app/modules/home/views/home_view.dart
       └── Ganti _buildMissionGrid() agar baca dari DailyMissionController

7. Seed Firestore (jalankan sekali)
   └── Isi collection daily_mission_templates via script atau console

8. Test flow end-to-end
   └── Pastikan daily_missions/{today} terbentuk otomatis saat app dibuka
```

---

## 10. Checklist QA

- [ ] `daily_mission_templates` terisi 7 dokumen via seed
- [ ] Buka app → `daily_missions/{today}` terbentuk otomatis
- [ ] Kartu misi 1 status `inProgress` di jam 00:00–04:00
- [ ] Kartu misi 1 status `expired` setelah jam 04:00
- [ ] Kartu misi 2 status `locked` sebelum jam 04:00, `inProgress` setelahnya
- [ ] Selesaikan misi → poin bertambah di HomeView (via `authController.totalPoints`)
- [ ] Selesaikan semua 7 misi → `all_7_completed = true`
- [ ] Streak bertambah jika kemarin juga selesai 7 misi
- [ ] Streak reset jika ada hari yang di-skip
- [ ] Setelah 7 hari streak → `badge_earned = true` di `user_mission_streaks`
- [ ] Misi ke-7 (spesial) hanya unlock jam 22:00, expire jam 00:00 besok
- [ ] Tidak ada duplikasi dokumen `daily_missions` pada hari yang sama
- [ ] `completeMission()` idempotent — misi yang sudah selesai tidak di-complete ulang

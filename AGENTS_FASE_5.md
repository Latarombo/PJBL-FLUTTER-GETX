# ⬜ FASE 5 — Leaderboard Real-time

> Baca `AGENTS.md` (core) terlebih dahulu, lalu baca file ini.
> Status: **STANDBY** — kerjakan setelah Fase 4 selesai & ter-checklist semua.
> Tujuan: Leaderboard menampilkan data nyata dari Firestore secara real-time.

---

## 🎯 TUJUAN FASE INI

- `leaderboard` collection di Firestore berisi entry per user
- LeaderboardView menampilkan top 50 via Stream real-time
- Podium top 3 menggunakan data asli
- Current user card menampilkan data user yang sedang login
- Entry leaderboard terupdate otomatis setelah quiz selesai (dari Fase 4)

---

## ❌ KONDISI SAAT INI (Yang Harus Diubah)

```dart
// leaderboard_controller.dart — SEMUA HARDCODE
final leaderboardData = <LeaderboardEntry>[
  LeaderboardEntry(rank: 1, username: 'keisya_pfp', score: 12500),
  LeaderboardEntry(rank: 2, username: 'user2', score: 11000),
  // ... semua hardcode
].obs;

// leaderboard_view.dart — podium hardcode
// _buildCurrentUserCard() — rank '3', 'Anda', '6370' hardcode
```

---

## 📁 FILE BARU YANG HARUS DIBUAT

### 1. `lib/shared/models/leaderboard_model.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardModel {
  final String uid;
  final String username;
  final String? avatarUrl;
  final int totalPoints;
  final int rank;           // dihitung dari posisi di list (bukan dari Firestore)
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

  // copyWith untuk assign rank setelah sort
  LeaderboardModel copyWith({int? rank}) => LeaderboardModel(
    uid: uid,
    username: username,
    avatarUrl: avatarUrl,
    totalPoints: totalPoints,
    rank: rank ?? this.rank,
    lastUpdated: lastUpdated,
  );
}
```

---

### 2. `lib/shared/services/leaderboard_service.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:santarana/shared/models/leaderboard_model.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream real-time top 50 — LeaderboardController listen ke ini
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
      // Assign rank berdasarkan posisi
      return List.generate(
        entries.length,
        (i) => entries[i].copyWith(rank: i + 1),
      );
    });
  }

  // Update atau create entry leaderboard — dipanggil dari quiz_controller setelah quiz selesai
  Future<void> updateLeaderboardEntry(
      String uid, String username, int totalPoints) async {
    try {
      await _firestore.collection('leaderboard').doc(uid).set({
        'uid': uid,
        'username': username,
        'totalPoints': totalPoints,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Gagal update leaderboard: $e');
    }
  }

  // Ambil rank user tertentu (posisi di leaderboard)
  Future<int> getUserRank(String uid) async {
    try {
      final userDoc = await _firestore.collection('leaderboard').doc(uid).get();
      if (!userDoc.exists) return 0;
      final userPoints = userDoc.data()?['totalPoints'] ?? 0;
      // Hitung berapa user yang poinnya lebih tinggi
      final snapshot = await _firestore
          .collection('leaderboard')
          .where('totalPoints', isGreaterThan: userPoints)
          .count()
          .get();
      return (snapshot.count ?? 0) + 1;
    } catch (e) {
      return 0;
    }
  }
}
```

---

## 📝 FILE YANG HARUS DIUPDATE

### `leaderboard_controller.dart` — Ganti Total ke Stream

```dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:santarana/shared/controllers/auth_controller.dart';
import 'package:santarana/shared/models/leaderboard_model.dart';
import 'package:santarana/shared/services/leaderboard_service.dart';

class LeaderboardController extends GetxController {
  final LeaderboardService _leaderboardService = LeaderboardService();
  final AuthController _authController = Get.find<AuthController>();

  final leaderboardData = <LeaderboardModel>[].obs;
  final isLoading = true.obs;

  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    _listenLeaderboard();
  }

  void _listenLeaderboard() {
    _subscription = _leaderboardService.leaderboardStream().listen(
      (data) {
        leaderboardData.value = data;
        isLoading.value = false;
      },
      onError: (_) {
        isLoading.value = false;
        Get.snackbar('Error', 'Gagal memuat leaderboard',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
      },
    );
  }

  // Data top 3 untuk podium
  List<LeaderboardModel> get top3 => leaderboardData.take(3).toList();

  // Entry user yang sedang login
  LeaderboardModel? get currentUserEntry {
    final uid = _authController.uid;
    if (uid == null) return null;
    try {
      return leaderboardData.firstWhere((e) => e.uid == uid);
    } catch (_) {
      return null;
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
```

---

### `leaderboard_view.dart` — Data Nyata

```dart
// _buildPodium() — UBAH dari hardcode ke:
Obx(() {
  final top = controller.top3;
  if (top.length < 3) return const SizedBox.shrink();
  return _buildPodium(
    first: top[0],   // rank 1
    second: top[1],  // rank 2
    third: top[2],   // rank 3
  );
})

// _buildLeaderboardList() — UBAH ke:
Obx(() {
  if (controller.isLoading.value) {
    return const CircularProgressIndicator();
  }
  return ListView.builder(
    itemCount: controller.leaderboardData.length,
    itemBuilder: (_, i) {
      final entry = controller.leaderboardData[i];
      return _buildLeaderboardItem(entry); // sesuaikan dengan widget yang ada
    },
  );
})

// _buildCurrentUserCard() — UBAH dari hardcode ke:
Obx(() {
  final userEntry = controller.currentUserEntry;
  if (userEntry == null) return const SizedBox.shrink();
  return _buildCurrentUserCard(
    rank: userEntry.rank,
    username: userEntry.username,
    points: userEntry.totalPoints,
  );
})
```

---

### `quiz_controller.dart` — Tambahkan Update Leaderboard

```dart
// Di _saveResults() dari Fase 4, tambahkan:
final LeaderboardService _leaderboardService = LeaderboardService();

// Di Future.wait([...]) tambahkan:
_leaderboardService.updateLeaderboardEntry(
  uid,
  _authController.username,
  _authController.totalPoints + pointsEarned,
),
```

---

## 🗄️ STRUKTUR FIRESTORE: Collection `leaderboard`

```
leaderboard/{uid}
  uid          : String
  username     : String
  avatarUrl    : String?  ← null jika belum ada foto profil
  totalPoints  : Number   ← diupdate setiap quiz selesai
  lastUpdated  : Timestamp
```

> 💡 **Catatan:** `rank` TIDAK disimpan di Firestore.
> Rank dihitung dari posisi di list setelah query `orderBy('totalPoints', descending: true)`.

---

## ✅ CHECKLIST FASE 5

```
✅ Buat lib/shared/models/leaderboard_model.dart
✅ Buat lib/shared/services/leaderboard_service.dart
✅ Update leaderboard_controller.dart (stream dari Firestore, hapus hardcode)
✅ Update leaderboard_view.dart (podium dari top3)
✅ Update leaderboard_view.dart (current user card data nyata)
✅ Update quiz_controller.dart (panggil updateLeaderboardEntry setelah quiz)
✅ Test: selesaikan quiz → cek leaderboard collection di Firestore
✅ Test: leaderboard view update real-time tanpa refresh manual
✅ Test: podium menampilkan top 3 yang benar
✅ Test: current user card menampilkan rank & poin yang benar
✅ Test: 2 user main quiz — urutan leaderboard berubah sesuai poin
```

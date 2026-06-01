import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:santarana/app/routes/app_pages.dart';
import 'package:santarana/shared/controllers/auth_controller.dart';
import 'package:santarana/shared/models/badge_model.dart';
import 'package:santarana/shared/models/user_model.dart';
import 'package:santarana/shared/services/auth_service.dart';
import 'package:santarana/shared/services/badge_service.dart';
import 'package:santarana/shared/services/profile_service.dart';

class ProfileController extends GetxController {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  final BadgeService _badgeService = BadgeService();
  final AuthController _authController = Get.find<AuthController>();

  final isLoadingBadges = false.obs;
  final allBadges = <BadgeModel>[].obs;
  final earnedBadgeIds = <String>{}.obs; // set ID badge yang sudah diraih

  StreamSubscription<UserModel>? _statsSubscription;
  final isLoadingRank = false.obs;

  @override
  void onInit() {
    super.onInit();
    _listenStats();
    _refreshRank();
    _loadBadges();
  }

  // ── Load semua badge + earned badge user ──────────────────────
  Future<void> _loadBadges() async {
    final uid = _authController.uid;
    if (uid == null) return;

    try {
      isLoadingBadges.value = true;

      // Fetch paralel: semua badge + earned badge user
      final results = await Future.wait([
        _badgeService.getAllBadgesIncludingInactive(),
        _badgeService.getEarnedBadges(uid),
      ]);

      allBadges.value = results[0] as List<BadgeModel>;

      final earned = results[1] as List<EarnedBadgeModel>;
      earnedBadgeIds.value = earned.map((e) => e.badgeId).toSet();
    } catch (e) {
      debugPrint('Warning: gagal load badges: $e');
    } finally {
      isLoadingBadges.value = false;
    }
  }

  // ── Subscribe stream stats user dari Firestore ────────────────────────────
  //
  // Stream ini memastikan poin, correctRate, quizCompleted, streak
  // otomatis update di ProfileView tanpa perlu pull manual.
  void _listenStats() {
    final uid = _authController.uid;
    if (uid == null) return;

    _statsSubscription?.cancel();
    _statsSubscription = _profileService
        .userStatsStream(uid)
        .listen(
          (updatedUser) {
            // Update currentUser di AuthController → semua Obx() langsung render ulang
            _authController.setUser(updatedUser);
          },
          onError: (_) {
            // Non-critical: stream error tidak perlu crash app
            // ignore: avoid_print
          },
        );
  }

  // ── Hitung & simpan rank dari leaderboard ─────────────────────────────────
  //
  // Dipanggil saat onInit (tab profile dibuka).
  // Rank dihitung dari posisi di collection leaderboard,
  // lalu disimpan ke users/{uid}.rank dan di-refresh ke AuthController.
  Future<void> _refreshRank() async {
    final uid = _authController.uid;
    if (uid == null) return;

    try {
      isLoadingRank.value = true;

      final rank = await _profileService.getRankFromLeaderboard(uid);

      // Hanya update ke Firestore jika rank berubah (hemat write)
      if (rank > 0 && rank != _authController.rank) {
        await _profileService.saveRank(uid: uid, rank: rank);
        await _authController.refreshUser();
      }
    } catch (_) {
      // Non-critical: rank gagal dihitung tidak crash app
    } finally {
      isLoadingRank.value = false;
    }
  }

  // ── Navigasi ke halaman Edit Profile ─────────────────────────────────────
  void goToEditAccount() {
    Get.toNamed(Routes.EDIT_PROFILE);
  }

  void showFeatureSnackbar(String feature) {
    Get.snackbar(
      'Info',
      'Fitur $feature akan segera hadir',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  void logout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin keluar akun?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF9E9E9E)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _doLogout();
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _doLogout() async {
    try {
      await _authService.signOut();
      _authController.clearUser();
      Get.offAllNamed(Routes.SIGN_IN);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal logout, coba lagi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    _statsSubscription?.cancel();
    super.onClose();
  }
}

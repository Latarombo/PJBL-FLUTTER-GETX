import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:santarana/shared/controllers/auth_controller.dart';
import 'package:santarana/shared/models/leaderboard_model.dart';
import 'package:santarana/shared/services/leaderboard_service.dart';

class LeaderboardController extends GetxController {
  final LeaderboardService _leaderboardService = LeaderboardService();
  final AuthController _authController = Get.find<AuthController>();

  final leaderboardData = <LeaderboardModel>[].obs;
  final isLoading = true.obs;

  StreamSubscription<List<LeaderboardModel>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _listenLeaderboard();
  }

  void _listenLeaderboard() {
    _subscription?.cancel();
    isLoading.value = true;

    _subscription = _leaderboardService.leaderboardStream().listen(
      (data) {
        leaderboardData.value = data;
        isLoading.value = false;
      },
      onError: (_) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Gagal memuat leaderboard',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  void refresh() {
    _listenLeaderboard();
  }

  List<LeaderboardModel> get top3 => leaderboardData.take(3).toList();

  /// Selalu return entry user saat ini.
  /// - Jika ada di leaderboard → return dengan rank asli
  /// - Jika belum ada (belum main) → return dengan rank 0 (ditampilkan sebagai "-")
  LeaderboardModel? get currentUserEntry {
    final uid = _authController.uid;
    if (uid == null) return null;

    try {
      // Coba cari di leaderboard stream
      return leaderboardData.firstWhere((e) => e.uid == uid);
    } catch (_) {
      // Belum ada di leaderboard → buat entry dummy dengan poin 0 & rank 0
      return LeaderboardModel(
        uid: uid,
        username: _authController.username,
        totalPoints: _authController.totalPoints,
        rank: 0, // 0 = belum punya rank, ditampilkan "-"
      );
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}

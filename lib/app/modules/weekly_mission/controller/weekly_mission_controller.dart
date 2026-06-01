import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:santarana/shared/controllers/auth_controller.dart';
import 'package:santarana/shared/models/weekly_mission_model.dart';
import 'package:santarana/shared/services/weekly_mission_service.dart';

class WeeklyMissionController extends GetxController {
  final WeeklyMissionService _service = WeeklyMissionService();
  AuthController get _auth => Get.find<AuthController>();

  // ── State ──────────────────────────────────────────────────────
  final isLoading = true.obs;
  final weeklyDoc = Rxn<WeeklyMissionDocument>();
  final completion = Rxn<UserWeeklyCompletion>();
  final isSaving = false.obs;

  StreamSubscription<WeeklyMissionDocument?>? _missionSub;

  // ── Computed: misi dengan status ──────────────────────────────
  List<WeeklyMissionSlotWithStatus> get missionsWithStatus {
    final doc = weeklyDoc.value;
    if (doc == null) return [];

    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final completedDays = completion.value?.completedDays ?? [];
    final canDoSpecial = completion.value?.canDoSpecialMission ?? false;

    return doc.missions.map((slot) {
      final isCompleted = completedDays.contains(slot.day);
      final status = slot.computeStatus(
        now: now,
        isCompleted: isCompleted,
        isSpecialLocked: slot.isSpecial && !canDoSpecial,
      );
      return WeeklyMissionSlotWithStatus(slot: slot, status: status);
    }).toList();
  }

  // ── Lifecycle ──────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    isLoading.value = true;
    try {
      await _service.generateWeekIfNeeded();

      _missionSub = _service.weeklyMissionStream().listen((doc) {
        weeklyDoc.value = doc;
      });

      final uid = _auth.uid;
      if (uid != null) {
        completion.value = await _service.getThisWeekCompletion(uid);
      }
    } catch (e) {
      debugPrint('WeeklyMissionController init error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Tap misi ───────────────────────────────────────────────────
  void onMissionTap(WeeklyMissionSlotWithStatus item) {
    switch (item.status) {
      case WeeklyMissionStatus.locked:
        final msg = item.slot.isSpecial
            ? 'Selesaikan misi hari 1-6 terlebih dahulu!'
            : 'Misi ini akan terbuka pada hari yang ditentukan';
        Get.snackbar(
          '🔒 Misi Terkunci',
          msg,
          backgroundColor: const Color(0xFF8B3A3A),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 14,
          duration: const Duration(seconds: 2),
        );
        break;

      case WeeklyMissionStatus.expired:
        Get.snackbar(
          '⏰ Misi Berakhir',
          'Waktu untuk misi ini sudah habis. Coba lagi minggu depan!',
          backgroundColor: const Color(0xFF5D4037),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 14,
          duration: const Duration(seconds: 2),
        );
        break;

      case WeeklyMissionStatus.completed:
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

      case WeeklyMissionStatus.inProgress:
        _doCompleteMission(item.slot);
        break;
    }
  }

  // ── Selesaikan misi ────────────────────────────────────────────
  Future<void> _doCompleteMission(WeeklyMissionSlot slot) async {
    final uid = _auth.uid;
    if (uid == null) return;

    try {
      isSaving.value = true;

      await _service.completeMission(
        uid: uid,
        day: slot.day,
        rewardPoints: slot.rewardPoints,
        totalMissionsInWeek: weeklyDoc.value?.missions.length ?? 7,
      );

      completion.value = await _service.getThisWeekCompletion(uid);
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

  @override
  void onClose() {
    _missionSub?.cancel();
    super.onClose();
  }
}

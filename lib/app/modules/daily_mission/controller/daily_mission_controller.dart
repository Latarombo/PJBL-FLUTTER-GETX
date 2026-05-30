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
      await _service.generateTodayIfNeeded();

      _missionSub = _service.dailyMissionStream().listen((doc) {
        dailyDoc.value = doc;
      });

      final uid = _auth.uid;
      if (uid != null) {
        completion.value = await _service.getTodayCompletion(uid);
      }
    } catch (e) {
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
        _doCompleteMission(
          item.slot,
        ); // Sementara: langsung complete (untuk testing)
        break;
    }
  }

  // ── Selesaikan misi ────────────────────────────────────────────────────────
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

      completion.value = await _service.getTodayCompletion(uid);
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

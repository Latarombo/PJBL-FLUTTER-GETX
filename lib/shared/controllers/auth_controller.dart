import 'package:get/get.dart';
import 'package:santarana/shared/models/user_model.dart';
import 'package:santarana/shared/services/auth_service.dart';

class AuthController extends GetxService {
  final AuthService _authService = AuthService();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  bool get isLoggedIn => currentUser.value != null;
  String get username => currentUser.value?.username ?? '';
  String get email => currentUser.value?.email ?? '';
  String get role => currentUser.value?.role ?? 'user';
  String? get avatarUrl => currentUser.value?.avatarUrl;
  bool get isAdmin => role == 'admin' || role == 'superadmin';
  bool get isSuperAdmin => role == 'superadmin';
  int get totalPoints => currentUser.value?.totalPoints ?? 0;
  int get rank => currentUser.value?.rank ?? 0;
  double get correctRate => currentUser.value?.correctRate ?? 0.0;
  int get quizCompleted => currentUser.value?.quizCompleted ?? 0;
  int get streak => currentUser.value?.streak ?? 0;
  String? get uid => currentUser.value?.uid;

  void setUser(UserModel user) {
    currentUser.value = user;
  }

  void clearUser() {
    currentUser.value = null;
  }

  Future<void> refreshUser() async {
    final uid = currentUser.value?.uid;
    if (uid == null) return;
    final updated = await _authService.getUserData(uid);
    if (updated != null) currentUser.value = updated;
  }
}

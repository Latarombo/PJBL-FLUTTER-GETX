// lib/app/routes/app_pages.dart

import 'package:get/get.dart';

import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/sign_in/bindings/sign_in_binding.dart';
import '../modules/sign_in/views/sign_in_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/forgot_password/views/forgot_password_view.dart';
import '../modules/email_verification/bindings/email_verification_binding.dart';
import '../modules/email_verification/views/email_verification_view.dart';
import '../modules/password_recovery_success/bindings/password_recovery_success_binding.dart';
import '../modules/password_recovery_success/views/password_recovery_success_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/quiz/bindings/quiz_binding.dart';
import '../modules/quiz/views/quiz_view.dart';
import '../modules/leaderboard/bindings/leaderboard_binding.dart';
import '../modules/leaderboard/views/leaderboard_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../app_shell.dart';
import '../app_shell_binding.dart';


part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.SIGN_IN,
      page: () => const SignInView(),
      binding: SignInBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: _Paths.EMAIL_VERIFICATION,
      page: () => const EmailVerificationView(),
      binding: EmailVerificationBinding(),
    ),
    GetPage(
      name: _Paths.PASSWORD_RECOVERY_SUCCESS,
      page: () => const PasswordRecoverySuccessView(),
      binding: PasswordRecoverySuccessBinding(),
    ),
    // AppShell sebagai shell utama (bottom navigation)
    GetPage(
      name: _Paths.APP,
      page: () => const AppShell(),
      binding: AppShellBinding(),
    ),
  ];
}

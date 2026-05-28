part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const SPLASH = _Paths.SPLASH;
  static const SIGN_IN = _Paths.SIGN_IN;
  static const REGISTER = _Paths.REGISTER;
  static const FORGOT_PASSWORD = _Paths.FORGOT_PASSWORD;
  static const EMAIL_VERIFICATION = _Paths.EMAIL_VERIFICATION;
  static const PASSWORD_RECOVERY_SUCCESS = _Paths.PASSWORD_RECOVERY_SUCCESS;
  static const APP = '/app';
  static const HOME = _Paths.HOME;
  static const QUIZ = _Paths.QUIZ;
  static const LEADERBOARD = _Paths.LEADERBOARD;
  static const PROFILE = _Paths.PROFILE;
  static const EDIT_PROFILE = _Paths.EDIT_PROFILE;
  static const SETTINGS = _Paths.SETTINGS;
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/';
  static const SIGN_IN = '/sign-in';
  static const REGISTER = '/register';
  static const FORGOT_PASSWORD = '/forgot-password';
  static const EMAIL_VERIFICATION = '/email-verification';
  static const PASSWORD_RECOVERY_SUCCESS = '/password-recovery-success';
  static const APP = '/app';
  static const HOME = '/home';
  static const QUIZ = '/quiz';
  static const LEADERBOARD = '/leaderboard';
  static const PROFILE = '/profile';
  static const EDIT_PROFILE = '/edit-profile';
  static const SETTINGS = '/settings';
}

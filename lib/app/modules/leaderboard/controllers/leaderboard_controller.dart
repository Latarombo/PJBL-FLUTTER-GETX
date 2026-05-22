import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class LeaderboardEntry {
  final int rank;
  final String username;
  final int score;
  final String avatarAsset;

  LeaderboardEntry({
    required this.rank,
    required this.username,
    required this.score,
    required this.avatarAsset,
  });
}

class LeaderboardController extends GetxController {
  static const String currentUsername = 'Najwa_Miniww';

  // Data leaderboard dipindah dari view ke controller
  final leaderboardData = <LeaderboardEntry>[
    LeaderboardEntry(rank: 1, username: 'keisya_pfp', score: 12500, avatarAsset: 'assets/images/avatar3.png'),
    LeaderboardEntry(rank: 2, username: 'adalahpokoknya', score: 8450, avatarAsset: 'assets/images/avatar4.png'),
    LeaderboardEntry(rank: 3, username: 'Najwa_Miniww', score: 6370, avatarAsset: 'assets/images/user.png'),
    LeaderboardEntry(rank: 4, username: 'nimiwisa_laber', score: 4220, avatarAsset: 'assets/images/avatar1.png'),
    LeaderboardEntry(rank: 5, username: 'nimiwisa_laber', score: 3400, avatarAsset: 'assets/images/avatar2.png'),
    LeaderboardEntry(rank: 6, username: 'nimiwisa_laber', score: 2500, avatarAsset: 'assets/images/avatar3.png'),
    LeaderboardEntry(rank: 7, username: 'nimiwisa_laber', score: 1580, avatarAsset: 'assets/images/avatar4.png'),
    LeaderboardEntry(rank: 8, username: 'nimiwisa_laber', score: 1200, avatarAsset: 'assets/images/avatar1.png'),
    LeaderboardEntry(rank: 9, username: 'nimiwisa_laber', score: 1100, avatarAsset: 'assets/images/avatar2.png'),
    LeaderboardEntry(rank: 10, username: 'nimiwisa_laber', score: 1000, avatarAsset: 'assets/images/avatar3.png'),
    LeaderboardEntry(rank: 11, username: 'nimiwisa_laber', score: 900, avatarAsset: 'assets/images/avatar4.png'),
    LeaderboardEntry(rank: 12, username: 'nimiwisa_laber', score: 800, avatarAsset: 'assets/images/avatar1.png'),
    LeaderboardEntry(rank: 13, username: 'nimiwisa_laber', score: 700, avatarAsset: 'assets/images/avatar2.png'),
    LeaderboardEntry(rank: 14, username: 'nimiwisa_laber', score: 600, avatarAsset: 'assets/images/avatar3.png'),
    LeaderboardEntry(rank: 15, username: 'nimiwisa_laber', score: 500, avatarAsset: 'assets/images/avatar4.png'),
    LeaderboardEntry(rank: 16, username: 'nimiwisa_laber', score: 300, avatarAsset: 'assets/images/avatar1.png'),
  ].obs;
}
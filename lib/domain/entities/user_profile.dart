class UserProfile {
  final String id;
  final String name;
  final String? avatarUrl;
  final DateTime joinedAt;
  final double heightCm;
  final double weightKg;
  final int ageYears;
  final int globalStreakDays;
  final int totalStepsWeek;
  final double totalCaloriesWeek;
  final double totalDistanceMilesWeek;

  const UserProfile({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.joinedAt,
    this.heightCm = 170,
    this.weightKg = 70,
    this.ageYears = 25,
    this.globalStreakDays = 0,
    this.totalStepsWeek = 0,
    this.totalCaloriesWeek = 0,
    this.totalDistanceMilesWeek = 0,
  });
}

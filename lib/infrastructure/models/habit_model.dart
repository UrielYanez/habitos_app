class HabitModel {
  final String id;
  final String name;
  final String category;
  final double goalValue;
  final String unit;
  final double currentValue;
  final bool isActive;
  final int streakDays;
  final String? scheduledTime; // ISO string

  const HabitModel({
    required this.id,
    required this.name,
    required this.category,
    required this.goalValue,
    required this.unit,
    this.currentValue = 0,
    this.isActive = false,
    this.streakDays = 0,
    this.scheduledTime,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) => HabitModel(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        goalValue: (json['goalValue'] as num).toDouble(),
        unit: json['unit'] as String,
        currentValue: (json['currentValue'] as num? ?? 0).toDouble(),
        isActive: json['isActive'] as bool? ?? false,
        streakDays: json['streakDays'] as int? ?? 0,
        scheduledTime: json['scheduledTime'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'goalValue': goalValue,
        'unit': unit,
        'currentValue': currentValue,
        'isActive': isActive,
        'streakDays': streakDays,
        'scheduledTime': scheduledTime,
      };
}
